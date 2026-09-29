extends SceneTree
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error(label)
func _initialize()->void:
	var B=load("res://scripts/bonus.gd")
	for pair in [[0,0],[6000,58],[9000,388],[9800,2999],[9980,29999]]:
		var b=B.new()
		check(b.trigger(pair[0]),"trigger")
		var state:Dictionary=b.to_dict()
		var restored=B.new()
		check(restored.restore(state),"valid persisted outcome")
		check(restored.remaining==0,"no coins before reels stop")
		restored.tick(3.0)
		check(restored.remaining==pair[1],"exact physical jackpot tier")
		restored.tick(3.0)
		check(restored.remaining==pair[1],"no second payout")
		var paid=B.new()
		check(paid.restore(restored.to_dict()) and paid.remaining==pair[1],"paid jackpot cannot replay after restart")
	var w=load("res://scripts/wallet.gd").new()
	if not w.has_method("claim_voice"):
		check(false,"voice catchphrase rule missing")
	else:
		w.balance=500
		check(w.claim_voice("国安是冠军")==0,"threshold strictly below 500")
		w.balance=499
		check(w.claim_voice("国安不是冠军")==0,"wrong phrase rejected")
		check(w.claim_voice("国安是冠军。")==5000 and w.balance==5499,"voice grant")
		check(w.claim_voice("国安是冠军")==0,"no repeat when funded")
	print("JACKPOT / VOICE: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
