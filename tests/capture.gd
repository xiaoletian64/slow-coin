extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.test_mode = true
	root.add_child(game)
	await create_timer(3.8).timeout
	game.set_paused(false)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/preview.png")
	game.set_paused(true)
	game.hud.show_collection(game.wallet)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/collection.png")
	paused = false
	quit()
