extends Control
const I18n = preload("res://scripts/i18n.gd")
signal repel_requested
var repel_button: Button
var title: Label
var detail: Label
var timer: ProgressBar
var elapsed: = 0.0
func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 4
	var panel: = Panel.new()
	panel.show_behind_parent = true
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: = StyleBoxFlat.new()
	style.bg_color = Color("172d38f5")
	style.border_color = Color("d5a870")
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	title = Label.new()
	title.text = I18n.thief_panel_title()
	title.position = Vector2(76, 10)
	title.add_theme_font_size_override("font_size", 18)
	add_child(title)
	detail = Label.new()
	detail.position = Vector2(76, 38)
	detail.add_theme_font_size_override("font_size", 12)
	add_child(detail)
	repel_button = Button.new()
	repel_button.position = Vector2(76, 65)
	repel_button.focus_mode = Control.FOCUS_NONE
	repel_button.pressed.connect( func(): repel_requested.emit())
	add_child(repel_button)
	timer = ProgressBar.new()
	timer.show_percentage = false
	timer.max_value = 5.0
	timer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timer.position = Vector2(14, 116)
	add_child(timer)
	visible = false
func sync_state(event, available: bool) -> void :
	visible = available and event.active()
	if not visible: return
	elapsed = event.WARNING_SECONDS - event.remaining
	detail.text = I18n.thief_detail(event.remaining, event.pending_loss)
	repel_button.text = I18n.thief_repel_button(event.taps)
	repel_button.size = Vector2(size.x - 90, 40)
	timer.size = Vector2(size.x - 28, 4)
	timer.value = event.remaining
	queue_redraw()
func _draw() -> void :
	if not visible: return
	var center: = Vector2(39, 53 + sin(elapsed * 7) * 2)
	draw_circle(center, 24, Color("0a151f"))
	draw_circle(center + Vector2(0, 7), 17, Color("c1a087"))
	draw_style_box(_mask(), Rect2(center - Vector2(20, 7), Vector2(40, 15)))
	for x in [-9, 9]:
		draw_circle(center + Vector2(x, 0), 3, Color("e2f2e6"))
		draw_circle(center + Vector2(x + 1, 0), 1.5, Color("13202a"))
	draw_arc(center + Vector2(0, 9), 6, 0.1, PI - 0.1, 16, Color("493e40"), 2, true)
	draw_circle(center + Vector2(3, 37), 16, Color("967348"))
	draw_line(center + Vector2(-8, 26), center + Vector2(10, 26), Color("edc880"), 3, true)
	draw_string(get_theme_default_font(), center + Vector2(-3, 43), "¢", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f2d09b"))
func _mask() -> StyleBoxFlat:
	var mask: = StyleBoxFlat.new()
	mask.bg_color = Color("283542")
	mask.set_corner_radius_all(5)
	return mask
