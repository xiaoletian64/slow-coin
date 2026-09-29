extends Control
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("110c20"))
	for side in [0.0,1.0]:
		var c:=Vector2(size.x*side,size.y*0.32)
		for i in range(12,0,-1):
			var tint:=Color("b334d4") if side==0 else Color("1db8cb")
			tint.a=0.007
			draw_circle(c,45+i*17,tint)
	for y in range(0,int(size.y),30):
		draw_line(Vector2(0,y),Vector2(size.x,y),Color(0.55,0.3,0.8,0.025),1)
	for x in range(12,int(size.x),26):
		draw_circle(Vector2(x,5),1.2,Color("cc925b"))
