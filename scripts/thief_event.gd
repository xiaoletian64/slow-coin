extends RefCounted

const WARNING_SECONDS: = 5.0
const COOLDOWN_SECONDS: = 90.0
const REQUIRED_INPUTS: = 30
const REQUIRED_TAPS: = 3
const MIN_BALANCE: = 100
const MAX_LOSS: = 150
var cooldown: = 45.0
var inputs: = 0
var remaining: = 0.0
var taps: = 0
var pending_loss: = 0
var encounters: = 0
var repelled: = 0
var stolen_total: = 0

func active() -> bool:
	return remaining > 0

func input_accepted(balance: int, roll: float = -1.0) -> bool:
	if active(): return false
	inputs = mini(inputs + 1, REQUIRED_INPUTS)
	if cooldown > 0 or inputs < REQUIRED_INPUTS or balance < MIN_BALANCE: return false
	if (randf() if roll < 0 else roll) >= 0.035: return false
	remaining = WARNING_SECONDS
	taps = 0
	pending_loss = mini(MAX_LOSS, maxi(3, int(floor(balance * 0.03))))
	encounters += 1
	inputs = 0
	return true


func tick(delta: float, balance: int) -> int:
	if not is_finite(delta) or delta <= 0: return 0
	if not active():
		cooldown = maxf(0, cooldown - delta)
		return 0
	remaining = maxf(0, remaining - delta)
	if remaining > 0: return 0
	var loss: = mini(maxi(0, balance), pending_loss)
	stolen_total += loss
	finish()
	return loss

func repel() -> bool:
	if not active(): return false
	taps += 1
	if taps < REQUIRED_TAPS: return false
	repelled += 1
	finish()
	return true

func finish() -> void :
	remaining = 0
	pending_loss = 0
	taps = 0
	cooldown = COOLDOWN_SECONDS

func to_dict() -> Dictionary:
	return {"cooldown": cooldown, "inputs": inputs, "remaining": remaining, "taps": taps, "pending_loss": pending_loss, "encounters": encounters, "repelled": repelled, "stolen_total": stolen_total}

func restore(data: Dictionary) -> bool:
	if data.is_empty(): return true
	for key in ["cooldown", "remaining"]:
		var value = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0: return false
	if data.cooldown > COOLDOWN_SECONDS or data.remaining > WARNING_SECONDS: return false
	for key in ["inputs", "taps", "pending_loss", "encounters", "repelled", "stolen_total"]:
		var value = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value != floor(value) or value > 1000000000000: return false
	if data.inputs > REQUIRED_INPUTS or data.taps >= REQUIRED_TAPS or data.pending_loss > MAX_LOSS or data.repelled > data.encounters: return false
	if data.remaining > 0:
		if data.pending_loss < 3 or data.encounters < 1: return false
	elif data.pending_loss != 0 or data.taps != 0: return false
	for key in data:
		if to_dict().has(key): set(key, data[key])
	return true
