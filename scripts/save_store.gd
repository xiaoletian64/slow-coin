extends RefCounted

var path: String
var recovered := false
var error_message := ""
func _init(save_path := "user://save.json") -> void:
	path = save_path

func read() -> Dictionary:
	recovered = false
	for candidate in [path, path + ".bak"]:
		var data := _read_file(candidate)
		if not data.is_empty():
			recovered = candidate != path
			return data
	return {}

func _read_file(candidate: String) -> Dictionary:
	if not FileAccess.file_exists(candidate):
		return {}
	var file := FileAccess.open(candidate, FileAccess.READ)
	if file == null or file.get_length() > 4000000:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		return {}
	var data: Dictionary = parser.data
	if data.get("version") != 1 or not data.get("wallet") is Dictionary or not data.get("boards") is Dictionary or not data.get("settings") is Dictionary:
		return {}
	var wallet = load("res://scripts/wallet.gd").new()
	if not wallet.restore(data.wallet):
		return {}
	for key in data.boards:
		if key not in ["classic","practice","split","split_practice","sweep","sweep_practice"] or not data.boards[key] is Dictionary:
			return {}
		if not load("res://scripts/machine.gd").valid_snapshot(data.boards[key]):
			return {}
	if not data.get("practice",false) is bool:
		return {}
	for key in ["sound","haptic","music"]:
		if not data.settings.get(key,true) is bool:
			return {}
	for key in ["bonus","practice_bonus"]:
		if data.has(key):
			if not data[key] is Dictionary or not load("res://scripts/bonus.gd").new().restore(data[key]):
				return {}
	return data

func write(data: Dictionary) -> bool:
	error_message = ""
	var temporary := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if temporary == null:
		error_message = "无法保存，请检查存储空间"
		return false
	temporary.store_string(JSON.stringify(data))
	temporary.flush()
	var result := temporary.get_error()
	temporary.close()
	if result != OK:
		error_message = "保存未完成，请检查存储空间"
		return false
	# Do not replace a healthy backup with a corrupt primary.
	if not _read_file(path).is_empty():
		if DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".bak")) != OK:
			error_message = "备份未完成"
			return false
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path)) != OK:
		error_message = "存档写入失败"
		return false
	return true
