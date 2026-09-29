extends Control

signal drop_requested
signal aim_requested
signal pause_requested
signal mode_requested
signal settings_changed(sound: bool, haptic: bool, music: bool)
signal voice_requested
signal phrase_submitted(text: String)
signal voice_start_requested
signal mechanism_requested
signal mechanism_selected(id: String)
signal titles_requested
signal title_selected(index:int)
var player_title:Label
signal restart_requested
signal restart_confirmed
signal settlement_requested
signal settlement_confirmed
var settlement_button:Button
signal coin_design_requested
signal shop_requested
signal skin_requested(id: String)
signal skin_preview_requested(id:String)
signal skin_preview_closed
var premium_layout:=false
var compact_slot_status:Label
var award_status:Label
var award_progress:ProgressBar
signal resume_requested
signal collection_requested
signal clear_requested
signal tower_test_requested
signal test_requested
signal help_requested

const Reel = preload("res://scripts/slot_reel.gd")
const Badge = preload("res://scripts/coin_badge.gd")
const CREAM := Color("f9ebcd")
const MUTED := Color("baa8c8")
const GOLD := Color("efc377")
var drop_button: Button
var balance_label: Label
var collection_label: Label
var progress_bar: ProgressBar
var toast_label: Label
var toast_timer := 0.0
var payout_label: Label
var payout_timer := 0.0
var header: Control
var wallet_panel: Panel
var footer: Panel
var stage_label: Button
var voice_button: Button
var rhythm: Label
var pool_label: Label
var aim_button: Button
var practice_button: Button
var daily_label: Label
var modal: Control
var top_inset := 0.0
var bottom_inset := 0.0
var stage_rect := Rect2()
var count_label: Label
var active_sound := true
var active_haptic := true
var active_music := true
var test_enabled := false
var slot_panel: Panel
var slot_labels: Array[Control] = []
var slot_status: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font := FontVariation.new()
	font.base_font = load("res://assets/fonts/NotoSansSC.ttf")
	font.variation_opentype = {2003265652:500.0}
	var ui_theme := Theme.new()
	ui_theme.default_font = font
	ui_theme.default_font_size = 15
	ui_theme.set_color("font_color","Label",CREAM)
	ui_theme.set_color("font_color","Button",CREAM)
	theme = ui_theme
	build()
	resized.connect(layout)
	layout()

func panel_style(color: String, radius := 18, border := "", width := 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(color)
	s.set_corner_radius_all(radius)
	if border != "":
		s.border_color = Color(border)
		s.set_border_width_all(width)
	return s

func label(parent: Node, text: String, font_size := 16, color := CREAM) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",color)
	parent.add_child(node)
	return node

func button(parent: Node, text: String, action: Callable, gold := false) -> Button:
	var node := Button.new()
	node.text = text
	node.focus_mode = Control.FOCUS_NONE
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.add_theme_font_size_override("font_size",15)
	node.add_theme_stylebox_override("normal",panel_style("f3bb59" if gold else "281d3c",14,"f6d796" if gold else "594069"))
	node.add_theme_stylebox_override("hover",panel_style("f6d18c" if gold else "483052",14,"f6d796" if gold else "526a70"))
	node.add_theme_stylebox_override("pressed",panel_style("be8b42" if gold else "375562",14,"d5aa60"))
	node.add_theme_stylebox_override("disabled",panel_style("263e48",14))
	if gold:
		for state in ["font_color","font_hover_color","font_pressed_color"]:
			node.add_theme_color_override(state,Color("273437"))
	node.pressed.connect(action)
	parent.add_child(node)
	return node

func build() -> void:
	header = Control.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	var badge := Badge.new()
	badge.position = Vector2(0,6)
	badge.size = Vector2(33,33)
	header.add_child(badge)
	var title := label(header,"金潮街机",21)
	title.position = Vector2(42,1)
	player_title = label(header,"初来乍到",10,GOLD)
	player_title.position = Vector2(43,29)
	var pause := button(header,"Ⅱ",func():pause_requested.emit())
	pause.name = "Pause"
	pause.size = Vector2(44,44)
	pause.add_theme_font_size_override("font_size",23)
	wallet_panel = Panel.new()
	wallet_panel.add_theme_stylebox_override("panel",panel_style("261a39",18,"855277"))
	add_child(wallet_panel)
	label(wallet_panel,"我的金币",12,MUTED).position = Vector2(18,11)
	balance_label = label(wallet_panel,"15,000",26)
	balance_label.position = Vector2(17,29)
	daily_label = label(wallet_panel,"+5,000 / 日",9,Color("9bdcc7"))
	daily_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	daily_label.position.y = 18
	var saved := label(wallet_panel,"自动保存 · 放心离开",11,MUTED)
	saved.name = "Saved"
	saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	saved.position.y = 46
	stage_label = button(self,"经典双层  ▾",func():mechanism_requested.emit())
	stage_label.add_theme_font_size_override("font_size",12)
	voice_button=button(self,"口令补给 · 语音/输入",func():voice_requested.emit())
	voice_button.add_theme_font_size_override("font_size",11)
	rhythm = label(self,"●  自由节奏",11,Color("91d0bb"))
	rhythm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slot_panel=Panel.new()
	slot_panel.add_theme_stylebox_override("panel",panel_style("27142e",13,"d29268"))
	add_child(slot_panel)
	label(slot_panel,"JACKPOT",14,GOLD).position=Vector2(12,12)
	label(slot_panel,"小丑连线奖",12,Color("eebada")).position=Vector2(13,37)
	for i in range(3):
		var frame:=Panel.new()
		frame.position=Vector2(106+i*56,9)
		frame.size=Vector2(48,72)
		frame.add_theme_stylebox_override("panel",panel_style("0a1e2b",6,"58726e"))
		slot_panel.add_child(frame)
		var reel:=Reel.new()
		reel.size=Vector2(48,72)
		reel.clip_contents=true
		frame.add_child(reel)
		slot_labels.append(reel)
	slot_status=label(slot_panel,"穿过移动靶抽奖",10,MUTED)
	slot_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	slot_status.position=Vector2(282,19)
	slot_status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	for i in range(4):
		var chip=Control.new()
		chip.name="Prize"+str(i)
		slot_panel.add_child(chip)
		var symbol=Reel.new()
		symbol.size=Vector2(19,25)
		symbol.symbol=["cherry","bell","star","seven"][i]
		chip.add_child(symbol)
		label(chip,["58","388","2,999","29,999"][i],12,GOLD).position=Vector2(24,3)
	compact_slot_status=label(self,"",11,GOLD)
	compact_slot_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	compact_slot_status.mouse_filter=Control.MOUSE_FILTER_IGNORE
	settlement_button=button(self,"待出太多？轮盘结算",func():settlement_requested.emit(),true)
	settlement_button.add_theme_font_size_override("font_size",11)
	award_status=label(self,"",14,GOLD)
	award_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	award_status.mouse_filter=Control.MOUSE_FILTER_IGNORE
	award_progress=ProgressBar.new()
	award_progress.show_percentage=false
	award_progress.mouse_filter=Control.MOUSE_FILTER_IGNORE
	award_progress.add_theme_stylebox_override("background",panel_style("281a38",4))
	award_progress.add_theme_stylebox_override("fill",panel_style("efc377",4))
	add_child(award_progress)
	count_label = label(self,"",11,MUTED)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer = Panel.new()
	footer.add_theme_stylebox_override("panel",panel_style("21162f",23,"925585"))
	add_child(footer)
	label(footer,"自动摆杆",11,MUTED).position = Vector2(17,15)
	aim_button = button(footer,"Ⅱ  停在这里",func():aim_requested.emit())
	aim_button.position = Vector2(92,8)
	aim_button.size = Vector2(160,32)
	aim_button.add_theme_font_size_override("font_size",13)
	pool_label = label(footer,"前口落币计奖",11,MUTED)
	pool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pool_label.position.y = 16
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.max_value = 20
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.add_theme_stylebox_override("background",panel_style("263e48",3))
	progress_bar.add_theme_stylebox_override("fill",panel_style("89cdb7",3))
	footer.add_child(progress_bar)
	drop_button = button(footer,"投  一  枚     ↓",func():pass,true)
	drop_button.add_theme_font_size_override("font_size",23)
	drop_button.button_down.connect(func():drop_requested.emit())
	drop_button.position = Vector2(15,56)
	var cost := label(footer,"1 金币 / 枚  ·  按一下，落一枚",11,Color("93aeb7"))
	cost.name = "Cost"
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.position.y = 128
	var collection := button(footer,"◇  收藏册",func():collection_requested.emit())
	collection.name = "Collection"
	practice_button = button(footer,"∞  练习台",func():mode_requested.emit())
	var shop := button(footer,"◈ 换皮肤",func():shop_requested.emit())
	shop.name="Shop"
	var help := button(footer,"?  怎么玩",func():help_requested.emit())
	help.name = "Help"
	collection_label = label(self,"",11,MUTED)
	collection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label = label(self,"",14,CREAM)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal",panel_style("543356",12,"57716f"))
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.visible = false
	payout_label = label(self,"",26,GOLD)
	payout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	payout_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func layout() -> void:
	if header == null:
		return
	var width := size.x
	var height := size.y
	top_inset = 0
	bottom_inset = 0
	if OS.has_feature("mobile"):
		var safe := DisplayServer.get_display_safe_area()
		var screen := DisplayServer.screen_get_size()
		var scale_factor := height/maxf(screen.y,1)
		top_inset = maxf(0,safe.position.y*scale_factor-12)
		bottom_inset = maxf(0,(screen.y-safe.end.y)*scale_factor)
	header.position = Vector2(12,10+top_inset)
	header.size = Vector2(width-24,48)
	header.get_node("Pause").position = Vector2(width-63,0)
	header.get_node("Pause").size=Vector2(40,44)
	wallet_panel.position = Vector2(width-198,10+top_inset)
	wallet_panel.size = Vector2(138,46)
	wallet_panel.get_child(0).position=Vector2(10,3)
	wallet_panel.get_child(0).add_theme_font_size_override("font_size",9)
	balance_label.position=Vector2(10,15)
	balance_label.add_theme_font_size_override("font_size",23)
	daily_label.position=Vector2(60,3)
	daily_label.size=Vector2(70,17)
	wallet_panel.get_node("Saved").visible=false
	stage_label.position=Vector2(12,64+top_inset)
	stage_label.size=Vector2(168,32)
	voice_button.position=Vector2(width-186,64+top_inset)
	voice_button.size=Vector2(174,32)
	rhythm.visible=false
	footer.position = Vector2(10,height-161-bottom_inset)
	footer.size = Vector2(width-20,140)
	footer.get_child(0).visible=false
	aim_button.position=Vector2(10,10)
	aim_button.size=Vector2(128,54)
	drop_button.position=Vector2(148,10)
	drop_button.size = Vector2(footer.size.x-158,54)
	drop_button.add_theme_font_size_override("font_size",21)
	pool_label.visible=false
	progress_bar.visible=false
	footer.get_node("Cost").position=Vector2(0,71)
	footer.get_node("Cost").size.x = footer.size.x
	var nav_width := (footer.size.x-38)/4
	var nav: Array = [footer.get_node("Collection"),footer.get_node("Shop"),practice_button,footer.get_node("Help")]
	for i in range(4):
		nav[i].position = Vector2(10+i*(nav_width+6),98)
		nav[i].size = Vector2(nav_width,33)
		nav[i].add_theme_font_size_override("font_size",11)
	collection_label.position = Vector2(0,height-19-bottom_inset)
	collection_label.size = Vector2(width,16)
	collection_label.add_theme_font_size_override("font_size",9)
	slot_panel.position=Vector2(12,104+top_inset)
	slot_panel.size=Vector2(width-24,108)
	slot_status.size=Vector2(slot_panel.size.x-294,54)
	for i in range(4):slot_panel.get_node("Prize"+str(i)).position=Vector2(12+i*(slot_panel.size.x-24)/4,81)
	slot_panel.visible=not premium_layout
	compact_slot_status.visible=premium_layout
	compact_slot_status.position=Vector2(12,100+top_inset)
	compact_slot_status.size=Vector2(width-24,40)
	settlement_button.position=Vector2(width/2-90,footer.position.y-110)
	settlement_button.size=Vector2(180,30)
	award_status.position=Vector2(16,footer.position.y-76)
	award_status.size=Vector2(width-32,40)
	award_progress.position=Vector2(50,footer.position.y-34)
	award_progress.size=Vector2(width-100,6)
	var stage_top:=100 if premium_layout else 216
	stage_rect = Rect2(0,stage_top+top_inset,width,maxf(180,footer.position.y-stage_top-4-top_inset))
	count_label.position = Vector2(0,footer.position.y-18)
	count_label.size = Vector2(width,16)
	count_label.add_theme_font_size_override("font_size",9)
	toast_label.position = Vector2(32,(144 if premium_layout else 218)+top_inset)
	toast_label.size = Vector2(width-64,40)
	payout_label.position = Vector2(0,footer.position.y-155)
	payout_label.size = Vector2(width,40)

func update_aim(locked: bool) -> void:
	aim_button.text = "↔  继续摆动" if locked else "Ⅱ  停在这里"
	aim_button.add_theme_stylebox_override("normal",panel_style("42625f" if locked else "281d3c",10,"8ac4b2" if locked else "594069"))

func update_state(wallet, practice: bool, queued: int, _capacity: int, mechanism := "classic") -> void:
	player_title.text="称号 · "+wallet.title_name()
	balance_label.text = format_number(wallet.balance)
	stage_label.text = ("练习 · " if practice else "") + {"classic":"经典双层","split":"交错双推板","sweep":"扫杆联动"}[mechanism]+" ▾"
	practice_button.text = "↩  正式台" if practice else "∞  练习台"
	footer.get_node("Cost").text = "无限免费投币 · 不计金币与收藏" if practice else "1 金币 / 枚  ·  按一下，落一枚"
	pool_label.text = "练习模式" if practice else "前口落币计奖"
	progress_bar.value = 0 if practice else wallet.side_progress
	collection_label.text = "无内购  ·  自动保存  ·  随时歇一会儿"
	count_label.text = "逐枚出币中 · 等待 %d 枚" % queued if queued>0 else "摆杆自动游走，也可以停在喜欢的位置"
	drop_button.disabled = (not practice and wallet.balance<1)
	if not practice and wallet.balance<1:
		count_label.text = "金币用完啦，去免费练习台继续玩"

static func format_number(value: int) -> String:
	var raw := str(value)
	var output := ""
	for i in range(raw.length()):
		if i>0 and (raw.length()-i)%3==0:
			output += ","
		output += raw[i]
	return output

func toast(text: String) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_timer = 3.2

func payout(amount: int) -> void:
	payout_label.text = "+ " + str(amount)
	payout_label.modulate.a = 1
	payout_timer = 1.1

func _process(delta: float) -> void:
	if toast_timer>0:
		toast_timer -= delta
		toast_label.visible = toast_timer>0
	if payout_timer>0:
		payout_timer -= delta
		payout_label.modulate.a = minf(1,maxf(0,payout_timer*2))

func close_modal() -> void:
	if is_instance_valid(modal):
		remove_child(modal)
		modal.queue_free()
	modal = null

func sheet(title: String, subtitle: String) -> VBoxContainer:
	close_modal()
	modal = Control.new()
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0.015,0.04,0.06,0.86)
	modal.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	modal.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(minf(size.x-40,430),0)
	card.add_theme_stylebox_override("panel",panel_style("281a38",24,"8f6187"))
	center.add_child(card)
	var margin := MarginContainer.new()
	for side in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,23)
	card.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",16)
	margin.add_child(content)
	label(content,title,26)
	var sub := label(content,subtitle,13,MUTED)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = minf(size.x-86,384)
	return content

func show_pause(sound: bool, haptic: bool, music := true) -> void:
	active_music = music
	active_sound = sound
	active_haptic = haptic
	var content := sheet("歇一会儿", "台面已经暂停，金币和进度都已保存。")
	var music_button := button(content,"背景音乐："+("开启" if music else "关闭"),func():
		active_music=not active_music
		settings_changed.emit(active_sound,active_haptic,active_music)
		show_pause(active_sound,active_haptic,active_music))
	music_button.custom_minimum_size.y=46
	var sound_button := button(content,"金币音效："+("开启" if sound else "关闭"),func():
		active_sound = not active_sound
		settings_changed.emit(active_sound,active_haptic,active_music)
		show_pause(active_sound,active_haptic,active_music))
	sound_button.custom_minimum_size.y = 46
	var haptic_button := button(content,"触感："+("开启" if haptic else "关闭"),func():
		active_haptic = not active_haptic
		settings_changed.emit(active_sound,active_haptic,active_music)
		show_pause(active_sound,active_haptic,active_music))
	haptic_button.custom_minimum_size.y = 46
	var clear_button:=button(content,"摇一摇 · 只震落上方卡币",func():clear_requested.emit())
	clear_button.custom_minimum_size.y=46
	var test_button:=button(content,"测试：必进中间洞 · "+("开启" if test_enabled else "关闭"),func():test_requested.emit())
	test_button.custom_minimum_size.y=46
	var tower_test:=button(content,"测试：金币塔 · 练习台",func():tower_test_requested.emit())
	tower_test.custom_minimum_size.y=40
	button(content,"重开一局 · 金币保留",func():restart_requested.emit()).custom_minimum_size.y=40
	var resume := button(content,"继续慢慢推",func():resume_requested.emit(),true)
	resume.custom_minimum_size.y = 56
	label(content,"随时离开，不会错过任何限时奖励。",12,MUTED)

func show_help() -> void:
	var content := sheet("一枚一枚，慢慢来", "经典推币机 · 玩法与金币规则")
	var scroll:=ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(0,minf(410,size.y-320))
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var body := label(scroll,"① 双导杆自动左右摆动，币沿两杆之间下滑。\n    点「停在这里」固定，随时恢复摆动。\n② 按一下按钮，投入一枚金币。\n③ 推板自动来回，把金币推向前沿。\n\n正面掉落：每枚返还 1 金币。\n侧边掉落：不计奖励。\n每天首次进入自动补给 5,000 金币。\n正式投币每满 50 次解锁一枚纪念章。\n金币还可以永久兑换机台皮肤。\n经典小丑·典藏：12,000 金币，可免费预览。\n持续投币时偶尔出现旋风金币塔：每层 5 枚、共 10 层。\n盘满会延后，塔币也要推出前口才到账。\n\n投币穿过移动靶启动免费老虎机：\n三横线、两斜线：同图案连成线中奖。\n三樱桃 58（18%）· 三铃铛 388（1.8%）\n三星星 2,999（0.18%）· 三个7 29,999（0.02%）\n其余 80% 不中奖（本游戏暂定概率）。\n正在中奖或派奖时，连抽降为 5%：\n58 枚 4.8%，388 枚 0.2%，不出更大档。\n每轮中奖最多连抽 2 次，连中也不重置。\n期间积攒的连抽保留降档规则，轮盘结算同样适用。\n普通奖币从联动短导杆出币口快速落下。\n奖金按枚实际落到推盘，前口推出才到账。\n出币和抽奖同时进行，奖币过靶也可连奖。\n累计待出较多时分批生成 50 枚金币塔。\n累计待出超过 200 枚，可自选轮盘结算：\n剩余抽奖按原概率算出，再将总待出按 1%～90% 折算到账。\n会结清待出和抽奖机会，钱包及台面币保留。\n\n没有内购、广告或连续签到。\n练习台无限投币，不计正式收益。",13)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size.x = minf(size.x-86,384)
	var done := button(content,"知道啦，去推金币",func():resume_requested.emit(),true)
	done.custom_minimum_size.y = 52

func show_collection(wallet) -> void:
	var content := sheet("慢慢攒的小美好", "永久收藏 · 每投 50 枚，留下一枚纪念章")
	button(content,"称号墙 · 每日 / 永久",func():titles_requested.emit()).custom_minimum_size.y=42
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",10)
	grid.add_theme_constant_override("v_separation",14)
	content.add_child(grid)
	var colors := ["efc377","99d8c8","ec9f87","a8abd7","dba663","91bddf"]
	for i in range(6):
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(cell)
		var badge := Badge.new()
		badge.tint = Color(colors[i])
		badge.locked = i>=wallet.unlocked_count()
		badge.custom_minimum_size = Vector2(80,75)
		cell.add_child(badge)
		var name_label := label(cell,wallet.COLLECTION_NAMES[i],13)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var status := label(cell,"已收藏" if i<wallet.unlocked_count() else "%d 次投币" % ((i+1)*50),11,MUTED)
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(content,"已投 %d 枚  ·  已收藏 %d / 6" % [wallet.inserted,wallet.unlocked_count()],13,Color("a6d6c4"))
	var done := button(content,"继续慢慢推",func():resume_requested.emit(),true)
	done.custom_minimum_size.y = 52

func update_slot(bonus, practice: bool, collected:=0) -> void:
	settlement_button.visible=bonus.remaining>bonus.SETTLEMENT_THRESHOLD and not practice
	award_status.visible=collected>0 or bonus.remaining>0
	award_progress.visible=false
	award_status.text="前口实际收回 %s 枚%s\n累计待出 %s 枚 · 推落才到账" % [format_number(collected)," · 本次游玩" if not practice else " · 练习不计收益",format_number(bonus.remaining)]
	for i in range(3):
		slot_labels[i].rows=bonus.column(i)
		slot_labels[i].lit=bonus.lit_rows(i)
		slot_labels[i].set_reel(str(bonus.reels[i]),bonus.spinning,bonus.elapsed,i)
	var state_text:String
	if bonus.spinning:
		state_text="连抽降档 58 / 388" if bonus.reduced_draw else "抽奖中 · 出币继续"
	elif bonus.presentation>0:
		state_text="小猫抓毛球" if bonus.reward==58 else ("小狗吃火腿" if bonus.reward==388 else "大奖演出中")
	elif bonus.remaining>0:
		state_text="派奖中 · 连抽 %d/2" % bonus.chain_used
	else:
		state_text="练习 · 命中也抽奖" if practice else "命中移动靶抽奖"
	slot_status.text=state_text+"\n待抽 %s 次" % format_number(bonus.pending_spins)
	compact_slot_status.text=slot_status.text.replace("\n"," · ")+"\n58 / 388 / 2,999 / 29,999"

func show_shop(wallet) -> void:
	var content := sheet("给机台换件新衣", "游戏金币永久兑换 · 只改变外观，不影响收益")
	label(content,"可用金币  " + format_number(wallet.balance),17,GOLD)
	button(content,"定制金币 · 选择自己的图片",func():coin_design_requested.emit()).custom_minimum_size.y=40
	var grid:=GridContainer.new()
	grid.columns=2
	grid.add_theme_constant_override("h_separation",12)
	grid.add_theme_constant_override("v_separation",14)
	var scrolling:=ScrollContainer.new()
	scrolling.custom_minimum_size=Vector2(0,minf(480,size.y-300))
	content.add_child(scrolling)
	grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scrolling.add_child(grid)
	for id in wallet.SKINS:
		var skin:Dictionary=wallet.SKINS[id]
		var cell:=VBoxContainer.new()
		cell.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		grid.add_child(cell)
		var preview:=Panel.new()
		preview.custom_minimum_size=Vector2(150,74)
		preview.add_theme_stylebox_override("panel",panel_style(skin.body,12,skin.trim,3))
		cell.add_child(preview)
		var bed:=Panel.new()
		bed.position=Vector2(10,12)
		bed.size=Vector2(130,49)
		bed.add_theme_stylebox_override("panel",panel_style(skin.bed,5))
		preview.add_child(bed)
		for i in range(4):
			var badge:=Badge.new()
			badge.position=Vector2(16+i*31,21)
			badge.size=Vector2(25,25)
			preview.add_child(badge)
		if id=="clown_deluxe" and ResourceLoader.exists("res://assets/art/premium-preview.png"):
			var picture:=TextureRect.new()
			picture.texture=load("res://assets/art/premium-preview.png")
			picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			picture.size=preview.custom_minimum_size
			preview.add_child(picture)
		var try_button:=button(cell,"免费预览",func():skin_preview_requested.emit(id))
		try_button.custom_minimum_size.y=28
		try_button.add_theme_font_size_override("font_size",11)
		var name_label:=label(cell,skin.name,14)
		name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		var owned:bool=wallet.owned_skins.has(id)
		var equipped:bool=wallet.equipped_skin==id
		var text:String="使用中" if equipped else ("换上这款" if owned else format_number(skin.price)+" 金币兑换")
		var choose:=button(cell,text,func():skin_requested.emit(id),not owned)
		choose.add_theme_font_size_override("font_size",11)
		choose.custom_minimum_size.y=38
		choose.disabled=equipped or (not owned and wallet.balance<int(skin.price))
	var done:=button(content,"回到推币台",func():resume_requested.emit())
	done.custom_minimum_size.y=45

func show_voice(message: String, listening := false) -> void:
	var content:=sheet("口令补给",message)
	var input:=LineEdit.new()
	input.placeholder_text="点此输入，或用输入法麦克风说口令"
	input.max_length=40
	input.custom_minimum_size.y=48
	input.add_theme_font_size_override("font_size",14)
	input.editable=not listening
	content.add_child(input)
	var submit:=button(content,"确认口令 · 领取金币",func():
		if not input.text.strip_edges().is_empty():phrase_submitted.emit(input.text),true)
	submit.custom_minimum_size.y=46
	submit.disabled=listening
	input.text_submitted.connect(func(text):
		if not text.strip_edges().is_empty():phrase_submitted.emit(text))
	label(content,"国安是冠军  →  +5,000（余额低于500）\n山东驴  →  +2,000（随时可用）\n跟丫死磕  →  +1,992（随时可用）",13,GOLD)
	var privacy:=label(content,"输入法语音：点键盘上的麦克风，识别后确认领取。\n备用麦克风入口需授权和系统识别服务，不保存录音。",11,MUTED)
	privacy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var mic:=button(content,"正在识别…" if listening else "备用：游戏内麦克风",func():voice_start_requested.emit(),true)
	mic.custom_minimum_size.y=52
	mic.disabled=listening
	var back:=button(content,"取消 / 回到机台",func():resume_requested.emit())
	back.custom_minimum_size.y=44

func show_mechanisms(current: String) -> void:
	var content:=sheet("选一台，换种手感", "三种真实物理机构 · 各自保留台面与进度")
	var names={"classic":"经典双层推板","split":"左右交错双推板","sweep":"推板 + 摆动扫杆"}
	var descriptions={"classic":"整面推板往复，适合观察前沿、精准投币。","split":"左右推板错峰推进，抓住两侧不同的时机。","sweep":"前方扫杆来回扫动，与推板一起搅动币堆。"}
	for id in names:
		var choose:=button(content,names[id]+("  ·  当前" if id==current else ""),func():mechanism_selected.emit(id),id==current)
		choose.custom_minimum_size.y=49
		var description:=label(content,descriptions[id],12,MUTED)
		description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var back:=button(content,"回到机台",func():resume_requested.emit())
	back.custom_minimum_size.y=44

func show_skin_preview(skin_name:String)->void:
	close_modal()
	modal=Control.new()
	modal.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var back:=button(modal,"返回商店 · "+skin_name,func():skin_preview_closed.emit(),true)
	back.position=Vector2(22,size.y-154-bottom_inset)
	back.size=Vector2(size.x-44,56)
	var note:=label(modal,"外观预览 · 台面已暂停 · 不扣金币",12,CREAM)
	note.position=Vector2(0,size.y-90-bottom_inset)
	note.size=Vector2(size.x,30)
	note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

func show_settlement(owed:int,chances:int)->void:
	var content:=sheet("待出金币 · 一把结算","累计待出 %s 枚 · 另有 %s 次抽奖\n先按原规则结算剩余抽奖，再随机折算 0.01～0.90 倍" % [format_number(owed),format_number(chances)])
	label(content,"结果直接到账。待出金币、正在开奖和排队机会全部结清。\n钱包现有金币、台面实体币保留。",13,CREAM)
	var start:=button(content,"接受折算 · 全部结算",func():settlement_confirmed.emit(),true)
	start.custom_minimum_size.y=48
	button(content,"继续抽奖和出币",func():resume_requested.emit()).custom_minimum_size.y=44
func show_settlement_result(owed:int,percent:int,received:int)->void:
	var content:=sheet("轮盘结算","已结算待出 %s 枚" % format_number(owed))
	var wheel=preload("res://scripts/settlement_wheel.gd").new()
	wheel.custom_minimum_size=Vector2(260,240)
	content.add_child(wheel)
	var result:=label(content,"轮盘转动中…",18,GOLD)
	result.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var done:=button(content,"回到推币台",func():resume_requested.emit(),true)
	done.custom_minimum_size.y=44
	wheel.spin(percent)
	var timer:=get_tree().create_timer(2.9,true)
	timer.timeout.connect(func():
		if is_instance_valid(result):result.text="× %.2f · 已到账 %s 枚" % [percent/100.0,format_number(received)])

func show_restart()->void:
	var content:=sheet("重开一局？","台面金币重新铺设，摆杆和推板回到初始位置。")
	label(content,"钱包金币、皮肤、定制币面保留。\n未发奖励与抽奖次数继续，尚未落出的付费投币退回。",13,CREAM)
	button(content,"确认重开",func():restart_confirmed.emit(),true).custom_minimum_size.y=48
	button(content,"继续当前这局",func():resume_requested.emit()).custom_minimum_size.y=44

func show_titles(wallet,daily:=true)->void:
	wallet.ensure_title_day()
	var content:=sheet("每日称号" if daily else "永久称号","当天解锁，当天佩戴 · 次日重置，无连续签到" if daily else "长期累计解锁 · 永久保留")
	var tabs:=HBoxContainer.new()
	content.add_child(tabs)
	button(tabs,"每日称号 · 8",func():show_titles(wallet,true),daily).size_flags_horizontal=Control.SIZE_EXPAND_FILL
	button(tabs,"永久称号 · 24",func():show_titles(wallet,false),not daily).size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var scroll:=ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(0,minf(440,size.y-310))
	content.add_child(scroll)
	var list:=VBoxContainer.new()
	list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",8)
	scroll.add_child(list)
	var labels={"inserted":"正式投币","collected":"前口实收","jackpots":"中奖","best_prize":"单次中奖","towers":"见到金币塔","skins":"拥有皮肤","custom":"定制币面","restarts":"重开一局","roulette":"轮盘结算"}
	var catalog:Array=wallet.DAILY_TITLES if daily else wallet.TITLES
	for i in range(catalog.size()):
		var id:int=i+100 if daily else i
		var data:Array=catalog[i]
		var unlocked:bool=wallet.has_title(id)
		var text:String=("佩戴中 · " if wallet.equipped_title==id else ("可佩戴 · " if unlocked else "未解锁 · "))+data[0]
		var item:=button(list,text,func():title_selected.emit(id),unlocked)
		item.custom_minimum_size.y=40
		item.disabled=not unlocked or wallet.equipped_title==id
		label(list,"%s %s / %s" % [labels[data[1]],format_number(mini(wallet.title_progress(id),data[2])),format_number(data[2])],11,MUTED)
	button(content,"回到推币台",func():resume_requested.emit()).custom_minimum_size.y=44
