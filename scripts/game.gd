extends Control

const Wallet = preload("res://scripts/wallet.gd")
const Store = preload("res://scripts/save_store.gd")
const Machine = preload("res://scripts/machine.gd")
const Hud = preload("res://scripts/hud.gd")
const Speech = preload("res://scripts/speech.gd")
const Bonus = preload("res://scripts/bonus.gd")
const Feedback = preload("res://scripts/feedback.gd")
var wallet = Wallet.new()
var bonus = Bonus.new()
var inactive_bonus = Bonus.new()
var store = Store.new()
var machine
var hud
var feedback
var preview_skin_id:=""
var speech
var harvest_total:=0
var coin_designer
var shake_detector
var jackpot_fx
var voice_waiting := false
var mechanism := "classic"
var viewport_container: SubViewportContainer
var viewport: SubViewport
var practice := false
var paused := false
var test_mode := false
var boards := {}
var save_elapsed := 0.0
var today := ""
var ready_to_save := false
var payout_amount := 0
var payout_elapsed := 0.0
var save_failed := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	if OS.get_cmdline_user_args().has("--test-mode"):
		test_mode = true
	var backdrop=preload("res://scripts/arcade_backdrop.gd").new()
	add_child(backdrop)
	viewport_container = SubViewportContainer.new()
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(viewport_container)
	viewport = SubViewport.new()
	viewport.size = Vector2i(450,450)
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	viewport_container.add_child(viewport)
	machine = Machine.new()
	machine.process_mode = Node.PROCESS_MODE_PAUSABLE
	viewport.add_child(machine)
	machine.coin_exited.connect(on_coin_exited)
	machine.coin_dropped.connect(on_coin_dropped)
	machine.spin_hit.connect(on_spin_hit)
	machine.coins_cleared.connect(func(count):hud.toast("台面超过 1,000 枚 · 随机消除 %d 枚" % count))
	machine.tower.prize_ready=func():return bonus.ready_coin_count()>=50
	machine.tower.prize_appeared.connect(func(count):
		for i in range(count):bonus.consume_coin())
	machine.tower.appeared.connect(func(count):
		if not practice:wallet.record("towers")
		hud.toast("旋风带来 %d 枚金币塔 · 推到前口才到账" % count)
		persist())
	speech=Speech.new()
	add_child(speech)
	speech.recognized.connect(on_voice_recognized)
	speech.failed.connect(on_voice_failed)
	speech.status.connect(func(message):
		if voice_waiting:hud.show_voice(message,true))
	feedback = Feedback.new()
	add_child(feedback)
	machine.metal_hit.connect(feedback.play_collision)
	machine.coin_landed.connect(func():feedback.play("drop"))
	hud = Hud.new()
	add_child(hud)
	jackpot_fx=preload("res://scripts/jackpot_fx.gd").new()
	hud.add_child(jackpot_fx)
	hud.drop_requested.connect(request_coin)
	hud.test_requested.connect(toggle_test_target)
	hud.tower_test_requested.connect(test_coin_tower)
	hud.clear_requested.connect(func():
		set_paused(false)
		clear_machine())
	shake_detector=preload("res://scripts/shake_detector.gd").new()
	shake_detector.process_mode=Node.PROCESS_MODE_PAUSABLE
	add_child(shake_detector)
	shake_detector.shaken.connect(clear_machine)
	hud.aim_requested.connect(func():
		if not paused:
			machine.toggle_aim()
			persist()
			refresh())
	hud.pause_requested.connect(open_pause)
	hud.resume_requested.connect(func():set_paused(false))
	hud.mode_requested.connect(switch_mode)
	hud.collection_requested.connect(func():
		set_paused(true)
		hud.show_collection(wallet))
	hud.help_requested.connect(func():
		set_paused(true)
		hud.show_help())
	hud.voice_requested.connect(open_voice)
	hud.voice_start_requested.connect(start_voice)
	hud.phrase_submitted.connect(submit_phrase)
	hud.mechanism_requested.connect(func():
		set_paused(true)
		hud.show_mechanisms(mechanism))
	hud.mechanism_selected.connect(change_mechanism)
	hud.shop_requested.connect(func():
		set_paused(true)
		hud.show_shop(wallet))
	coin_designer=preload("res://scripts/coin_designer.gd").new()
	coin_designer.hud=hud
	add_child(coin_designer)
	coin_designer.applied.connect(func(texture):
		machine.apply_coin_stamp(texture)
		if texture!=null:
			wallet.records["custom"]=1
			wallet.daily_record("custom")
		persist())
	machine.apply_coin_stamp(coin_designer.current)
	hud.titles_requested.connect(func():set_paused(true);hud.show_titles(wallet))
	hud.title_selected.connect(func(index):
		if wallet.equip_title(index):persist();refresh();hud.show_titles(wallet,index>=100))
	hud.restart_requested.connect(func():set_paused(true);hud.show_restart())
	hud.restart_confirmed.connect(restart_round)
	hud.settlement_requested.connect(open_settlement)
	hud.settlement_confirmed.connect(settle_pending_prizes)
	hud.coin_design_requested.connect(func():set_paused(true);coin_designer.show_editor())
	hud.skin_preview_requested.connect(preview_skin)
	hud.skin_preview_closed.connect(close_skin_preview)
	hud.skin_requested.connect(func(id):
		if wallet.buy_skin(id):
			preview_skin_id=""
			apply_visual_skin(wallet.equipped_skin)
			persist()
			refresh()
			hud.show_shop(wallet))
	hud.settings_changed.connect(func(sound,haptic,music):
		feedback.enabled=sound
		feedback.haptics=haptic
		feedback.set_music_enabled(music)
		persist())
	resized.connect(layout)
	layout()
	var saved: Dictionary = {} if test_mode else store.read()
	if not saved.is_empty():
		wallet.restore(saved.wallet)
		boards = saved.boards
		mechanism=saved.get("mechanism","classic")
		if mechanism not in ["classic","split","sweep"]:mechanism="classic"
		practice = saved.get("practice",false) == true
		feedback.enabled = saved.settings.get("sound",true) == true
		feedback.haptics = saved.settings.get("haptic",true) == true
		feedback.set_music_enabled(saved.settings.get("music",true) == true)
		if saved.get("bonus") is Dictionary:
			(inactive_bonus if practice else bonus).restore(saved.bonus)
		if saved.get("practice_bonus") is Dictionary:
			(bonus if practice else inactive_bonus).restore(saved.practice_bonus)
	machine.configure_mechanism(mechanism)
	var board = boards.get(board_key(),{})
	machine.restore(board if board is Dictionary else {})
	apply_visual_skin(wallet.equipped_skin)
	ready_to_save = true
	grant_daily()
	persist()
	refresh()
	if store.recovered:
		hud.toast("已从备份恢复进度")

func layout() -> void:
	if hud == null:
		return
	hud.size = size
	hud.layout()
	viewport_container.position = hud.stage_rect.position
	var pixel_scale:float=clampf(float(DisplayServer.window_get_size().x)/maxf(size.x,1),1.5,2.0)
	viewport_container.scale=Vector2.ONE/pixel_scale
	viewport_container.size = hud.stage_rect.size*pixel_scale

func board_key() -> String:
	return ("practice" if mechanism=="classic" else mechanism+"_practice") if practice else mechanism

func grant_daily() -> void:
	wallet.ensure_title_day()
	today = Time.get_date_string_from_system()
	if wallet.claim_daily(today)>0:
		hud.toast("今日补给 +5,000，慢慢玩")
		persist()
		refresh()

func request_coin() -> void:
	if paused or save_failed:
		return
	if not machine.accepts_coin():
		hud.toast("投币队列已达上限，请稍后再投")
		return
	var unlocked: int = wallet.unlocked_count()
	if not wallet.spend(practice):
		hud.toast("金币用完啦，免费练习台随时开放")
		return
	machine.enqueue(machine.lane)
	machine.tower.input_accepted()
	feedback.pulse()
	if wallet.unlocked_count()>unlocked:
		hud.toast("收藏解锁 · " + Wallet.COLLECTION_NAMES[unlocked])
	persist()
	refresh()

func on_coin_dropped() -> void:
	persist()
	refresh()

func on_spin_hit() -> void:
	var accepted:bool=bonus.trigger()
	hud.toast(("命中移动靶！" + ("抽奖已排队" if bonus.pending_spins>0 else "三滚轮启动")) if accepted else "本轮连抽已达 2 次 · 继续推币收奖")
	persist()
	refresh()

func on_coin_exited(front: bool, _at: Vector3, _is_bonus := false) -> void:
	if front:
		wallet.reward_front(practice)
		feedback.play("drop")
		if not practice:
			harvest_total+=Wallet.COST
			payout_amount += Wallet.COST
			payout_elapsed = 0.3
			hud.payout(payout_amount)
	persist()
	refresh()

func refresh() -> void:
	jackpot_fx.sync_state(bonus.reward,bonus.presentation)
	hud.update_aim(machine.aim_locked)
	hud.update_slot(bonus,practice,harvest_total)
	machine.premium.sync_bonus(bonus,practice)
	hud.update_state(wallet,practice,machine.pending.size(),machine.pending.size()+machine.coins.get_child_count(),mechanism)

func switch_mode() -> void:
	if paused:
		return
	# Synchronous detach means no old-board exit callback can reward the new mode.
	boards[board_key()] = machine.snapshot()
	practice = not practice
	machine.test_target=false
	hud.test_enabled=false
	var previous_bonus=bonus
	bonus=inactive_bonus
	inactive_bonus=previous_bonus
	machine.configure_mechanism(mechanism)
	var board = boards.get(board_key(),{})
	machine.restore(board if board is Dictionary else {})
	payout_amount = 0
	persist()
	refresh()
	hud.toast("自由练习 · 无限投币，不计收益" if practice else "已回到正式台，接着慢慢推")

func open_pause() -> void:
	set_paused(true)
	hud.show_pause(feedback.enabled,feedback.haptics,feedback.music_enabled)

func set_paused(value: bool) -> void:
	if not value and not preview_skin_id.is_empty():
		preview_skin_id=""
		apply_visual_skin(wallet.equipped_skin)
	paused = value
	get_tree().paused = value
	if not value:
		if voice_waiting:
			speech.stop()
			voice_waiting=false
		hud.close_modal()
		if save_failed:
			persist()
		grant_daily()
	else:
		persist()

func make_save() -> Dictionary:
	var current_boards := boards.duplicate(true)
	current_boards[board_key()] = machine.snapshot()
	return {"version":1,"wallet":wallet.to_dict(),"boards":current_boards,"practice":practice,"mechanism":mechanism,"settings":{"sound":feedback.enabled,"haptic":feedback.haptics,"music":feedback.music_enabled},"bonus":(inactive_bonus if practice else bonus).to_dict(),"practice_bonus":(bonus if practice else inactive_bonus).to_dict()}

func persist() -> void:
	if not ready_to_save or test_mode:
		return
	if not store.write(make_save()):
		save_failed = true
		hud.toast(store.error_message + "，投币暂时停用")
	else:
		save_failed = false

func _physics_process(delta: float) -> void:
	if not ready_to_save or paused:
		return
	if bonus.tick(delta):
		var prize:int=bonus.reward
		if prize>0:
			if not practice:
				wallet.record("jackpots")
				wallet.records["best_prize"]=maxi(int(wallet.records.get("best_prize",0)),prize)
			jackpot_fx.celebrate(prize)
			hud.toast("三同中奖！%s 枚，演出结束后开始吐币" % Hud.format_number(prize))
		else:
			hud.toast("这次未连成三同，继续慢慢推")
		persist()
		refresh()
	if bonus.can_dispense() and bonus.dispense_clock<=0 and machine.clearing<=0:
		var tower_waiting:bool=bonus.remaining>=500 and bonus.ready_coin_count()>=50 and machine.tower.request_prize_tower()
		if not tower_waiting and machine.pinboard_count()<32:
			var coin=machine.dispense_bonus(bonus.payout_tier(),bonus.payout_emitted())
			if coin!=null:
				bonus.consume_coin()
				persist()
				refresh()
		bonus.dispense_clock=[0.08,0.06,0.06,0.05][bonus.payout_tier()]
	jackpot_fx.sync_state(bonus.reward,bonus.presentation)
	hud.update_slot(bonus,practice,harvest_total)
	machine.premium.sync_bonus(bonus,practice)

func _process(delta: float) -> void:
	if jackpot_fx!=null:position=Vector2.ZERO if paused else jackpot_fx.screen_shake()
	if not ready_to_save:
		return
	save_elapsed += delta
	if save_elapsed >= 2:
		save_elapsed = 0
		if Time.get_date_string_from_system() != today:
			grant_daily()
		if not paused:
			persist()
	if payout_elapsed>0:
		payout_elapsed-=delta
		if payout_elapsed<=0:
			payout_amount=0

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_SPACE:
			request_coin()
		elif event.keycode==KEY_ESCAPE:
			if paused:
				set_paused(false)
			else:
				open_pause()

func _notification(what: int) -> void:
	if not ready_to_save:
		return
	if coin_designer!=null and coin_designer.picking:
		if what==NOTIFICATION_APPLICATION_PAUSED:persist()
		return
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if voice_waiting:
			persist()
			if what==NOTIFICATION_APPLICATION_PAUSED and OS.get_name()=="iOS":
				speech.stop()
				voice_waiting=false
		else:
			open_pause()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		grant_daily()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		open_pause()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		persist()
		get_tree().quit()

func change_mechanism(id: String) -> void:
	if id not in ["classic","split","sweep"]:return
	boards[board_key()]=machine.snapshot()
	mechanism=id
	machine.configure_mechanism(id)
	machine.restore(boards.get(board_key(),{}))
	apply_visual_skin(wallet.equipped_skin)
	persist()
	refresh()
	set_paused(false)

func open_voice() -> void:
	set_paused(true)
	hud.show_voice("可直接输入，也可用输入法语音。确认文字后领取。")

func start_voice() -> void:
	if practice:
		hud.show_voice("请先返回正式机台，再领取语音补给。")
		return
	voice_waiting=true
	hud.show_voice("正在请求麦克风，请留意系统权限提示…",true)
	speech.listen()

func on_voice_recognized(text: String) -> void:
	if not voice_waiting:return
	voice_waiting=false
	var amount:int=wallet.claim_voice(text)
	persist()
	refresh()
	hud.show_voice("识别：%s\n+%s 金币已到账！" % [text,Hud.format_number(amount)] if amount>0 else "识别：%s\n口令不匹配，或该口令需要余额低于 500。" % text)

func on_voice_failed(message: String) -> void:
	voice_waiting=false
	hud.show_voice(message)

func toggle_test_target() -> void:
	var enabled:bool=not machine.test_target
	set_paused(false)
	if enabled and not practice:switch_mode()
	machine.test_target=enabled
	hud.test_enabled=enabled
	hud.toast("测试开启：按投币必进中间洞，奖币也走此路径" if enabled else "测试关闭：恢复真实碰撞")


func clear_machine() -> void:
	if paused:return
	if machine.shakeable_count()==0:
		hud.toast("上方钉板没有金币需要震落 · 下方推盘照常运行")
		return
	machine.shake_clear()
	if OS.has_feature("mobile") and feedback.haptics:Input.vibrate_handheld(100,0.5)
	hud.toast("正在震落上方卡币 · 下方推盘照常运行")
	persist()

func submit_phrase(text: String) -> void:
	if practice:
		hud.show_voice("请先返回正式台，再领取口令补给。")
		return
	if voice_waiting:speech.stop()
	voice_waiting=true
	DisplayServer.virtual_keyboard_hide()
	on_voice_recognized(text)

func apply_visual_skin(id:String)->void:
	machine.apply_skin(id)
	hud.premium_layout=id=="clown_deluxe"
	layout()
	machine.premium.sync_bonus(bonus,practice)
func preview_skin(id:String)->void:
	if not wallet.SKINS.has(id):return
	set_paused(true)
	preview_skin_id=id
	apply_visual_skin(id)
	hud.show_skin_preview(wallet.SKINS[id].name)
func close_skin_preview()->void:
	preview_skin_id=""
	apply_visual_skin(wallet.equipped_skin)
	hud.show_shop(wallet)

func test_coin_tower()->void:
	set_paused(false)
	if not practice:switch_mode()
	machine.tower.inputs=12
	machine.tower.wait_seconds=0
	hud.toast("练习测试 · 有空位时旋风带来金币塔")
	persist()

func open_settlement()->void:
	if practice or bonus.remaining<=bonus.SETTLEMENT_THRESHOLD:return
	set_paused(true)
	hud.show_settlement(bonus.remaining,bonus.pending_spins+(1 if bonus.spinning else 0))
func settle_pending_prizes()->void:
	if practice or not paused or bonus.remaining<=bonus.SETTLEMENT_THRESHOLD:return
	var old_bonus:Dictionary=bonus.to_dict()
	var old_tower:Dictionary=machine.tower.snapshot()
	var old_wallet:Dictionary=wallet.to_dict()
	var old_balance:int=wallet.balance
	var owed:int=bonus.remaining
	var percent:=randi_range(1,90)
	var received:int=bonus.settle_pending(percent)
	wallet.balance+=received
	wallet.record("roulette")
	machine.tower.cancel_prize()
	persist()
	if save_failed:
		bonus.restore(old_bonus)
		machine.tower.restore(old_tower)
		wallet.restore(old_wallet)
		hud.toast("保存失败，本次未结算，请重试")
		return
	refresh()
	hud.show_settlement_result(bonus.last_settlement_pool,percent,received)

func restart_round()->void:
	if not paused:return
	if not practice:wallet.record("restarts")
	var paid_inputs:int=machine.pending.size()
	if not practice:wallet.balance+=paid_inputs*Wallet.COST
	machine.restore({})
	machine.test_target=false
	hud.test_enabled=false
	harvest_total=0
	payout_amount=0
	payout_elapsed=0
	hud.payout_label.visible=false
	boards[board_key()]=machine.snapshot()
	persist()
	set_paused(false)
	refresh()
	hud.toast("新一局已开始 · 金币与未发奖励保留")
