extends RefCounted



const SYMBOLS: = ["cherry", "bell", "star", "seven"]
const LINES: = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 4, 8], [6, 4, 2]]
const SETTLEMENT_THRESHOLD: = 200
const CHAIN_LIMIT: = 2
const PRIZES: = [58, 388, 2999, 29999]
const ROLL_COUNT: = 1000000
const PATTERNS: = ["逐枚吐币", "连续吐币", "摆动吐币", "快速吐币"]
var spinning: = false
var elapsed: = 0.0
var cooldown: = 0.0
var reward: = 0
var remaining: = 0
var dispense_clock: = 0.0
var presentation: = 0.0
var reels: Array = ["cherry", "bell", "seven"]
var tier: = -1
var credited: = true
var emitted: = 0
var pending_spins: = 0
var pending_reduced: Array = []
var reduced_draw: = false
var chain_used: = 0
var awarded: = 0
var settled: = 0
var last_settlement_pool: = 0
var payouts: Array = []
var last_completed: = 0
var completed_timer: = 0.0
var grid: Array = ["cherry", "bell", "star", "bell", "star", "seven", "seven", "cherry", "bell"]
var winning_line: = -1




static func tier_for_roll(roll: int, reduced: = false) -> int:
	if roll < 0 or roll >= ROLL_COUNT: return -1
	if reduced:
		if roll >= 999900: return 1
		return 0 if roll >= 995000 else -1
	if roll >= 999999: return 3
	if roll >= 999900: return 2
	if roll >= 999000: return 1
	if roll >= 970000: return 0
	return -1

func winning_active() -> bool:
	return remaining > 0 or presentation > 0 or (spinning and reward > 0)

func trim_chain_queue() -> void :


	while pending_reduced.size() < pending_spins:
		pending_reduced.append(winning_active())

func trigger(roll: = -1, reduced_override: = -1, from_queue: = false) -> bool:
	trim_chain_queue()
	var reduced: bool = winning_active() if reduced_override < 0 else reduced_override == 1
	if not from_queue and reduced and chain_used + pending_reduced.count(true) >= CHAIN_LIMIT: return false
	if spinning or presentation > 0:
		while pending_reduced.size() < pending_spins: pending_reduced.append(winning_active())
		pending_spins += 1
		pending_reduced.append(reduced)
		return true
	if roll < 0:
		roll = randi_range(0, ROLL_COUNT - 1)
	reduced_draw = reduced
	if reduced: chain_used = mini(CHAIN_LIMIT, chain_used + 1)
	tier = tier_for_roll(roll, reduced)
	if tier >= 0:
		reels = [SYMBOLS[tier], SYMBOLS[tier], SYMBOLS[tier]]
		reward = PRIZES[tier]
	else:
		var shift: = roll % 4
		reels = [SYMBOLS[shift], SYMBOLS[(shift + 1) % 4], SYMBOLS[(shift + 2) % 4]]
		reward = 0
	build_grid(roll)
	spinning = true
	elapsed = 0
	cooldown = 0.0
	credited = false
	if tier >= 0 and not reduced: chain_used = 0
	trim_chain_queue()
	return true

func tick(delta: float) -> bool:
	completed_timer = maxf(0, completed_timer - delta)
	for payout in payouts: payout.wait = maxf(0, float(payout.wait) - delta)
	presentation = maxf(0, presentation - delta)
	var started: = false
	trim_chain_queue()
	if not spinning and presentation <= 0 and pending_spins > 0:
		pending_spins -= 1
		var reduced: bool = bool(pending_reduced.pop_front()) if not pending_reduced.is_empty() else false
		trigger(-1, 1 if reduced else 0, true)
		started = true
	cooldown = maxf(0, cooldown - delta)
	dispense_clock = maxf(0, dispense_clock - delta)
	if spinning and not started:
		elapsed += delta
		if elapsed >= 3.0:
			elapsed = 3.0
			spinning = false
			presentation = 3.4 if reward > 0 else 0.0
			if reward > 0:
				remaining += reward
				awarded += reward
				payouts.append({"amount": reward, "tier": tier, "remaining": reward, "emitted": 0, "wait": 3.4})
			return true
	return false

func ready_coin_count() -> int:
	var total: = 0
	for row in payouts:
		if float(row.wait) > 0: break
		total += int(row.remaining)
	return total

func settle_pending(percent: int) -> int:
	if percent < 1 or percent > 90 or remaining <= 0: return 0
	trim_chain_queue()
	var extra: = reward if spinning else 0
	for i in range(pending_spins):
		var roll: = randi_range(0, ROLL_COUNT - 1)
		var reduced: bool = bool(pending_reduced[i])
		if reduced: chain_used = mini(CHAIN_LIMIT, chain_used + 1)
		var draw_tier: = tier_for_roll(roll, reduced)
		if draw_tier >= 0: extra += PRIZES[draw_tier]
	awarded += extra
	last_settlement_pool = remaining + extra
	var value: = int(floor(float(last_settlement_pool) * percent / 100.0))
	settled += last_settlement_pool
	remaining = 0
	payouts.clear()
	pending_spins = 0
	pending_reduced.clear()
	spinning = false
	elapsed = 3.0
	presentation = 0
	completed_timer = 0
	return value

func can_dispense() -> bool:
	return not payouts.is_empty() and float(payouts[0].wait) <= 0

func payout_tier() -> int:
	return int(payouts[0].tier) if not payouts.is_empty() else 0

func payout_emitted() -> int:
	return int(payouts[0].emitted) if not payouts.is_empty() else 0

func consume_coin() -> int:
	if not can_dispense(): return 0
	payouts[0].remaining -= 1
	payouts[0].emitted += 1
	remaining -= 1
	emitted += 1
	if payouts[0].remaining == 0:
		last_completed = int(payouts[0].amount)
		completed_timer = 3.0
		payouts.pop_front()
		return last_completed
	return 0

func build_grid(seed_value: int) -> void :
	var rng: = RandomNumberGenerator.new()
	rng.seed = seed_value + 9371
	winning_line = seed_value % LINES.size() if tier >= 0 else -1
	while true:
		grid.clear()
		for i in range(9): grid.append(SYMBOLS[rng.randi_range(0, 3)])
		if winning_line >= 0:
			for cell in LINES[winning_line]: grid[cell] = SYMBOLS[tier]
		if valid_grid(grid, tier, winning_line): break
	reels = [grid[3], grid[4], grid[5]]

static func valid_grid(cells: Array, result_tier: int, line: int) -> bool:
	if cells.size() != 9 or line < -1 or line >= LINES.size(): return false
	for cell in cells:
		if cell not in SYMBOLS: return false
	var wins: = 0
	for i in range(LINES.size()):
		var indices: Array = LINES[i]
		if cells[indices[0]] == cells[indices[1]] and cells[indices[1]] == cells[indices[2]]:
			wins += 1
			if i != line or result_tier < 0 or cells[indices[0]] != SYMBOLS[result_tier]: return false
	return wins == (1 if result_tier >= 0 else 0)

func column(index: int) -> Array:
	return [grid[index], grid[index + 3], grid[index + 6]]

func lit_rows(index: int) -> Array:
	var rows: Array = []
	if winning_line >= 0 and not spinning:
		for cell in LINES[winning_line]:
			if cell % 3 == index: rows.append(cell / 3)
	return rows

func pattern_name() -> String:
	return PATTERNS[tier] if tier >= 0 else "等待命中奖口"

func to_dict() -> Dictionary:
	return {"chain_used": chain_used, "pending_reduced": pending_reduced.duplicate(), "reduced_draw": reduced_draw, "format": 4, "awarded": awarded, "settled": settled, "payouts": payouts.duplicate(true), "spinning": spinning, "elapsed": elapsed, "cooldown": cooldown, "reward": reward, "remaining": remaining, "dispense_clock": dispense_clock, "presentation": presentation, "reels": reels.duplicate(), "tier": tier, "credited": credited, "emitted": emitted, "pending_spins": pending_spins, "grid": grid.duplicate(), "winning_line": winning_line}

func restore(data: Dictionary) -> bool:
	if data.get("format") == 4: return restore_parallel(data)


	if data.get("format", 1) in [1, 2]:
		var legacy = data.duplicate(true)
		if legacy.get("format", 1) == 1:
			var old: int = int(legacy.get("reward", 0))
			if old not in [0, 3, 8, 18]: return false
			var old_tier: int = {0: -1, 3: 0, 8: 1, 18: 2}[old]
			legacy = {"format": 2, "spinning": legacy.get("spinning", false), "credited": true, "reels": ["cherry", "bell", "seven"], "elapsed": 0, "cooldown": 0, "reward": 0, "remaining": 0, "dispense_clock": 0, "tier": -1, "emitted": 0}
			if old_tier >= 0:
				legacy.tier = old_tier
				legacy.reward = PRIZES[old_tier]
				legacy.reels = [SYMBOLS[old_tier], SYMBOLS[old_tier], SYMBOLS[old_tier]]
		legacy.format = 3
		legacy.remaining = 0
		legacy.emitted = 0 if legacy.get("spinning", false) else legacy.get("reward", 0)
		legacy.cooldown = 0
		legacy.pending_spins = 0
		return restore(legacy)
	if data.get("format") != 3 or not data.get("spinning") is bool or not data.get("credited") is bool or not data.get("reels") is Array or data.reels.size() != 3:
		return false
	for symbol in data.reels:
		if symbol not in SYMBOLS: return false
	for key in ["elapsed", "cooldown", "reward", "remaining", "dispense_clock", "tier", "emitted", "pending_spins"]:
		var v = data.get(key)
		if not (v is int or v is float) or not is_finite(float(v)): return false
	for key in ["reward", "remaining", "tier", "emitted", "pending_spins"]:
		if floor(float(data[key])) != float(data[key]): return false
	if data.tier < -1 or data.tier > 3 or data.elapsed < 0 or data.elapsed > 3 or data.cooldown < 0 or data.cooldown > 9 or data.dispense_clock < 0 or data.dispense_clock > 0.5:
		return false
	var expected: int = PRIZES[int(data.tier)] if data.tier >= 0 else 0
	var count: int = expected
	if data.reward != expected or data.remaining < 0 or data.remaining > count or data.emitted < 0 or data.emitted > count:
		return false
	if data.pending_spins < 0 or data.pending_spins > 1000000: return false
	if data.spinning:
		if data.remaining != 0 or data.emitted != 0: return false
	elif data.remaining + data.emitted != count: return false
	var cells = data.get("grid", [])
	var line = data.get("winning_line", -1)
	if not cells is Array or not (line is int or line is float) or not is_finite(float(line)) or float(line) != floor(float(line)): return false
	if not cells.is_empty() and not valid_grid(cells, int(data.tier), int(line)): return false
	var shown = data.get("presentation", 0.0)
	if not (shown is int or shown is float) or not is_finite(float(shown)) or shown < 0 or shown > 3.4: return false
	presentation = float(shown)
	spinning = data.spinning
	elapsed = float(data.elapsed)
	cooldown = float(data.cooldown)
	reward = int(data.reward)
	remaining = int(data.remaining)
	dispense_clock = float(data.dispense_clock)
	reels = data.reels.duplicate()
	tier = int(data.tier)
	credited = data.credited
	emitted = int(data.emitted)
	pending_spins = int(data.pending_spins)
	pending_reduced = []
	reduced_draw = false
	chain_used = 0
	if cells.is_empty():
		build_grid(42)
	else:
		grid = cells.duplicate()
		winning_line = int(line)
	settled = 0
	awarded = remaining + emitted
	payouts = []
	if remaining > 0: payouts.append({"amount": reward, "tier": tier, "remaining": remaining, "emitted": emitted, "wait": presentation})
	return true

func restore_parallel(data: Dictionary) -> bool:
	var used = data.get("chain_used", 1 if data.get("reduced_draw", false) and data.get("spinning", false) else 0)
	if not (used is int or used is float) or not is_finite(float(used)) or used < 0 or used > CHAIN_LIMIT or float(used) != floor(float(used)): return false
	var modes = data.get("pending_reduced", [])
	if not modes is Array or modes.size() > 1000000: return false
	for mode in modes:
		if not mode is bool: return false
	if not data.get("reduced_draw", false) is bool: return false
	var rows = data.get("payouts")
	if not rows is Array or rows.size() > 1000000: return false
	for key in ["awarded", "remaining", "emitted"]:
		var value = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) != floor(float(value)) or value < 0 or value > 1000000000000.0: return false
	var redeemed = data.get("settled", 0)
	if not (redeemed is int or redeemed is float) or not is_finite(float(redeemed)) or redeemed < 0 or redeemed > 1000000000000.0 or floor(float(redeemed)) != float(redeemed): return false
	if data.awarded != data.remaining + data.emitted + redeemed: return false
	var owed: = 0
	var partial: = 0
	for row in rows:
		if not row is Dictionary: return false
		for key in ["amount", "tier", "remaining", "emitted"]:
			var value = row.get(key)
			if not (value is int or value is float) or not is_finite(float(value)) or float(value) != floor(float(value)): return false
		if row.tier < 0 or row.tier > 3 or row.amount != PRIZES[int(row.tier)] or row.remaining <= 0 or row.emitted < 0 or row.remaining + row.emitted != row.amount: return false
		var wait = row.get("wait")
		if not (wait is int or wait is float) or not is_finite(float(wait)) or wait < 0 or wait > 3.4: return false
		owed += int(row.remaining)
		partial += int(row.emitted)
	if owed != data.remaining or partial > data.emitted: return false

	var legacy = data.duplicate(true)
	legacy.format = 3
	legacy.remaining = 0 if legacy.get("spinning", false) else legacy.get("reward", -1)
	legacy.emitted = 0
	if not restore(legacy): return false
	if modes.size() > pending_spins: return false
	pending_reduced = modes.duplicate()
	reduced_draw = data.get("reduced_draw", false)
	settled = int(redeemed)
	awarded = int(data.awarded)
	remaining = int(data.remaining)
	emitted = int(data.emitted)
	payouts = rows.duplicate(true)
	chain_used = int(used)
	trim_chain_queue()
	return true
