extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:
	var B=load("res://scripts/bonus.gd")
	var b=B.new()
	b.trigger(8000);b.tick(3);b.tick(3.4)
	for i in range(12):b.consume_coin()
	check(b.remaining==46,"first 58 prize has paid twelve")
	b.trigger(9800)
	check(b.spinning and b.remaining==46,"new draw runs while prior prize remains")
	b.tick(1)
	b.consume_coin()
	check(b.remaining==45 and b.spinning,"prior payout keeps running during reels")
	b.tick(2)
	check(b.remaining==433 and b.payouts.size()==2,"second 388 prize stacks exactly")
	var saved:Dictionary=b.to_dict()
	var restored=B.new()
	check(restored.restore(saved) and restored.remaining==433 and restored.payouts[0].emitted==13,"stack and progress restore without reroll")
	b.tick(3.4)
	for i in range(45):b.consume_coin()
	check(b.payouts.size()==1 and b.payouts[0].amount==388 and b.last_completed==58,"first prize completion advances head")
	for i in range(388):b.consume_coin()
	check(b.remaining==0 and b.emitted==446 and b.awarded==446,"all actual payout counts conserved")
	var invalid=saved.duplicate(true)
	invalid.remaining+=1
	check(not restored.restore(invalid),"reject inconsistent debt")
	invalid=saved.duplicate(true);invalid.payouts[0].emitted+=1
	check(not restored.restore(invalid),"reject duplicated payout")
	print("PARALLEL AWARDS: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
