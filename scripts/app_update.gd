extends Node
signal changed
signal update_available
const VERSION_CODE: = 18
const VERSION_NAME: = "0.7.1"
const PACKAGE: = "com.slowcoin.pusher"
const BASE_URL: = "http://124.222.88.195/slow-coin/"
const MANIFEST_URL: = BASE_URL + "latest.json"
const Trust = preload("res://scripts/update_trust.gd")
const PART_PATH: = "user://updates/update.apk.part"
const APK_PATH: = "user://updates/update.apk"
const MAX_APK_BYTES: = 300 * 1024 * 1024
var request: HTTPRequest
var state: = "idle"
var message: = "当前版本 " + VERSION_NAME
var release: = {}
var progress: = 0.0
var automatic: = false
var elapsed: = 0.0
var bridge

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	request = HTTPRequest.new()
	request.use_threads = true
	request.max_redirects = 0
	add_child(request)
	request.request_completed.connect(_completed)
	if Engine.has_singleton("SlowCoinUpdate"):
		bridge = Engine.get_singleton("SlowCoinUpdate")
		bridge.status.connect( func(text): message = text;changed.emit())

func check(background: = false) -> void :
	if OS.get_name() != "Android": return
	if state in ["checking", "downloading"]: return
	automatic = background
	release = {}
	state = "checking"
	message = "正在检查更新…"
	request.download_file = ""
	request.body_size_limit = 65536
	request.timeout = 15
	changed.emit()
	if request.request(MANIFEST_URL, ["Cache-Control: no-cache"]) != OK:
		_fail("暂时无法连接更新服务器，可稍后重试。")

func parse_release(body: PackedByteArray, current_code: = VERSION_CODE, public_key: = Trust.PUBLIC_KEY) -> Dictionary:
	if body.size() > 65536: return {}
	var envelope = JSON.parse_string(body.get_string_from_utf8())
	if not envelope is Dictionary or not envelope.get("payload") is String or not envelope.get("signature") is String: return {}
	var payload: PackedByteArray = Marshalls.base64_to_raw(envelope.payload)
	var signature: PackedByteArray = Marshalls.base64_to_raw(envelope.signature)
	var key: = CryptoKey.new()
	if key.load_from_string(public_key, true) != OK: return {}
	var hash: = HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(payload)
	if not Crypto.new().verify(HashingContext.HASH_SHA256, hash.finish(), signature, key): return {}
	var data = JSON.parse_string(payload.get_string_from_utf8())
	if not data is Dictionary or data.get("schema") != 1 or data.get("package") != PACKAGE: return {}
	for field in ["version_code", "size"]:
		var value = data.get(field)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 1 or value != floor(value): return {}
	if data.version_code > 2100000000 or data.size > MAX_APK_BYTES: return {}
	for field in ["version", "url", "sha256", "notes"]:
		if not data.get(field) is String: return {}
	if data.version.length() > 40 or data.notes.length() > 2000: return {}
	var pattern: = RegEx.new()
	pattern.compile("^[a-f0-9]{64}$")
	if pattern.search(data.sha256) == null: return {}
	var filename: String = data.url.trim_prefix(BASE_URL + "releases/")
	pattern.compile("^ShiguangCoin-[0-9A-Za-z._-]+\\.apk$")
	if not data.url.begins_with(BASE_URL + "releases/") or pattern.search(filename) == null: return {}
	data["newer"] = int(data.version_code) > current_code
	return data

func download() -> void :
	if state != "available" or release.is_empty() or not release.get("newer", false): return
	if bridge == null:
		message = "请在 Android 版内下载更新，其他设备可打开下载页。"
		changed.emit()
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://updates"))
	_remove_file(PART_PATH)
	_remove_file(APK_PATH)
	state = "downloading"
	progress = 0
	message = "正在下载更新…"
	request.download_file = PART_PATH
	request.body_size_limit = int(release.size)
	request.timeout = 600
	changed.emit()
	if request.request(release.url, ["Accept-Encoding: identity"]) != OK: _fail("下载未能开始，请重试。")

func cancel() -> void :
	if state not in ["checking", "downloading"]: return
	request.cancel_request()
	_remove_file(PART_PATH)
	state = "available" if not release.is_empty() and release.get("newer", false) else "idle"
	message = "已取消，可以继续游戏。"
	changed.emit()

func install() -> void :
	if state != "ready" or bridge == null: return
	if not valid_apk(APK_PATH, release):
		_remove_file(APK_PATH)
		_fail("安装文件已变化，请重新下载。")
		return
	bridge.install_update(ProjectSettings.globalize_path(APK_PATH))

func valid_apk(path: String, info: Dictionary) -> bool:
	if not info.has("sha256") or not info.has("size") or not FileAccess.file_exists(path): return false
	var file: = FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var length: = file.get_length()
	file.close()
	return length == int(info.size) and FileAccess.get_sha256(path) == info.sha256

func _completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if state not in ["checking", "downloading"]: return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_fail("更新服务暂不可用，游戏可继续离线游玩。" if state == "checking" else "下载中断或文件不完整，请重试。")
		return
	if state == "checking":
		release = parse_release(body)
		if release.is_empty():
			_fail("更新信息未通过校验，请稍后重试。")
			return
		state = "available" if release.newer else "current"
		message = "发现新版本 " + release.version if release.newer else "已经是最新版本 " + VERSION_NAME
		changed.emit()
		if release.newer: update_available.emit()
	else:
		if not valid_apk(PART_PATH, release):
			_fail("安装包校验失败，请重新下载。")
			return
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(PART_PATH), ProjectSettings.globalize_path(APK_PATH)) != OK:
			_fail("无法保存安装包，请检查可用空间。")
			return
		state = "ready"
		progress = 1
		message = "安装包已校验，点击安装后由 Android 系统确认。"
		changed.emit()

func _process(delta: float) -> void :
	if state != "downloading": return
	elapsed += delta
	if elapsed < 0.25: return
	elapsed = 0
	progress = clampf(float(request.get_downloaded_bytes()) / maxf(1, float(release.size)), 0, 1)
	message = "正在下载更新 · %d%%" % int(progress * 100)
	changed.emit()

func _fail(text: String) -> void :
	_remove_file(PART_PATH)
	state = "error"
	message = text
	changed.emit()

func _remove_file(path: String) -> void :
	if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _exit_tree() -> void :
	if request != null: request.cancel_request()
