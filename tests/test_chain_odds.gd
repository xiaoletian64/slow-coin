extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:
	var B=load("res://scripts/bonus.gd")
	var counts:=[0,0,0,0,0]
	for roll in range(10000):counts[B.tier_for_roll(roll,true)+1]+=1
	check(counts==[9500,480,20,0,0],"chain odds exactly 5 percent, only two small tiers")
	var b=B.new()
	b.trigger(9998);b.tick(3);b.tick(3.4)
	b.trigger(9999)
	check(b.reduced_draw and b.reward==388 and b.remaining==29999,"outstanding prize lowers next draw without cutting debt")
	b.trigger()
	check(b.pending_reduced==[true],"queued opportunity remembers reduced pool")
	var restored=B.new()
	check(restored.restore(b.to_dict()) and restored.pending_reduced==[true] and restored.reward==388,"save preserves committed result and chain flag")
	var pool:int=restored.remaining+restored.reward
	restored.settle_pending(50)
	check(restored.last_settlement_pool in [pool,pool+58,pool+388],"roulette cannot upgrade chain chance to large jackpot")
	check(restored.pending_reduced.is_empty(),"settlement clears flags")
	# Finish both committed prizes before starting the queued chain opportunity.
	b.tick(3);b.tick(3.39)
	for row in b.payouts:row.wait=0.0
	while b.remaining>0:b.consume_coin()
	b.tick(0.02)
	check(b.spinning and b.reduced_draw and b.reward in [0,58,388],"queued chain remains reduced after all physical debt is emitted")
	var normal=B.new()
	normal.trigger(9999)
	check(not normal.reduced_draw and normal.reward==29999,"ordinary draw retains full pool")
	var invalid=b.to_dict();invalid.pending_reduced=["bad"]
	check(not B.new().restore(invalid),"invalid chain flag rejected")
	print("CHAIN ODDS: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
