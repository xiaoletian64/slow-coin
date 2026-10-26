extends Node
signal recognized(text: String)
signal status(message: String)
signal failed(message: String)
var bridge: Object
var pending: = false
func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Engine.has_singleton("SlowCoinSpeech"):
		bridge = Engine.get_singleton("SlowCoinSpeech")
		bridge.connect("recognized", _on_recognized)
		bridge.connect("failed", _on_failed)
		if bridge.has_signal("status"):
			bridge.connect("status", func(message):
				if pending: status.emit(message))
func listen() -> void :
	if pending: return
	if bridge == null:
		failed.emit("当前设备没有可用的系统语音服务，请使用已安装语音服务的 Android 或 iPhone 真机。")
		return
	pending = true
	bridge.call("listen")
func stop() -> void :
	pending = false
	if bridge != null: bridge.call("stop")
func _on_recognized(text: String) -> void :
	if not pending: return
	pending = false
	recognized.emit(text)
func _on_failed(message: String) -> void :
	if not pending: return
	pending = false
	failed.emit(message)
