extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(false)
	for pair in [[58,"cat"],[388,"dog"],[2999,"cart"],[29999,"vault"]]:
		game.set_paused(true)
		game.hud.close_modal()
		game.jackpot_fx.celebrate(pair[0],1.4)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://builds/story-"+pair[1]+".png")
	game.set_paused(false)
	game.feedback.stop_all()
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
