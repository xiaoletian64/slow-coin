extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.ready_to_save=false
	game.set_paused(false)
	game.apply_visual_skin("clown_deluxe")
	print("MODEL_CAPTURE: scene built")
	for i in range(60):await process_frame
	print("MODEL_CAPTURE: frames ready")
	game.set_paused(true)
	game.hud.close_modal()
	print("MODEL_CAPTURE: awaiting draw")
	RenderingServer.force_draw()
	print("MODEL_CAPTURE: draw ready")
	root.get_texture().get_image().save_png("res://builds/premium-model.png")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit()
