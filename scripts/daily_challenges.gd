extends RefCounted


const TARGETS: = {"inserted": 100, "collected": 40, "chased": 1}
const TITLES: = {"inserted": "投币练手 · 正式投币 100 枚", "collected": "前口丰收 · 实收 40 枚", "chased": "守住钱包 · 驱赶小偷 1 次"}
const ORDER: = ["inserted", "collected", "chased"]
const RANKS: = [
	[0, "新晋挑战者"], [3, "街机学徒"], [12, "挑战能手"],
	[30, "机台守护者"], [60, "街机达人"], [120, "传奇收藏家"],
]
const MAX_TOTAL: = 1000000000
var day: = ""
var progress: = {"inserted": 0, "collected": 0, "chased": 0}
var completed_total: = 0

func ensure_day(value: String) -> bool:
	if not valid_date(value) or value < day:
		return false
	if value > day:
		day = value
		progress = {"inserted": 0, "collected": 0, "chased": 0}
	return true

func record(kind: String, amount, date: String) -> Array:
	var completed: Array = []

	if not TARGETS.has(kind) or not whole_number(amount, MAX_TOTAL) or amount <= 0:
		return completed
	if not ensure_day(date):
		return completed
	var target: int = TARGETS[kind]
	var before: int = progress[kind]
	progress[kind] = mini(target, before + int(amount))
	if before < target and int(progress[kind]) == target:
		completed_total = mini(MAX_TOTAL, completed_total + 1)
		completed.append(TITLES[kind])
	return completed

func rows() -> Array:
	var result: Array = []
	for kind in ORDER:
		result.append({"kind": kind, "title": TITLES[kind], "target": TARGETS[kind],
			"progress": progress[kind], "completed": int(progress[kind]) >= int(TARGETS[kind])})
	return result

func rank_name() -> String:
	var result: String = RANKS[0][1]
	for rank in RANKS:
		if completed_total >= int(rank[0]):
			result = rank[1]
	return result

func to_dict() -> Dictionary:
	return {"version": 1, "day": day, "progress": progress.duplicate(), "completed_total": completed_total}

func restore(data) -> bool:
	if not data is Dictionary:
		return false

	if data.is_empty():
		day = ""
		progress = {"inserted": 0, "collected": 0, "chased": 0}
		completed_total = 0
		return true
	if not whole_number(data.get("version"), 1) or data.version != 1:
		return false
	var saved_day = data.get("day")
	var saved_progress = data.get("progress")
	var total = data.get("completed_total")
	if not saved_day is String or (saved_day != "" and not valid_date(saved_day)):
		return false
	if not saved_progress is Dictionary or saved_progress.size() != TARGETS.size():
		return false
	if not whole_number(total, MAX_TOTAL):
		return false
	var checked: = {}
	var today_completed: = 0
	for kind in ORDER:
		var value = saved_progress.get(kind)
		if not whole_number(value, int(TARGETS[kind])):
			return false
		checked[kind] = int(value)
		if checked[kind] == TARGETS[kind]:
			today_completed += 1
		if saved_day == "" and value != 0:
			return false
	if int(total) < today_completed or (saved_day == "" and total != 0):
		return false

	day = saved_day
	progress = checked
	completed_total = int(total)
	return true

static func whole_number(value, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= 0 and value <= maximum and float(value) == floor(float(value))

static func valid_date(value: String) -> bool:
	if value.length() != 10 or value[4] != "-" or value[7] != "-":
		return false
	var digits: = value.replace("-", "")
	if digits.length() != 8:
		return false
	for character in digits:
		if character < "0" or character > "9":
			return false
	var year: = int(value.substr(0, 4))
	var month: = int(value.substr(5, 2))
	var date: = int(value.substr(8, 2))
	if year < 1 or month < 1 or month > 12 or date < 1:
		return false
	var days: = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0):
		days[1] = 29
	return date <= int(days[month - 1])
