extends SceneTree
func _initialize()->void:call_deferred("run")
func shot(path:String)->void:
	for i in range(3):await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(path)
func run()->void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.ready_to_save=false
	game.set_paused(true)
	game.hud.show_titles(game.wallet)
	await shot("res://builds/060-daily-titles.png")
	game.hud.show_titles(game.wallet,false)
	await shot("res://builds/060-permanent-titles.png")
	game.hud.show_pause(true,true,true)
	await shot("res://builds/060-pause.png")
	game.coin_designer.load_selected("res://assets/art/premium-circus-atlas.png")
	await shot("res://builds/060-coin-designer.png")
	game.hud.show_settlement(32000,7)
	await shot("res://builds/060-roulette-confirm.png")
	game.hud.show_settlement_result(35000,42,14700)
	await create_timer(3.1,true).timeout
	await shot("res://builds/060-roulette-result.png")
	game.feedback.stop_all();game.queue_free()
	await process_frame
	quit()
