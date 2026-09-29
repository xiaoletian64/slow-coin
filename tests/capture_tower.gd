extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.ready_to_save=false
	game.apply_visual_skin("clown_deluxe")
	for i in range(150):await physics_frame
	game.machine.tower.inputs=12
	game.machine.tower.wait_seconds=0
	for i in range(45):await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/tower-mist.png")
	for i in range(130):await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/tower-reveal.png")
	var max_y:=0.0
	for coin in game.machine.coins.get_children():
		if not coin.in_pinboard:max_y=maxf(max_y,coin.position.y)
	print("VISIBLE TOWER top: ",max_y," total coins ",game.machine.coins.get_child_count())
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit()
