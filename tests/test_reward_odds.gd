extends SceneTree

func _initialize()->void:
	var Bonus=load("res://scripts/bonus.gd")
	var counts:=[0,0,0,0,0]
	var total:=0
	for roll in range(10000):
		var tier:int=Bonus.tier_for_roll(roll)
		counts[tier+1]+=1
		if tier>=0:total+=Bonus.PRIZES[tier]
	if counts!=[8000,1800,180,18,2] or total!=288220:
		push_error("Reward distribution or expected payout changed")
		quit(1)
		return
	# Existing committed results must survive the odds change unmodified.
	for roll in [8000,9800,9980,9998]:
		var previous=Bonus.new()
		previous.trigger(roll)
		var saved:Dictionary=previous.to_dict()
		var restored=Bonus.new()
		if not restored.restore(saved) or restored.reward!=previous.reward:
			push_error("Committed award lost during restore")
			quit(1)
			return
	print("REWARD ODDS: PASS counts=",counts," mean=28.822 coins per draw")
	quit(0)
