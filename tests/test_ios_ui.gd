extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.test_mode = true
	root.add_child(game)
	game.open_voice()
	var text := ""
	var pending: Array[Node] = [game.hud]
	while not pending.is_empty():
		var n = pending.pop_back()
		if n is Label: text += n.text + "\n"
		for child in n.get_children(): pending.append(child)
	for phrase in ["guoan", "各个国家的战斗到底"]:
		check(phrase in text, "visible phrase " + phrase)
	for phrase in ["国安是冠军", "国安永远争第一", "跟丫死磕", "山东驴"]:
		check(not phrase in text, "retired phrase absent " + phrase)
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	print("IOS UI COPY: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
