extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	await process_frame
	game.open_voice()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/input-sheet.png")
	game.open_pause()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/pause-sheet.png")
	game.set_paused(false)
	game.bonus.trigger(9000)
	game._physics_process(3.0)
	await create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/win-show.png")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
