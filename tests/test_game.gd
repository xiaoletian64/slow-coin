extends SceneTree
var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	if not ResourceLoader.exists("res://scenes/main.tscn"):
		check(false, "Game scene missing: input and physics must be implemented")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.test_mode = true
	root.add_child(game)
	await process_frame
	game.set_paused(false)
	var before: int = game.wallet.balance
	game.hud.drop_button.button_down.emit()
	check(game.wallet.balance == before - 1, "one button-down one debit")
	await create_timer(0.7).timeout
	check(game.wallet.inserted == 1, "holding never repeats")
	check(game.machine.coins.get_child_count() >= 110, "initial bed stays on the machine")
	for c in game.machine.coins.get_children():
		check(c.in_pinboard or c.linear_velocity.length()<4.0, "no initial kinematic impulse")
	var echo := InputEventKey.new()
	echo.keycode = KEY_SPACE
	echo.pressed = true
	echo.echo = true
	game._unhandled_key_input(echo)
	check(game.wallet.inserted == 1, "ignore keyboard echo")
	game.set_paused(true)
	var phase: float = game.machine.phase
	game.request_coin()
	await create_timer(0.15).timeout
	check(game.wallet.inserted == 1 and game.machine.phase == phase, "pause blocks physics and input")
	game.set_paused(false)
	for i in range(4):
		game.request_coin()
	var save: Dictionary = game.make_save()
	check(save.boards.classic.queue.size() == 4, "paid queue in save")
	var inserted: int = game.wallet.inserted
	game.switch_mode()
	game.set_paused(false)
	game.request_coin()
	check(game.wallet.inserted == inserted, "practice input isolated")
	var money: int = game.wallet.balance
	game.on_coin_exited(true, Vector3.ZERO)
	game.on_coin_exited(false, Vector3.ZERO)
	check(game.wallet.balance == money, "practice reward isolated")
	game.switch_mode()
	check(game.machine.pending.size() == 4, "formal queue restored after practice")
	check(game.wallet.inserted == inserted, "restore queue no re-debit")
	game.machine.clear_coins()
	game.machine.pending.clear()
	for i in range(240):
		game.machine.pending.append(0.0)
	money = game.wallet.balance
	game.request_coin()
	check(game.wallet.balance == money-1 and game.machine.pending.size()==241, "long queue accepts input with one debit")
	money=game.wallet.balance
	game.machine.pending.clear()
	var front = game.machine.spawn_coin(Vector3(0, -0.4, 3.3))
	game.machine.settle_exits()
	check(not is_instance_valid(front) or not front.get_parent(), "front coin removed immediately")
	check(game.wallet.balance == money + 1, "front scores once")
	game.machine.settle_exits()
	check(game.wallet.balance == money + 1, "no duplicate settlement")
	var probe = game.machine.spawn_coin(Vector3(0, 0.07, -1.25))
	game.machine.phase = 0
	game.machine.update_pusher()
	for i in range(180):
		await physics_frame
	check(is_instance_valid(probe) and probe.position.z > -1.0, "pusher physically moves coin forward")
	check(is_instance_valid(probe) and probe.position.y > -0.15, "coin does not tunnel through shelf")
	var snap: Dictionary = game.machine.snapshot()
	game.machine.restore(snap)
	check(game.machine.coins.get_child_count() == snap.coins.size(), "snapshot restores coin count")
	# A full pile should remain finite and bounded under actual physics.
	game.machine.clear_coins()
	game.machine.seed_coins()
	for i in range(90):
		game.machine.spawn_coin(Vector3(randf_range(-2.6,2.6), 1.0 + i * 0.012, randf_range(-2.4,2.4)))
	for i in range(180):
		await physics_frame
	for coin in game.machine.coins.get_children():
		check(coin.position.is_finite() and coin.position.y > -1.0, "stress finite, no leaked coins")
	game.set_paused(false)
	game._notification(MainLoop.NOTIFICATION_APPLICATION_PAUSED)
	check(game.paused, "background pauses")
	game._notification(MainLoop.NOTIFICATION_APPLICATION_RESUMED)
	check(game.paused, "foreground requires explicit resume")
	print("GAME: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	paused = false
	quit(0 if failures == 0 else 1)
