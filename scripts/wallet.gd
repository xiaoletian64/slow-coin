extends RefCounted

const COST: = 1
const DAILY: = 500
const VOICE_RESCUE: = 200
const VOICE_BALANCE_LIMIT: = 50
const COLLECTION_NAMES: = ["初见黄铜", "海盐薄荷", "落日珊瑚", "午夜星光", "琥珀回声", "银河漫游"]
const SKINS: = {
	"classic": {"name": "经典街机", "price": 0, "body": "17324d", "bed": "243742", "trim": "bca36b"},
	"mint": {"name": "海盐薄荷", "price": 1500, "body": "39776e", "bed": "285c5b", "trim": "a9e3ce"},
	"sakura": {"name": "落日樱粉", "price": 3500, "body": "915b6c", "bed": "634553", "trim": "edbfa4"},
	"clown_deluxe": {"name": "经典小丑·典藏", "price": 12000, "body": "173f96", "bed": "89969e", "trim": "d5bd73"},
	"galaxy": {"name": "午夜银河", "price": 6000, "body": "4b4981", "bed": "302f55", "trim": "b7a9e6"},
	"retro": {"name": "复古街机", "price": 0, "login_days": 3, "body": "653d34", "bed": "34434b", "trim": "c5a36c"},
	"future": {"name": "未来霓虹", "price": 0, "login_days": 10, "body": "18374b", "bed": "253949", "trim": "69e0ec"},
	"royal": {"name": "皇家典藏", "price": 100000, "body": "342449", "bed": "34333f", "trim": "e5bf69"},
	"aurora": {"name": "极光幻彩", "price": 200000, "body": "245e64", "bed": "253d4c", "trim": "a7d9cb"}
}
const TITLES: = [
	["初来乍到", "inserted", 0], ["试试手气", "inserted", 1], ["街机常客", "inserted", 50], ["落币如雨", "inserted", 500], ["千投不倦", "inserted", 2000],
	["第一桶金", "collected", 1], ["百币入袋", "collected", 100], ["收币能手", "collected", 1000], ["万币归仓", "collected", 10000], ["拾光收藏家", "collected", 50000],
	["好运开张", "jackpots", 1], ["好事成双", "jackpots", 10], ["中奖专业户", "jackpots", 100],
	["毛球捕手", "best_prize", 58], ["火腿搭档", "best_prize", 388], ["金币车车长", "best_prize", 2999], ["金库来客", "best_prize", 29999],
	["高塔见习生", "towers", 1], ["推塔高手", "towers", 10], ["换装玩家", "skins", 2], ["机台收藏家", "skins", 5],
	["私人铸币师", "custom", 1], ["再来一局", "restarts", 1], ["轮盘体验官", "roulette", 1]
]
const DAILY_TITLES: = [
	["今日开张", "inserted", 1], ["随手十投", "inserted", 10], ["今日落币手", "inserted", 50], ["今日收币员", "collected", 10],
	["今日小丰收", "collected", 100], ["今日好运", "jackpots", 1], ["今日推塔手", "towers", 1], ["今日铸币师", "custom", 1]
]
var daily_date: = ""
var daily_records: Dictionary = {}
var records: Dictionary = {}
var equipped_title: = 0
func ensure_title_day() -> void :
	var date: = Time.get_date_string_from_system()
	if daily_date == date: return
	daily_date = date
	daily_records = {}
	if equipped_title >= 100: equipped_title = 0
func daily_record(key: String, amount: = 1) -> void :
	ensure_title_day()
	daily_records[key] = int(daily_records.get(key, 0)) + amount
func title_name() -> String:
	ensure_title_day()
	return str(DAILY_TITLES[equipped_title - 100][0]) if equipped_title >= 100 else str(TITLES[equipped_title][0])
func title_progress(index: int) -> int:
	ensure_title_day()
	if index >= 100 and index < 100 + DAILY_TITLES.size(): return int(daily_records.get(DAILY_TITLES[index - 100][1], 0))
	if index < 0 or index >= TITLES.size(): return 0
	match TITLES[index][1]:
		"inserted": return inserted
		"collected": return collected
		"skins": return owned_skins.size()
	return int(records.get(TITLES[index][1], 0))
func has_title(index: int) -> bool:
	if index >= 100 and index < 100 + DAILY_TITLES.size(): return title_progress(index) >= int(DAILY_TITLES[index - 100][2])
	return index >= 0 and index < TITLES.size() and title_progress(index) >= int(TITLES[index][2])
func equip_title(index: int) -> bool:
	if not has_title(index): return false
	equipped_title = index
	return true
func record(key: String, amount: = 1) -> void :
	records[key] = int(records.get(key, 0)) + amount
	daily_record(key, amount)

var owned_skins: Array = ["classic"]
var equipped_skin: = "classic"
var balance: = 1000
var last_daily: = ""
var voice_last_daily: = ""
var last_login: = ""
var login_streak: = 0
var inserted: = 0
var collected: = 0
var side_progress: = 0

func claim_daily(day: String) -> int:
	if not valid_date(day) or day <= last_daily:
		return 0
	_record_login(day)
	last_daily = day
	balance += DAILY
	return DAILY

func _record_login(day: String) -> void :
	if day <= last_login:
		return
	var elapsed: = int(Time.get_unix_time_from_datetime_string(day)) - int(Time.get_unix_time_from_datetime_string(last_login)) if last_login != "" else 0
	login_streak = login_streak + 1 if elapsed == 86400 else 1
	last_login = day
	for id in SKINS:
		var required: = int(SKINS[id].get("login_days", 0))
		if required > 0 and login_streak >= required and not owned_skins.has(id):
			owned_skins.append(id)

static func valid_date(day: String) -> bool:
	if day.length() != 10 or day[4] != "-" or day[7] != "-":
		return false
	var digits: = day.replace("-", "")
	if digits.length() != 8:
		return false
	for character in digits:
		if character < "0" or character > "9":
			return false
	var year: = int(day.substr(0, 4))
	var month: = int(day.substr(5, 2))
	var date: = int(day.substr(8, 2))
	if year < 1 or month < 1 or month > 12 or date < 1:
		return false
	var days: = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0):
		days[1] = 29
	return date <= int(days[month - 1])

func skin_requirement(id: String) -> String:
	if not SKINS.has(id):
		return ""
	var required: = int(SKINS[id].get("login_days", 0))
	if required > 0:
		if owned_skins.has(id):
			return "连续登录 %d 天 · 已永久解锁" % required
		return "连续登录 %d 天 · 当前 %d/%d 天" % [required, mini(login_streak, required), required]
	return "初始免费拥有" if int(SKINS[id].price) == 0 else "永久兑换 · %s 金币" % str(SKINS[id].price)

func spend(practice: bool) -> bool:
	if practice:
		return true
	if balance < COST:
		return false
	balance -= COST
	inserted += 1
	daily_record("inserted")
	return true

func reward_front(practice: bool) -> void :
	if not practice:
		balance += COST
		collected += 1
		daily_record("collected")

func reward_side(_practice: bool) -> bool:

	return false

func unlocked_count() -> int:
	return mini(6, inserted / 50)

func claim_voice(transcript: String, day: = "") -> int:
	var normalized: = transcript.strip_edges().replace(" ", "").replace("。", "").replace("！", "").replace("!", "").replace("，", "").replace(",", "")
	if normalized not in ["国安是冠军", "国安永远争第一", "跟丫死磕"] or balance >= VOICE_BALANCE_LIMIT:
		return 0
	var date: String = Time.get_date_string_from_system() if day == "" else day
	if not valid_date(date) or date <= voice_last_daily or date < last_daily:
		return 0
	voice_last_daily = date
	balance += VOICE_RESCUE
	return VOICE_RESCUE

func buy_skin(id: String) -> bool:
	if not SKINS.has(id):
		return false
	if not owned_skins.has(id):
		if int(SKINS[id].get("login_days", 0)) > 0:
			return false
		var price: int = SKINS[id].price
		if balance < price:
			return false
		balance -= price
		owned_skins.append(id)
	equipped_skin = id
	return true

func to_dict() -> Dictionary:
	return {"voice_last_daily": voice_last_daily, "last_login": last_login, "login_streak": login_streak, "daily_date": daily_date, "daily_records": daily_records.duplicate(), "records": records.duplicate(), "equipped_title": equipped_title, "balance": balance, "last_daily": last_daily, "inserted": inserted, "collected": collected, "side_progress": side_progress, "owned_skins": owned_skins.duplicate(), "equipped_skin": equipped_skin}

func restore(data: Dictionary) -> bool:

	var candidate = get_script().new()
	if not candidate._restore_candidate(data):
		return false
	var validated: Dictionary = candidate.to_dict()
	for key in validated:
		set(key, validated[key])
	return true

func _restore_candidate(data: Dictionary) -> bool:
	for key in ["balance", "inserted", "collected", "side_progress"]:
		var value = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 1000000000 or float(value) != floor(float(value)):
			return false
	if data.side_progress >= 20 or not data.get("last_daily") is String:
		return false
	var date: String = data.last_daily
	if date != "" and not valid_date(date):
		return false
	var voice_day = data.get("voice_last_daily", "")
	if not voice_day is String or (voice_day != "" and not valid_date(voice_day)):
		return false


	if data.has("last_login") != data.has("login_streak"):
		return false
	var login_day = data.get("last_login", date)
	var streak = data.get("login_streak", 0 if date == "" else 1)
	if not login_day is String or (login_day != "" and not valid_date(login_day)):
		return false
	if not (streak is int or streak is float) or not is_finite(float(streak)) or streak < 0 or streak > 1000000000 or floor(float(streak)) != float(streak):
		return false
	if (login_day == "") != (streak == 0) or login_day != date:
		return false
	var skins = data.get("owned_skins", ["classic"])
	var equipped = data.get("equipped_skin", "classic")
	if not skins is Array or skins.size() > SKINS.size() or not skins.has("classic") or not equipped is String or not skins.has(equipped):
		return false
	var seen: Dictionary = {}
	for skin in skins:
		if not skin is String or not SKINS.has(skin) or seen.has(skin):
			return false
		seen[skin] = true
	var saved_records = data.get("records", {})
	var title = data.get("equipped_title", 0)
	if not saved_records is Dictionary or not (title is int or title is float) or not is_finite(float(title)) or floor(float(title)) != float(title) or not ((title >= 0 and title < TITLES.size()) or (title >= 100 and title < 100 + DAILY_TITLES.size())): return false
	for key in saved_records:
		if key not in ["jackpots", "best_prize", "towers", "custom", "restarts", "roulette"]: return false
		var value = saved_records[key]
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 1000000000000.0 or floor(float(value)) != float(value): return false
	var day = data.get("daily_date", "")
	var daily = data.get("daily_records", {})
	if not day is String or not daily is Dictionary: return false
	if day != "" and not valid_date(day): return false
	for key in daily:
		if key not in ["inserted", "collected", "jackpots", "best_prize", "towers", "custom", "restarts", "roulette"]: return false
		var value = daily[key]
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 1000000000000.0 or floor(float(value)) != float(value): return false
	daily_date = day
	daily_records = daily.duplicate()
	records = saved_records.duplicate()
	equipped_title = int(title)
	owned_skins = skins.duplicate()
	equipped_skin = equipped
	balance = int(data.balance)
	inserted = int(data.inserted)
	collected = int(data.collected)
	side_progress = int(data.side_progress)
	last_daily = date
	voice_last_daily = voice_day
	last_login = login_day
	login_streak = int(streak)
	ensure_title_day()
	if not has_title(equipped_title): return false
	return true
