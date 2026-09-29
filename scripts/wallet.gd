extends RefCounted

const COST := 1
const DAILY := 5000
const COLLECTION_NAMES := ["初见黄铜", "海盐薄荷", "落日珊瑚", "午夜星光", "琥珀回声", "银河漫游"]
const SKINS := {
	"classic":{"name":"皇家蓝金","price":0,"body":"17324d","bed":"243742","trim":"bca36b"},
	"mint":{"name":"海盐薄荷","price":1500,"body":"39776e","bed":"285c5b","trim":"a9e3ce"},
	"sakura":{"name":"落日樱粉","price":3500,"body":"915b6c","bed":"634553","trim":"edbfa4"},
	"clown_deluxe":{"name":"经典小丑·典藏","price":12000,"body":"173f96","bed":"89969e","trim":"d5bd73"},
	"galaxy":{"name":"午夜银河","price":6000,"body":"4b4981","bed":"302f55","trim":"b7a9e6"}
}
const TITLES := [
 ["初来乍到","inserted",0],["试试手气","inserted",1],["街机常客","inserted",50],["落币如雨","inserted",500],["千投不倦","inserted",2000],
 ["第一桶金","collected",1],["百币入袋","collected",100],["收币能手","collected",1000],["万币归仓","collected",10000],["金潮收藏家","collected",50000],
 ["好运开张","jackpots",1],["好事成双","jackpots",10],["中奖专业户","jackpots",100],
 ["毛球捕手","best_prize",58],["火腿搭档","best_prize",388],["金币车车长","best_prize",2999],["金库来客","best_prize",29999],
 ["高塔见习生","towers",1],["推塔高手","towers",10],["换装玩家","skins",2],["机台收藏家","skins",5],
 ["私人铸币师","custom",1],["再来一局","restarts",1],["轮盘体验官","roulette",1]
]
const DAILY_TITLES := [
 ["今日开张","inserted",1],["随手十投","inserted",10],["今日落币手","inserted",50],["今日收币员","collected",10],
 ["今日小丰收","collected",100],["今日好运","jackpots",1],["今日推塔手","towers",1],["今日铸币师","custom",1]
]
var daily_date:=""
var daily_records:Dictionary={}
var records:Dictionary={}
var equipped_title:=0
func ensure_title_day()->void:
	var date:=Time.get_date_string_from_system()
	if daily_date==date:return
	daily_date=date
	daily_records={}
	if equipped_title>=100:equipped_title=0
func daily_record(key:String,amount:=1)->void:
	ensure_title_day()
	daily_records[key]=int(daily_records.get(key,0))+amount
func title_name()->String:
	ensure_title_day()
	return str(DAILY_TITLES[equipped_title-100][0]) if equipped_title>=100 else str(TITLES[equipped_title][0])
func title_progress(index:int)->int:
	ensure_title_day()
	if index>=100 and index<100+DAILY_TITLES.size():return int(daily_records.get(DAILY_TITLES[index-100][1],0))
	if index<0 or index>=TITLES.size():return 0
	match TITLES[index][1]:
		"inserted":return inserted
		"collected":return collected
		"skins":return owned_skins.size()
	return int(records.get(TITLES[index][1],0))
func has_title(index:int)->bool:
	if index>=100 and index<100+DAILY_TITLES.size():return title_progress(index)>=int(DAILY_TITLES[index-100][2])
	return index>=0 and index<TITLES.size() and title_progress(index)>=int(TITLES[index][2])
func equip_title(index:int)->bool:
	if not has_title(index):return false
	equipped_title=index
	return true
func record(key:String,amount:=1)->void:
	records[key]=int(records.get(key,0))+amount
	daily_record(key,amount)

var owned_skins: Array = ["classic"]
var equipped_skin := "classic"
var balance := 10000
var last_daily := ""
var inserted := 0
var collected := 0
var side_progress := 0

func claim_daily(day: String) -> int:
	if day.length() != 10 or day <= last_daily:
		return 0
	last_daily = day
	balance += DAILY
	return DAILY

func spend(practice: bool) -> bool:
	if practice:
		return true
	if balance < COST:
		return false
	balance -= COST
	inserted += 1
	daily_record("inserted")
	return true

func reward_front(practice: bool) -> void:
	if not practice:
		balance += COST
		collected += 1
		daily_record("collected")

func reward_side(_practice: bool) -> bool:
	# Side losses do not pay. Retain the method for old callers/save compatibility.
	return false

func unlocked_count() -> int:
	return mini(6, inserted / 50)

func claim_voice(transcript: String) -> int:
	var normalized:=transcript.strip_edges().replace(" ","").replace("。","").replace("！","").replace("!","").replace("，","").replace(",","")
	var amount:=0
	if normalized=="国安是冠军" and balance<500: amount=5000
	elif normalized=="山东驴": amount=2000
	elif normalized=="跟丫死磕": amount=1992
	balance+=amount
	return amount

func buy_skin(id: String) -> bool:
	if not SKINS.has(id):
		return false
	if not owned_skins.has(id):
		var price: int = SKINS[id].price
		if balance<price:
			return false
		balance-=price
		owned_skins.append(id)
	equipped_skin=id
	return true

func to_dict() -> Dictionary:
	return {"daily_date":daily_date,"daily_records":daily_records.duplicate(),"records":records.duplicate(),"equipped_title":equipped_title,"balance":balance, "last_daily":last_daily, "inserted":inserted, "collected":collected, "side_progress":side_progress,"owned_skins":owned_skins.duplicate(),"equipped_skin":equipped_skin}

func restore(data: Dictionary) -> bool:
	for key in ["balance", "inserted", "collected", "side_progress"]:
		var value = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 1000000000 or float(value) != floor(float(value)):
			return false
	if data.side_progress >= 20 or not data.get("last_daily") is String:
		return false
	var date: String = data.last_daily
	if date != "" and (date.length() != 10 or not date.replace("-", "").is_valid_int()):
		return false
	var skins = data.get("owned_skins",["classic"])
	var equipped = data.get("equipped_skin","classic")
	if not skins is Array or skins.size()>SKINS.size() or not skins.has("classic") or not equipped is String or not skins.has(equipped):
		return false
	var seen:Dictionary={}
	for skin in skins:
		if not skin is String or not SKINS.has(skin) or seen.has(skin):
			return false
		seen[skin]=true
	var saved_records=data.get("records",{})
	var title=data.get("equipped_title",0)
	if not saved_records is Dictionary or not (title is int or title is float) or not is_finite(float(title)) or floor(float(title))!=float(title) or not ((title>=0 and title<TITLES.size()) or (title>=100 and title<100+DAILY_TITLES.size())):return false
	for key in saved_records:
		if key not in ["jackpots","best_prize","towers","custom","restarts","roulette"]:return false
		var value=saved_records[key]
		if not (value is int or value is float) or not is_finite(float(value)) or value<0 or value>1e12 or floor(float(value))!=float(value):return false
	var day=data.get("daily_date","")
	var daily=data.get("daily_records",{})
	if not day is String or not daily is Dictionary:return false
	if day!="" and (day.length()!=10 or not day.replace("-","").is_valid_int()):return false
	for key in daily:
		if key not in ["inserted","collected","jackpots","best_prize","towers","custom","restarts","roulette"]:return false
		var value=daily[key]
		if not (value is int or value is float) or not is_finite(float(value)) or value<0 or value>1e12 or floor(float(value))!=float(value):return false
	daily_date=day
	daily_records=daily.duplicate()
	records=saved_records.duplicate()
	equipped_title=int(title)
	owned_skins=skins.duplicate()
	equipped_skin=equipped
	balance = int(data.balance)
	inserted = int(data.inserted)
	collected = int(data.collected)
	side_progress = int(data.side_progress)
	last_daily = date
	ensure_title_day()
	if not has_title(equipped_title):return false
	return true
