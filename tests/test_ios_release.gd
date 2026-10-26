extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	var W = load("res://scripts/wallet.gd")
	for phrase in ["国安是冠军", "国安永远争第一", "跟丫死磕"]:
		var w = W.new()
		w.balance = 49
		check(w.claim_voice(phrase, "2026-10-26") == 200 and w.balance == 249, "accepted phrase: " + phrase)
		w.balance = 0
		check(w.claim_voice("跟丫死磕", "2026-10-26") == 0, "daily quota shared across phrases")
		var restored = W.new()
		check(restored.restore(w.to_dict()), "wallet round trip")
		restored.balance = 0
		check(restored.claim_voice(phrase, "2026-10-26") == 0, "restart retains used quota")
		check(restored.claim_voice(phrase, "2026-10-27") == 200, "next day restores quota")
	var w = W.new()
	w.balance = 50
	check(w.claim_voice("国安是冠军", "2026-10-26") == 0, "50 is not below threshold")
	w.balance = 0
	check(w.claim_voice("山东驴", "2026-10-26") == 0, "removed phrase rejected")
	var B = load("res://scripts/bonus.gd")
	var b = B.new()
	b.pending_spins = 20
	b.pending_reduced = []
	b.trim_chain_queue()
	check(b.pending_spins == 20 and b.pending_reduced.size() == 20, "0.7.1 keeps accumulated pending spins")
	var restored = B.new()
	check(restored.restore(b.to_dict()) and restored.pending_spins == 20, "pending queue persists")
	print("IOS RELEASE REGRESSIONS: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
