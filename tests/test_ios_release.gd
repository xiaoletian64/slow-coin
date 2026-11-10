extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	var W = load("res://scripts/wallet.gd")
	for phrase in ["guoan", "GUOAN", "Guo An", "guoan。", "国安", "各个国家的战斗到底", "各个国家战斗到底"]:
		var w = W.new()
		w.balance = 49
		check(w.claim_voice(phrase, "2026-10-26") == 200 and w.balance == 249, "accepted phrase: " + phrase)
		w.balance = 0
		check(w.claim_voice("guoan", "2026-10-26") == 0, "daily quota shared across phrases")
		var restored = W.new()
		check(restored.restore(w.to_dict()), "wallet round trip")
		restored.balance = 0
		check(restored.claim_voice(phrase, "2026-10-26") == 0, "restart retains used quota")
		check(restored.claim_voice(phrase, "2026-10-27") == 200, "next day restores quota")
	for phrase in ["国安是冠军", "国安永远争第一", "跟丫死磕", "山东驴"]:
		var w = W.new()
		w.balance = 49
		check(w.claim_voice(phrase, "2026-10-26") == 0, "retired phrase rejected: " + phrase)
	var w = W.new()
	w.balance = 50
	check(w.claim_voice("guoan", "2026-10-26") == 0, "50 is not below threshold")
	var I = load("res://scripts/i18n.gd")
	check(I.phrase_list() == ["guoan", "各个国家的战斗到底"], "single global phrase list")
	var matches: Array = I.match_list()
	for variant in ["guoan", "国安", "各个国家的战斗到底", "各个国家战斗到底"]:
		check(variant in matches, "match list variant: " + variant)
	check(I.t("拾光币社", "en") == "Time Coin Parlor", "i18n maps app title")
	check(I.t("拾光币社", "zh") == "拾光币社", "i18n keeps zh passthrough")
	check(I.t("词表里没有的一句话", "en") == "词表里没有的一句话", "i18n passes unknown strings")
	check(I.app_title("en") == "Time Coin Parlor" and I.app_title("zh") == "拾光币社", "i18n getter localized")
	check(I.skin_name("royal", "en") == "Royal Vault", "i18n skin name")
	check(I.title_name(3, "en") == "Coin Downpour", "i18n title name")
	check(I.challenge_title("inserted", "en") == "Drop warm-up · 100 real drops", "i18n challenge title")
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
