extends Control

signal update_requested
signal ui_requested
signal challenges_requested
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
signal title_selected(index: int)
var player_title: Label
signal restart_requested
signal restart_confirmed
signal settlement_requested
signal settlement_confirmed
var settlement_button: Button
signal coin_design_requested
signal shop_requested
signal skin_requested(id: String)
signal skin_preview_requested(id: String)
signal skin_preview_closed
var premium_layout: = false
var compact_slot_status: Label
var award_status: Label
var award_progress: ProgressBar
signal resume_requested
signal collection_requested
signal clear_requested
signal tower_test_requested
signal test_requested
signal help_requested

const Reel = preload("res://scripts/slot_reel.gd")
const I18n = preload("res://scripts/i18n.gd")
const Badge = preload("res://scripts/coin_badge.gd")
const CREAM: = Color("f9ebcd")
const MUTED: = Color("baa8c8")
const GOLD: = Color("efc377")
var drop_button: Button
var balance_label: Label
var collection_label: Label
var progress_bar: ProgressBar
var toast_label: Label
var toast_timer: = 0.0
var payout_label: Label
var payout_timer: = 0.0
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
var top_inset: = 0.0
var bottom_inset: = 0.0
var stage_rect: = Rect2()
var count_label: Label
var active_sound: = true
var active_haptic: = true
var active_music: = true
var test_enabled: = false
var slot_panel: Panel
var slot_labels: Array[Control] = []
var slot_status: Label

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font: = FontVariation.new()
	font.base_font = load("res://assets/fonts/NotoSansSC.ttf")
	font.variation_opentype = {2003265652: 500.0}
	var ui_theme: = Theme.new()
	ui_theme.default_font = font
	ui_theme.default_font_size = 15
	ui_theme.set_color("font_color", "Label", CREAM)
	ui_theme.set_color("font_color", "Button", CREAM)
	theme = ui_theme
	build()
	resized.connect(layout)
	layout()

func panel_style(color: String, radius: = 18, border: = "", width: = 1) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = Color(color)
	s.set_corner_radius_all(radius)
	if border != "":
		s.border_color = Color(border)
		s.set_border_width_all(width)
	return s

func label(parent: Node, text: String, font_size: = 16, color: = CREAM) -> Label:
	var node: = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

func button(parent: Node, text: String, action: Callable, gold: = false) -> Button:
	var node: = Button.new()
	node.text = text
	node.focus_mode = Control.FOCUS_NONE
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.add_theme_font_size_override("font_size", 15)
	node.add_theme_stylebox_override("normal", panel_style("f3bb59" if gold else "281d3c", 14, "f6d796" if gold else "594069"))
	node.add_theme_stylebox_override("hover", panel_style("f6d18c" if gold else "483052", 14, "f6d796" if gold else "526a70"))
	node.add_theme_stylebox_override("pressed", panel_style("be8b42" if gold else "375562", 14, "d5aa60"))
	node.add_theme_stylebox_override("disabled", panel_style("263e48", 14))
	if gold:
		for state in ["font_color", "font_hover_color", "font_pressed_color"]:
			node.add_theme_color_override(state, Color("273437"))
	node.pressed.connect( func(): ui_requested.emit())
	node.pressed.connect(action)
	parent.add_child(node)
	return node

func build() -> void :
	header = Control.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	var badge: = Badge.new()
	badge.position = Vector2(0, 6)
	badge.size = Vector2(33, 33)
	header.add_child(badge)
	var title: = label(header, I18n.app_title(), 21)
	title.position = Vector2(42, 1)
	player_title = label(header, I18n.title_name(0), 10, GOLD)
	player_title.position = Vector2(43, 29)
	var pause: = button(header, "Ⅱ", func(): pause_requested.emit())
	pause.name = "Pause"
	pause.size = Vector2(44, 44)
	pause.add_theme_font_size_override("font_size", 23)
	wallet_panel = Panel.new()
	wallet_panel.add_theme_stylebox_override("panel", panel_style("261a39", 18, "855277"))
	add_child(wallet_panel)
	label(wallet_panel, I18n.my_coins(), 12, MUTED).position = Vector2(18, 11)
	balance_label = label(wallet_panel, "1,500", 26)
	balance_label.position = Vector2(17, 29)
	daily_label = label(wallet_panel, I18n.daily_tag(), 9, Color("9bdcc7"))
	daily_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	daily_label.position.y = 18
	var saved: = label(wallet_panel, I18n.autosave_hint(), 11, MUTED)
	saved.name = "Saved"
	saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	saved.position.y = 46
	stage_label = button(self, I18n.stage_default(), func(): mechanism_requested.emit())
	stage_label.add_theme_font_size_override("font_size", 12)
	voice_button = button(self, I18n.voice_button_label(), func(): voice_requested.emit())
	voice_button.add_theme_font_size_override("font_size", 11)
	rhythm = label(self, I18n.free_rhythm(), 11, Color("91d0bb"))
	rhythm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slot_panel = Panel.new()
	slot_panel.add_theme_stylebox_override("panel", panel_style("27142e", 13, "d29268"))
	add_child(slot_panel)
	label(slot_panel, "JACKPOT", 14, GOLD).position = Vector2(12, 12)
	label(slot_panel, I18n.triple_bonus(), 12, Color("eebada")).position = Vector2(13, 37)
	for i in range(3):
		var frame: = Panel.new()
		frame.position = Vector2(106 + i * 56, 9)
		frame.size = Vector2(48, 72)
		frame.add_theme_stylebox_override("panel", panel_style("0a1e2b", 6, "58726e"))
		slot_panel.add_child(frame)
		var reel: = Reel.new()
		reel.size = Vector2(48, 72)
		reel.clip_contents = true
		frame.add_child(reel)
		slot_labels.append(reel)
	slot_status = label(slot_panel, I18n.slot_idle_hint(), 10, MUTED)
	slot_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slot_status.position = Vector2(282, 19)
	slot_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for i in range(4):
		var chip = Control.new()
		chip.name = "Prize" + str(i)
		slot_panel.add_child(chip)
		var symbol = Reel.new()
		symbol.size = Vector2(19, 25)
		symbol.symbol = ["cherry", "bell", "star", "seven"][i]
		chip.add_child(symbol)
		label(chip, ["58", "388", "2,999", "29,999"][i], 12, GOLD).position = Vector2(24, 3)
	compact_slot_status = label(self, "", 11, GOLD)
	compact_slot_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	compact_slot_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settlement_button = button(self, I18n.settle_button_label(), func(): settlement_requested.emit(), true)
	settlement_button.add_theme_font_size_override("font_size", 11)
	award_status = label(self, "", 12, GOLD)
	award_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	award_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	award_progress = ProgressBar.new()
	award_progress.show_percentage = false
	award_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	award_progress.add_theme_stylebox_override("background", panel_style("281a38", 4))
	award_progress.add_theme_stylebox_override("fill", panel_style("efc377", 4))
	add_child(award_progress)
	count_label = label(self, "", 11, MUTED)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer = Panel.new()
	footer.add_theme_stylebox_override("panel", panel_style("21162f", 23, "925585"))
	add_child(footer)
	label(footer, I18n.auto_swing(), 11, MUTED).position = Vector2(17, 15)
	aim_button = button(footer, I18n.aim_hold(), func(): aim_requested.emit())
	aim_button.position = Vector2(92, 8)
	aim_button.size = Vector2(160, 32)
	aim_button.add_theme_font_size_override("font_size", 13)
	pool_label = label(footer, I18n.front_pays(), 11, MUTED)
	pool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pool_label.position.y = 16
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.max_value = 20
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.add_theme_stylebox_override("background", panel_style("263e48", 3))
	progress_bar.add_theme_stylebox_override("fill", panel_style("89cdb7", 3))
	footer.add_child(progress_bar)
	drop_button = button(footer, I18n.drop_one(), func(): pass, true)
	drop_button.add_theme_font_size_override("font_size", 23)
	drop_button.button_down.connect( func(): drop_requested.emit())
	drop_button.position = Vector2(15, 56)
	var cost: = label(footer, I18n.tap_or_hold(), 11, Color("93aeb7"))
	cost.name = "Cost"
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost.position.y = 128
	var collection: = button(footer, I18n.collection_button(), func(): collection_requested.emit())
	collection.name = "Collection"
	practice_button = button(footer, I18n.practice_button(), func(): mode_requested.emit())
	var shop: = button(footer, I18n.skins_button(), func(): shop_requested.emit())
	shop.name = "Shop"
	var help: = button(footer, I18n.help_button(), func(): help_requested.emit())
	help.name = "Help"
	collection_label = label(self, "", 11, MUTED)
	collection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label = label(self, "", 14, CREAM)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal", panel_style("543356", 12, "57716f"))
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.visible = false
	payout_label = label(self, "", 26, GOLD)
	payout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	payout_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func layout() -> void :
	if header == null:
		return
	var width: = size.x
	var height: = size.y
	top_inset = 0
	bottom_inset = 0
	if OS.has_feature("mobile"):
		var safe: = DisplayServer.get_display_safe_area()
		var screen: = DisplayServer.screen_get_size()
		var scale_factor: = height / maxf(screen.y, 1)
		top_inset = maxf(0, safe.position.y * scale_factor - 12)
		bottom_inset = maxf(0, (screen.y - safe.end.y) * scale_factor)
	header.position = Vector2(12, 10 + top_inset)
	header.size = Vector2(width - 24, 48)
	header.get_node("Pause").position = Vector2(width - 63, 0)
	header.get_node("Pause").size = Vector2(40, 44)
	wallet_panel.position = Vector2(width - 198, 10 + top_inset)
	wallet_panel.size = Vector2(138, 46)
	wallet_panel.get_child(0).position = Vector2(10, 3)
	wallet_panel.get_child(0).add_theme_font_size_override("font_size", 9)
	balance_label.position = Vector2(10, 15)
	balance_label.add_theme_font_size_override("font_size", 23)
	daily_label.position = Vector2(60, 3)
	daily_label.size = Vector2(70, 17)
	wallet_panel.get_node("Saved").visible = false
	stage_label.position = Vector2(12, 64 + top_inset)
	stage_label.size = Vector2(168, 32)
	voice_button.position = Vector2(width - 186, 64 + top_inset)
	voice_button.size = Vector2(174, 32)
	rhythm.visible = false
	footer.position = Vector2(10, height - 161 - bottom_inset)
	footer.size = Vector2(width - 20, 140)
	footer.get_child(0).visible = false
	aim_button.position = Vector2(10, 10)
	aim_button.size = Vector2(128, 54)
	drop_button.position = Vector2(148, 10)
	drop_button.size = Vector2(footer.size.x - 158, 54)
	drop_button.add_theme_font_size_override("font_size", 21)
	pool_label.visible = false
	progress_bar.visible = false
	footer.get_node("Cost").position = Vector2(0, 71)
	footer.get_node("Cost").size.x = footer.size.x
	var nav_width: = (footer.size.x - 38) / 4
	var nav: Array = [footer.get_node("Collection"), footer.get_node("Shop"), practice_button, footer.get_node("Help")]
	for i in range(4):
		nav[i].position = Vector2(10 + i * (nav_width + 6), 98)
		nav[i].size = Vector2(nav_width, 33)
		nav[i].add_theme_font_size_override("font_size", 11)
	collection_label.position = Vector2(0, height - 19 - bottom_inset)
	collection_label.size = Vector2(width, 16)
	collection_label.add_theme_font_size_override("font_size", 9)
	slot_panel.position = Vector2(12, 104 + top_inset)
	slot_panel.size = Vector2(width - 24, 108)
	slot_status.size = Vector2(slot_panel.size.x - 294, 54)
	for i in range(4): slot_panel.get_node("Prize" + str(i)).position = Vector2(12 + i * (slot_panel.size.x - 24) / 4, 81)
	slot_panel.visible = not premium_layout
	compact_slot_status.visible = premium_layout
	compact_slot_status.position = Vector2(12, 100 + top_inset)
	compact_slot_status.size = Vector2(width - 24, 40)
	settlement_button.position = Vector2(width - 174, footer.position.y - 60)
	settlement_button.size = Vector2(158, 32)
	award_status.position = Vector2(16, footer.position.y - 64)
	award_status.size = Vector2(width - 184 if settlement_button.visible else width - 32, 40)
	award_progress.position = Vector2(50, footer.position.y - 34)
	award_progress.size = Vector2(width - 100, 6)
	var stage_top: = 100 if premium_layout else 216
	stage_rect = Rect2(0, stage_top + top_inset, width, maxf(180, footer.position.y - stage_top - 70 - top_inset))
	count_label.position = Vector2(0, footer.position.y - 18)
	count_label.size = Vector2(width, 16)
	count_label.add_theme_font_size_override("font_size", 9)
	toast_label.position = Vector2(32, (144 if premium_layout else 218) + top_inset)
	toast_label.size = Vector2(width - 64, 40)
	payout_label.position = Vector2(0, footer.position.y - 155)
	payout_label.size = Vector2(width, 40)

func update_aim(locked: bool) -> void :
	aim_button.text = I18n.aim_resume() if locked else I18n.aim_hold()
	aim_button.add_theme_stylebox_override("normal", panel_style("42625f" if locked else "281d3c", 10, "8ac4b2" if locked else "594069"))

func update_state(wallet, practice: bool, queued: int, _capacity: int, mechanism: = "classic") -> void :
	player_title.text = I18n.title_prefix() + wallet.title_name()
	balance_label.text = format_number(wallet.balance)
	stage_label.text = (I18n.practice_prefix() if practice else "") + I18n.stage_name(mechanism) + " ▾"
	practice_button.text = I18n.main_table_button() if practice else I18n.practice_button()
	footer.get_node("Cost").text = I18n.free_play_hint() if practice else I18n.tap_or_hold()
	pool_label.text = I18n.practice_mode() if practice else I18n.front_pays()
	progress_bar.value = 0 if practice else wallet.side_progress
	collection_label.text = I18n.footer_tagline()
	count_label.text = I18n.dispensing_wait(queued) if queued > 0 else I18n.swing_hint()
	drop_button.disabled = ( not practice and wallet.balance < 1)
	if not practice and wallet.balance < 1:
		count_label.text = I18n.broke_practice_hint()

static func format_number(value: int) -> String:
	var raw: = str(value)
	var output: = ""
	for i in range(raw.length()):
		if i > 0 and (raw.length() - i) % 3 == 0:
			output += ","
		output += raw[i]
	return output

func toast(text: String) -> void :
	toast_label.text = text
	toast_label.visible = true
	toast_timer = 3.2

func payout(amount: int) -> void :
	payout_label.text = "+ " + str(amount)
	payout_label.modulate.a = 1
	payout_timer = 1.1

func _process(delta: float) -> void :
	if toast_timer > 0:
		toast_timer -= delta
		toast_label.visible = toast_timer > 0
	if payout_timer > 0:
		payout_timer -= delta
		payout_label.modulate.a = minf(1, maxf(0, payout_timer * 2))

func close_modal() -> void :
	if is_instance_valid(modal):
		remove_child(modal)
		modal.queue_free()
	modal = null

func sheet(title: String, subtitle: String) -> VBoxContainer:
	close_modal()
	modal = Control.new()
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim: = ColorRect.new()
	dim.color = Color(0.015, 0.04, 0.06, 0.86)
	modal.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center: = CenterContainer.new()
	modal.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card: = PanelContainer.new()
	card.custom_minimum_size = Vector2(minf(size.x - 40, 430), 0)
	card.add_theme_stylebox_override("panel", panel_style("281a38", 24, "8f6187"))
	center.add_child(card)
	var margin: = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 23)
	card.add_child(margin)
	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	margin.add_child(content)
	label(content, title, 26)
	var sub: = label(content, subtitle, 13, MUTED)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = minf(size.x - 86, 384)
	return content

func show_pause(sound: bool, haptic: bool, music: = true) -> void :
	active_music = music
	active_sound = sound
	active_haptic = haptic
	var content: = sheet(I18n.pause_title(), I18n.pause_subtitle())
	var music_button: = button(content, I18n.music_label() + I18n.on_off(music), func():
		active_music = not active_music
		settings_changed.emit(active_sound, active_haptic, active_music)
		show_pause(active_sound, active_haptic, active_music))
	music_button.custom_minimum_size.y = 46
	var sound_button: = button(content, I18n.sound_label() + I18n.on_off(sound), func():
		active_sound = not active_sound
		settings_changed.emit(active_sound, active_haptic, active_music)
		show_pause(active_sound, active_haptic, active_music))
	sound_button.custom_minimum_size.y = 46
	var haptic_button: = button(content, I18n.haptic_label() + I18n.on_off(haptic), func():
		active_haptic = not active_haptic
		settings_changed.emit(active_sound, active_haptic, active_music)
		show_pause(active_sound, active_haptic, active_music))
	haptic_button.custom_minimum_size.y = 46
	var clear_button: = button(content, I18n.shake_clear_button(), func(): clear_requested.emit())
	clear_button.custom_minimum_size.y = 46
	var test_button: = button(content, I18n.test_target_button() + I18n.on_off(test_enabled), func(): test_requested.emit())
	test_button.custom_minimum_size.y = 46
	var tower_test: = button(content, I18n.test_tower_button(), func(): tower_test_requested.emit())
	tower_test.custom_minimum_size.y = 40
	button(content, I18n.restart_keep_button(), func(): restart_requested.emit()).custom_minimum_size.y = 40
	if OS.get_name() == "Android":
		button(content, I18n.update_menu_button() + preload("res://scripts/app_update.gd").VERSION_NAME, func(): update_requested.emit()).custom_minimum_size.y = 40
	var resume: = button(content, I18n.resume_button(), func(): resume_requested.emit(), true)
	resume.custom_minimum_size.y = 56
	label(content, I18n.leave_note(), 12, MUTED)

func show_help() -> void :
	var content: = sheet(I18n.help_title(), I18n.help_subtitle())
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, minf(410, size.y - 320))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var body: = label(scroll, I18n.help_body(), 13)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size.x = minf(size.x - 86, 384)
	var done: = button(content, I18n.help_done_button(), func(): resume_requested.emit(), true)
	done.custom_minimum_size.y = 52

func show_collection(wallet) -> void :
	var content: = sheet(I18n.collection_title(), I18n.collection_subtitle())
	button(content, I18n.daily_goals_button(), func(): challenges_requested.emit()).custom_minimum_size.y = 42
	button(content, I18n.title_wall_button(), func(): titles_requested.emit()).custom_minimum_size.y = 42
	var grid: = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)
	var colors: = ["efc377", "99d8c8", "ec9f87", "a8abd7", "dba663", "91bddf"]
	for i in range(6):
		var cell: = VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(cell)
		var badge: = Badge.new()
		badge.tint = Color(colors[i])
		badge.locked = i >= wallet.unlocked_count()
		badge.custom_minimum_size = Vector2(80, 75)
		cell.add_child(badge)
		var name_label: = label(cell, I18n.collection_name(i), 13)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var status: = label(cell, I18n.collected_tag() if i < wallet.unlocked_count() else I18n.drops_needed((i + 1) * 50), 11, MUTED)
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(content, I18n.collection_stats(wallet.inserted, wallet.unlocked_count()), 13, Color("a6d6c4"))
	var done: = button(content, I18n.resume_button(), func(): resume_requested.emit(), true)
	done.custom_minimum_size.y = 52

func update_slot(bonus, practice: bool, collected: = 0) -> void :
	settlement_button.visible = bonus.remaining > bonus.SETTLEMENT_THRESHOLD and not practice
	award_status.visible = collected > 0 or bonus.remaining > 0
	award_progress.visible = false
	award_status.size.x = size.x - (184 if settlement_button.visible else 32)
	award_status.text = I18n.award_status_line(I18n.award_run_label(practice), format_number(collected), format_number(bonus.remaining))
	for i in range(3):
		slot_labels[i].rows = bonus.column(i)
		slot_labels[i].lit = bonus.lit_rows(i)
		slot_labels[i].set_reel(str(bonus.reels[i]), bonus.spinning, bonus.elapsed, i)
	var state_text: String
	if bonus.spinning:
		state_text = I18n.reduced_odds_status() if bonus.reduced_draw else I18n.spinning_status()
	elif bonus.presentation > 0:
		state_text = I18n.prize_show_name(bonus.reward)
	elif bonus.remaining > 0:
		state_text = I18n.paying_chain(bonus.chain_used)
	else:
		state_text = I18n.practice_spin_status() if practice else I18n.hit_target_status()
	slot_status.text = state_text + "\n" + I18n.pending_spins(format_number(bonus.pending_spins))
	compact_slot_status.text = slot_status.text.replace("\n", " · ") + "\n58 / 388 / 2,999 / 29,999"

func show_shop(wallet) -> void :
	var content: = sheet(I18n.shop_title(), I18n.shop_subtitle())
	label(content, I18n.coins_available() + format_number(wallet.balance), 17, GOLD)
	label(content, I18n.login_streak_line(wallet.login_streak), 11, CREAM)
	button(content, I18n.custom_coin_button(), func(): coin_design_requested.emit()).custom_minimum_size.y = 40
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 14)
	var scrolling: = ScrollContainer.new()
	scrolling.custom_minimum_size = Vector2(0, minf(480, size.y - 300))
	content.add_child(scrolling)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scrolling.add_child(grid)
	var skin_order: Array = ["classic", "retro", "future", "royal", "aurora"]
	for id in wallet.SKINS:
		if not skin_order.has(id): skin_order.append(id)
	for id in skin_order:
		var skin: Dictionary = wallet.SKINS[id]
		var cell: = VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(cell)
		var preview: = Panel.new()
		preview.custom_minimum_size = Vector2(150, 120)
		preview.add_theme_stylebox_override("panel", panel_style(skin.body, 12, skin.trim, 3))
		cell.add_child(preview)
		var bed: = Panel.new()
		bed.position = Vector2(10, 12)
		bed.size = Vector2(130, 49)
		bed.add_theme_stylebox_override("panel", panel_style(skin.bed, 5))
		preview.add_child(bed)
		for i in range(4):
			var badge: = Badge.new()
			badge.position = Vector2(16 + i * 31, 21)
			badge.size = Vector2(25, 25)
			preview.add_child(badge)
		var thumbnail: String = "res://assets/art/cabinet-" + id + ".png"
		if id == "clown_deluxe": thumbnail = "res://assets/art/premium-preview.png"
		if ResourceLoader.exists(thumbnail):
			for fallback in preview.get_children(): fallback.visible = false
			var picture: = TextureRect.new()
			picture.texture = load(thumbnail)
			picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			picture.size = preview.custom_minimum_size
			preview.add_child(picture)
		var try_button: = button(cell, I18n.preview_button(), func(): skin_preview_requested.emit(id))
		try_button.custom_minimum_size.y = 28
		try_button.add_theme_font_size_override("font_size", 11)
		var name_label: = label(cell, I18n.skin_name(id), 14)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var owned: bool = wallet.owned_skins.has(id)
		var equipped: bool = wallet.equipped_skin == id
		var requirement: = label(cell, wallet.skin_requirement(id), 10, CREAM)
		requirement.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		requirement.custom_minimum_size = Vector2(150, 30)
		requirement.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var login_locked: bool = not owned and int(skin.get("login_days", 0)) > 0
		var text: String = I18n.in_use() if equipped else (I18n.equip_this() if owned else format_number(skin.price) + I18n.coins_to_redeem())
		if login_locked: text = I18n.login_locked_button()
		var choose: = button(cell, text, func(): skin_requested.emit(id), not owned)
		choose.add_theme_font_size_override("font_size", 11)
		choose.custom_minimum_size.y = 38
		choose.disabled = equipped or login_locked or ( not owned and wallet.balance < int(skin.price))
	var done: = button(content, I18n.back_to_table_button(), func(): resume_requested.emit())
	done.custom_minimum_size.y = 45

func show_voice(message: String, listening: = false) -> void :
	var content: = sheet(I18n.phrase_bonus_title(), message)
	var input: = LineEdit.new()
	input.placeholder_text = I18n.phrase_input_hint()
	input.max_length = 40
	input.custom_minimum_size.y = 48
	input.add_theme_font_size_override("font_size", 14)
	input.editable = not listening
	content.add_child(input)
	var submit: = button(content, I18n.confirm_phrase_button(), func():
		if not input.text.strip_edges().is_empty(): phrase_submitted.emit(input.text), true)
	submit.custom_minimum_size.y = 46
	submit.disabled = listening
	input.text_submitted.connect( func(text):
		if not text.strip_edges().is_empty(): phrase_submitted.emit(text))
	label(content, I18n.voice_help(), 13, GOLD)
	var privacy: = label(content, I18n.voice_privacy_note(), 11, MUTED)
	privacy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var mic: = button(content, I18n.listening_label() if listening else I18n.backup_mic_button(), func(): voice_start_requested.emit(), true)
	mic.custom_minimum_size.y = 52
	mic.disabled = listening
	var back: = button(content, I18n.cancel_back_button(), func(): resume_requested.emit())
	back.custom_minimum_size.y = 44

func show_mechanisms(current: String) -> void :
	var content: = sheet(I18n.mechanism_title(), I18n.mechanism_subtitle())
	for id in ["classic", "split", "sweep"]:
		var choose: = button(content, I18n.mechanism_name(id) + (I18n.current_tag() if id == current else ""), func(): mechanism_selected.emit(id), id == current)
		choose.custom_minimum_size.y = 49
		var description: = label(content, I18n.mechanism_description(id), 12, MUTED)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var back: = button(content, I18n.back_machine_button(), func(): resume_requested.emit())
	back.custom_minimum_size.y = 44

func show_skin_preview(skin_name: String) -> void :
	close_modal()
	modal = Control.new()
	modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var back: = button(modal, I18n.back_shop_prefix() + skin_name, func(): skin_preview_closed.emit(), true)
	back.position = Vector2(22, size.y - 154 - bottom_inset)
	back.size = Vector2(size.x - 44, 56)
	var note: = label(modal, I18n.preview_note(), 12, CREAM)
	note.position = Vector2(0, size.y - 90 - bottom_inset)
	note.size = Vector2(size.x, 30)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func show_settlement(owed: int, chances: int) -> void :
	var content: = sheet(I18n.settle_title(), I18n.settle_subtitle(format_number(owed), format_number(chances)))
	label(content, I18n.settle_body(), 13, CREAM)
	var start: = button(content, I18n.settle_accept_button(), func(): settlement_confirmed.emit(), true)
	start.custom_minimum_size.y = 48
	button(content, I18n.settle_keep_button(), func(): resume_requested.emit()).custom_minimum_size.y = 44
func show_settlement_result(owed: int, percent: int, received: int) -> void :
	var content: = sheet(I18n.wheel_title(), I18n.wheel_subtitle(format_number(owed)))
	var wheel = preload("res://scripts/settlement_wheel.gd").new()
	wheel.custom_minimum_size = Vector2(260, 240)
	content.add_child(wheel)
	var result: = label(content, I18n.wheel_spinning(), 18, GOLD)
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var done: = button(content, I18n.back_to_table_button(), func(): resume_requested.emit(), true)
	done.custom_minimum_size.y = 44
	wheel.spin(percent)
	var timer: = get_tree().create_timer(2.9, true)
	timer.timeout.connect( func():
		if is_instance_valid(result): result.text = I18n.wheel_result(percent, format_number(received)))

func show_restart() -> void :
	var content: = sheet(I18n.restart_title(), I18n.restart_subtitle())
	label(content, I18n.restart_body(), 13, CREAM)
	button(content, I18n.restart_confirm_button(), func(): restart_confirmed.emit(), true).custom_minimum_size.y = 48
	button(content, I18n.restart_stay_button(), func(): resume_requested.emit()).custom_minimum_size.y = 44

func show_titles(wallet, daily: = true) -> void :
	wallet.ensure_title_day()
	var content: = sheet(I18n.titles_title(daily), I18n.titles_subtitle(daily))
	var tabs: = HBoxContainer.new()
	content.add_child(tabs)
	button(tabs, I18n.daily_titles_tab(), func(): show_titles(wallet, true), daily).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button(tabs, I18n.permanent_titles_tab(), func(): show_titles(wallet, false), not daily).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, minf(440, size.y - 310))
	content.add_child(scroll)
	var list: = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	var catalog: Array = wallet.DAILY_TITLES if daily else wallet.TITLES
	for i in range(catalog.size()):
		var id: int = i + 100 if daily else i
		var data: Array = catalog[i]
		var unlocked: bool = wallet.has_title(id)
		var text: String = (I18n.worn_prefix() if wallet.equipped_title == id else (I18n.ready_prefix() if unlocked else I18n.locked_prefix())) + I18n.title_name(id)
		var item: = button(list, text, func(): title_selected.emit(id), unlocked)
		item.custom_minimum_size.y = 40
		item.disabled = not unlocked or wallet.equipped_title == id
		label(list, "%s %s / %s" % [I18n.category_label(data[0]), format_number(mini(wallet.title_progress(id), data[1])), format_number(data[1])], 11, MUTED)
	button(content, I18n.back_to_table_button(), func(): resume_requested.emit()).custom_minimum_size.y = 44

func show_challenges(challenges, thief) -> void :
	var content: = sheet(I18n.challenges_title(), I18n.challenges_subtitle())
	label(content, I18n.rank_stamp_line(challenges.rank_name(), challenges.completed_total), 17, GOLD)
	for i in range(challenges.RANK_STEPS.size()):
		if challenges.RANK_STEPS[i] > challenges.completed_total:
			label(content, I18n.next_rank_line(challenges.RANK_STEPS[i] - challenges.completed_total, I18n.rank_title(i)), 12, MUTED)
			break
	for row in challenges.rows():
		var card: = VBoxContainer.new()
		content.add_child(card)
		var heading: = label(card, I18n.challenge_title(row.kind) + (I18n.completed_tag() if row.completed else ""), 15)
		heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		heading.custom_minimum_size.x = minf(size.x - 86, 384)
		var progress: = ProgressBar.new()
		progress.max_value = row.target
		progress.value = row.progress
		progress.show_percentage = false
		progress.custom_minimum_size.y = 7
		card.add_child(progress)
		label(card, I18n.stamp_progress(row.progress, row.target), 12, MUTED)
	label(content, I18n.thief_stats_line(thief.repelled, thief.stolen_total), 13, MUTED)
	var note: = label(content, I18n.challenges_note(), 12, MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = minf(size.x - 86, 384)
	button(content, I18n.challenges_resume_button(), func(): resume_requested.emit(), true).custom_minimum_size.y = 48

func show_update(updater) -> void :
	var content: = sheet(I18n.update_title(), I18n.update_subtitle(updater.VERSION_NAME))
	var status: = label(content, updater.message, 16, GOLD)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size.x = minf(size.x - 86, 384)
	if not updater.release.is_empty() and updater.release.get("newer", false):
		label(content, I18n.new_version_line(updater.release.version, updater.release.size / 1048576.0), 14)
		var notes: = label(content, updater.release.notes, 13, MUTED)
		notes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notes.custom_minimum_size.x = minf(size.x - 86, 384)
		if updater.state == "available": button(content, I18n.download_button(), updater.download, true).custom_minimum_size.y = 48
	if updater.state == "ready": button(content, I18n.install_button(), updater.install, true).custom_minimum_size.y = 48
	if updater.state == "downloading":
		var bar: = ProgressBar.new()
		bar.value = updater.progress * 100
		bar.custom_minimum_size.y = 12
		content.add_child(bar)
	if updater.state in ["checking", "downloading"]:
		button(content, I18n.cancel_button(), updater.cancel).custom_minimum_size.y = 40
	else:
		button(content, I18n.recheck_button(), func(): updater.check()).custom_minimum_size.y = 40
	button(content, I18n.download_page_button(), func(): OS.shell_open(updater.BASE_URL)).custom_minimum_size.y = 40
	button(content, I18n.back_game_button(), func(): resume_requested.emit(), true).custom_minimum_size.y = 48
