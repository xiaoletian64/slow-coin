extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var input:=Image.create(512,256,false,Image.FORMAT_RGBA8)
	input.fill(Color.WHITE)
	input.fill_rect(Rect2i(128,64,128,128),Color.BLACK)
	input.save_png("res://builds/coin-import-test.png")
	var Design=load("res://scripts/coin_designer.gd")
	var stamp:Image=Design.simplify(input,1,Vector2.ZERO)
	check(stamp.get_size()==Vector2i(256,256) and stamp.get_pixel(0,0).a==0,"circular simplified texture")
	check(stamp.get_pixel(110,110).r<0.1,"preserve central silhouette")
	var game=load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	game.set_paused(true)
	var coin=game.machine.coins.get_child(0)
	var before:Transform3D=coin.transform
	var collider=coin.get_child(0).shape
	game.machine.apply_coin_stamp(ImageTexture.create_from_image(stamp))
	check(coin.get_node("Visual").material_override==coin.stamp_material,"existing coins share printed face")
	check(coin.transform==before and coin.get_child(0).shape==collider,"design never changes physics")
	var next=game.machine.spawn_coin(Vector3.ZERO)
	check(next.get_node("Visual").material_override==coin.stamp_material,"new coins inherit design")
	game.machine.apply_skin("clown_deluxe")
	check(next.get_node("Visual").material_override==coin.stamp_material,"premium skin preserves personal design")
	game.machine.apply_coin_stamp(null)
	check(next.get_node("Visual").material_override!=coin.stamp_material,"restore default coin")
	game.feedback.stop_all();game.queue_free()
	await process_frame
	print("CUSTOM COIN: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
