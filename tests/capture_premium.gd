extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	game.ready_to_save=false
	game.apply_visual_skin("clown_deluxe")
	for i in range(120):await physics_frame
	game.set_paused(true)
	game.hud.close_modal()
	game.hud.toast_label.visible=false
	game.hud.payout_label.visible=false
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://builds/premium-game.png")
	game.viewport.get_texture().get_image().save_png("res://assets/art/premium-preview.png")
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	quit()
