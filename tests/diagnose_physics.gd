extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.test_mode=true
	root.add_child(game)
	for i in range(300):
		await physics_frame
		if i in [0,1,2,5,10,30,60,120,240,299]:
			var low:=0
			var high:=0
			var max_speed:=0.0
			var zs: Array=[]
			for c in game.machine.coins.get_children():
				if c.position.y<0.3: low+=1
				else: high+=1
				max_speed=maxf(max_speed,c.linear_velocity.length())
				zs.append(snapped(c.position.z,0.1))
			print(i," low=",low," high=",high," speed=",max_speed," balance=",game.wallet.balance," z=",zs.slice(0,15))
	quit()
