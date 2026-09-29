extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.machine.phase=0
	game.machine.spin_target.position.x=0
	var coin=game.machine.spawn_coin(Vector3(0,2.3,-1.44))
	coin.rotation.x=PI/2
	coin.set_pinboard(true)
	coin.previous_y=2.3
	coin.linear_velocity=Vector3(0,-1,0)
	await create_timer(0.65).timeout
	if not game.bonus.spinning:
		push_error("Physical target crossing did not start slot")
		quit(1)
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/spin-hit.png")
	print("PHYSICAL TARGET -> REELS: PASS")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
