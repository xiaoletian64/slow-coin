extends SceneTree
var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	if not ResourceLoader.exists("res://scripts/wallet.gd"):
		check(false, "Wallet missing: daily grants and currency must be implemented")
		quit(1)
		return
	var wallet = load("res://scripts/wallet.gd").new()
	check(wallet.balance == 10000, "initial funds")
	check(wallet.claim_daily("2026-09-29") == 5000, "daily 5000")
	check(wallet.balance == 15000, "initial plus daily")
	check(wallet.claim_daily("2026-09-29") == 0, "no duplicate")
	check(wallet.claim_daily("2026-09-28") == 0, "rollback no grant")
	check(wallet.claim_daily("2026-09-30") == 5000, "next day")
	check(wallet.spend(false), "affordable coin")
	check(wallet.balance == 19999 and wallet.inserted == 1, "debit and progress")
	check(wallet.spend(true), "practice accepted")
	check(wallet.balance == 19999 and wallet.inserted == 1, "practice isolated")
	wallet.balance = 0
	check(not wallet.spend(false), "insufficient funds")
	check(wallet.balance == 0 and wallet.inserted == 1, "failed insert no mutation")
	wallet.reward_front(false)
	check(wallet.balance == 1 and wallet.collected == 1, "front payout")
	for i in range(20):
		wallet.reward_side(false)
	check(wallet.balance == 1 and wallet.side_progress == 0, "side exits do not pay")
	wallet.reward_front(true)
	wallet.reward_side(true)
	check(wallet.balance == 1 and wallet.side_progress == 0, "practice payout isolated")
	var restore = load("res://scripts/wallet.gd").new()
	check(restore.restore(wallet.to_dict()), "valid restore")
	check(restore.balance == 1 and restore.last_daily == "2026-09-30", "restored values")
	check(not restore.restore({"balance": -2}), "reject invalid data")
	check(not restore.restore({"balance": "hello"}), "reject invalid types")
	check(restore.balance == 1, "invalid restore atomic")
	var store = load("res://scripts/save_store.gd").new("user://test-save.json")
	var data = {"version":1, "wallet":wallet.to_dict(), "boards":{}, "settings":{}}
	check(store.write(data), "write save")
	wallet.balance = 123
	data.wallet = wallet.to_dict()
	check(store.write(data), "second write")
	check(int(store.read().wallet.balance) == 123, "latest save")
	var file = FileAccess.open("user://test-save.json", FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check(int(store.read().wallet.balance) == 1, "corrupt primary recovers backup")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test-save.json" + suffix))
	print("RULES: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
	quit(0 if failures == 0 else 1)
