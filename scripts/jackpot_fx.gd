extends Control
# Original vector characters, articulated directly in-game (not a static popup).
const DURATION:=3.4
var clock:=0.0
var amount:=0
var caption:Label
var reward_label:Label
var panel_center:=Vector2.ZERO
var scene_scale:=1.0
func _ready()->void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption=Label.new()
	reward_label=Label.new()
	for node in [caption,reward_label]:
		node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		node.mouse_filter=Control.MOUSE_FILTER_IGNORE
		node.add_theme_color_override("font_color",Color("fff0c8"))
		add_child(node)
	caption.add_theme_font_size_override("font_size",21)
	reward_label.add_theme_font_size_override("font_size",32)
	visible=false
func celebrate(prize:int,remaining:=DURATION)->void:
	amount=prize
	clock=remaining
	visible=clock>0
	update_layout()
	queue_redraw()
func sync_state(prize:int,remaining:float)->void:
	amount=prize
	clock=remaining
	visible=clock>0
	if visible:update_layout()
	queue_redraw()
func update_layout()->void:
	scene_scale=minf(1.0,(size.x-24)/410)
	panel_center=Vector2(size.x/2,size.y*0.46)
	var age:=DURATION-clock
	caption.position=Vector2(0,panel_center.y-142*scene_scale)
	caption.size=Vector2(size.x,34)
	if amount==58:
		caption.text="抓到毛球啦！" if age>=1.7 else "小猫发现了毛球…"
	elif amount==388:
		caption.text="啊呜，吃到火腿啦！" if age>=1.7 else "小狗闻到了香味…"
	elif amount in [2888,2999]:caption.text="金币车爆开啦！" if age>=1.7 else "地震了！金币车来了…"
	else:caption.text="金币宝库全开！" if age>=1.7 else "超级宝库正在开启…"
	reward_label.position=Vector2(0,panel_center.y+97*scene_scale)
	reward_label.size=Vector2(size.x,48)
	reward_label.text="%s 金币" % amount if age>=1.7 else "…"
	reward_label.modulate.a=clampf((age-1.55)*4,0,1)
func oval(at:Vector2,radius:Vector2,color:Color)->void:
	var points:=PackedVector2Array()
	for i in range(48):
		var a:float=i*TAU/48
		points.append(at+Vector2(cos(a)*radius.x,sin(a)*radius.y))
	draw_colored_polygon(points,color)
func line(points:Array,color:Color,width:float)->void:
	draw_polyline(PackedVector2Array(points),color,width,true)
func _draw()->void:
	if clock<=0:return
	var age:=DURATION-clock
	var fade:=minf(1,clock*3)
	var panel:=StyleBoxFlat.new()
	panel.bg_color=Color("213955") if amount==58 else Color("50354e")
	panel.border_color=Color("e6bf79")
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(24)
	draw_style_box(panel,Rect2(panel_center-Vector2(205,161)*scene_scale,Vector2(410,322)*scene_scale))
	draw_set_transform(panel_center,0,Vector2.ONE*scene_scale)
	for i in range(7):
		draw_circle(Vector2(-160+i*54,-73),2,Color("96b4c8"))
	oval(Vector2(0,75),Vector2(167,13),Color(0.04,0.07,0.13,0.32))
	if amount==58:cat_story(age)
	elif amount==388:dog_story(age)
	elif amount in [2888,2999]:cart_story(age)
	else:vault_story(age)
	if age>=1.65:
		for i in range(18):
			var a:float=i*2.399
			var t:float=age-1.65
			var at:=Vector2(cos(a),sin(a))*(40+t*60)+Vector2(0,-20+t*t*15)
			var tint:Color=[Color("f8d775"),Color("89dcce"),Color("f4a3bd")][i%3]
			tint.a=fade
			draw_circle(at,2.5,tint)
	draw_set_transform(Vector2.ZERO)
func cat_story(age:float)->void:
	var leap:=smoothstep(0.75,1.65,age)
	var bounce:=sin(leap*PI)*29
	var x:float=lerpf(-95,-20,leap)
	var yarn_x:float=lerpf(110,43,smoothstep(0,1.2,age))
	var caught:=age>=1.65
	yarn(Vector2(yarn_x,57),age*3 if not caught else 0)
	var origin:=Vector2(x,-bounce)
	# Curled tail; separate from body so the jump has a swinging silhouette.
	var tail:Array=[]
	for i in range(22):
		var t:float=i/21.0
		tail.append(origin+Vector2(-38-34*sin(t*PI*0.85),39-63*t+sin(age*6)*t*5))
	line(tail,Color("b57340"),17)
	line(tail,Color("e6ac69"),11)
	oval(origin+Vector2(0,39),Vector2(44,34),Color("e9ad69"))
	oval(origin+Vector2(9,46),Vector2(26,24),Color("fff0d3"))
	oval(origin+Vector2(-22,65),Vector2(17,9),Color("f5c68a"))
	var paw:=origin+Vector2(lerpf(25,64,leap),lerpf(43,57,leap))
	line([origin+Vector2(20,32),paw],Color("d08c4d"),20)
	oval(paw,Vector2(17,10),Color("f5c68a"))
	var head:=origin+Vector2(7,-5)
	draw_colored_polygon(PackedVector2Array([head+Vector2(-35,-13),head+Vector2(-34,-51),head+Vector2(-7,-28)]),Color("e9ad69"))
	draw_colored_polygon(PackedVector2Array([head+Vector2(9,-29),head+Vector2(39,-48),head+Vector2(39,-9)]),Color("e9ad69"))
	draw_colored_polygon(PackedVector2Array([head+Vector2(-28,-24),head+Vector2(-28,-41),head+Vector2(-15,-26)]),Color("dc8b89"))
	draw_colored_polygon(PackedVector2Array([head+Vector2(18,-27),head+Vector2(33,-39),head+Vector2(32,-21)]),Color("dc8b89"))
	oval(head,Vector2(44,35),Color("f5c68a"))
	oval(head+Vector2(4,15),Vector2(28,19),Color("fff0d3"))
	face(head,caught,true)
	for side in [-1,1]:
		for i in range(2):draw_line(head+Vector2(side*22,12+i*7),head+Vector2(side*51,8+i*13),Color("a57554"),1.5,true)
	for i in range(3):draw_line(head+Vector2(-9+i*10,-30),head+Vector2(-7+i*8,-19),Color("bc7d45"),3,true)
func yarn(at:Vector2,rotation_angle:float)->void:
	draw_circle(at,23,Color("bd5389"))
	draw_circle(at+Vector2(-2,-2),20,Color("e98cbd"))
	for i in range(5):
		var offset:float=-12+i*6
		draw_arc(at+Vector2(offset*0.3,0),16+absf(offset)*0.25,rotation_angle+0.3,rotation_angle+2.7,24,Color("f6bfd9"),1.5,true)
	line([at+Vector2(20,4),at+Vector2(33,9),at+Vector2(38,20),at+Vector2(58,21)],Color("e98cbd"),2)
func face(at:Vector2,happy:bool,cat:bool)->void:
	var ink:=Color("302d3b")
	for x in [-14,17]:
		if happy:draw_arc(at+Vector2(x,3),6,PI,TAU,16,ink,2.5,true)
		else:
			oval(at+Vector2(x,0),Vector2(4.5,7),ink)
			draw_circle(at+Vector2(x+1,-2),1.6,Color.WHITE)
	oval(at+Vector2(2,10),Vector2(5 if cat else 9,4 if cat else 6),Color("d88688") if cat else ink)
	draw_arc(at+Vector2(2,14),7,0.1,PI-0.1,18,ink,1.8,true)
	oval(at+Vector2(-25,13),Vector2(7,4),Color("e9a29b"))
	oval(at+Vector2(28,13),Vector2(7,4),Color("e9a29b"))
func dog_story(age:float)->void:
	var approach:=smoothstep(0.35,1.65,age)
	var caught:=age>=1.65
	var bob:=sin(age*12)*(1-approach)*4
	var origin:=Vector2(lerpf(-80,-10,approach),bob)
	var wag:=sin(age*17)*13
	line([origin+Vector2(-36,40),origin+Vector2(-66,17+wag)],Color("a76a49"),13)
	oval(origin+Vector2(-5,41),Vector2(45,30),Color("bc8258"))
	oval(origin+Vector2(6,46),Vector2(25,21),Color("f8e5c6"))
	for x in [-28,24]:oval(origin+Vector2(x,65),Vector2(16,10),Color("daab7b"))
	var head:=origin+Vector2(13,-7)
	oval(head+Vector2(-37,-1+sin(age*7)*3),Vector2(15,33),Color("80563e"))
	oval(head+Vector2(39,-1+sin(age*7+1)*3),Vector2(15,33),Color("80563e"))
	oval(head,Vector2(43,37),Color("dbae7e"))
	oval(head+Vector2(1,17),Vector2(29,22),Color("f8e5c6"))
	face(head,caught,false)
	if caught:
		var chew:=sin(age*18)*2
		oval(head+Vector2(3,25+chew),Vector2(7,5),Color("e8989a"))
	else:
		var food:=Vector2(lerpf(119,23,approach),lerpf(42,16,approach))
		ham(food,lerpf(-0.25,-0.6,approach))
		if age<1.25:
			for i in range(3):draw_arc(Vector2(110+i*10,13-i*9),8,-1.8,0.4,16,Color("eed09e"),1.5,true)
func ham(at:Vector2,angle:float)->void:
	var direction:=Vector2(cos(angle),sin(angle))
	var tip:=at+direction*33
	draw_line(at,tip,Color("f8ead4"),10,true)
	draw_circle(tip+Vector2(-2,-5),7,Color("fff5e2"))
	draw_circle(tip+Vector2(4,4),7,Color("fff5e2"))
	oval(at,Vector2(27,19),Color("a9584a"))
	oval(at+Vector2(-4,-2),Vector2(20,14),Color("de8a73"))
	draw_arc(at,19,3.3,5.0,20,Color("efb298"),3,true)
func treasure_story(age:float)->void:
	var lift:=smoothstep(0.4,1.6,age)
	var base:=Rect2(-68,4,136,65)
	draw_rect(base,Color("ad7745"))
	draw_rect(Rect2(-68,4,136,12),Color("efd18b"))
	for x in [-50,40]:draw_rect(Rect2(x,4,10,65),Color("efd18b"))
	draw_rect(Rect2(-68,-4-lift*30,136,18),Color("d3a15a"))
	for i in range(9):
		var at:=Vector2(-45+(i%3)*44,-10-lift*(30+(i/3)*25))
		draw_circle(at,14,Color("e8b752"))
		draw_arc(at,10,0,TAU,24,Color("ffe7a0"),2,true)

func screen_shake() -> Vector2:
	if clock<=0 or amount not in [2888,2999]:return Vector2.ZERO
	var age:=DURATION-clock
	var power:float=7.0*smoothstep(0.05,0.35,age)*(1.0-smoothstep(2.1,2.8,age))
	return Vector2(sin(age*73)+sin(age*121)*0.3,cos(age*89))*power

func coin_icon(at:Vector2,radius:float)->void:
	draw_circle(at,radius,Color("c99736"))
	draw_circle(at+Vector2(-1,-1),radius-2,Color("f5ce68"))
	draw_arc(at,radius-4,0,TAU,24,Color("fff1a9"),1.2,true)
	var star:=PackedVector2Array()
	for i in range(10):
		var a:float=-PI/2+i*PI/5
		star.append(at+Vector2(cos(a),sin(a))*radius*(0.48 if i%2==0 else 0.22))
	draw_colored_polygon(star,Color("ae7d2c"))

func cart_story(age:float)->void:
	var arrival:=smoothstep(0.1,1.1,age)
	var x:float=lerpf(-230,0,arrival)
	var shake:=sin(age*70)*3
	var boom:=maxf(0,age-1.65)
	var floor_y:=68.0
	# Tracks tremble and crack before the cart bursts.
	line([Vector2(-173,floor_y+5),Vector2(173,floor_y+5)],Color("a5b8c2"),4)
	line([Vector2(-173,floor_y+17),Vector2(173,floor_y+17)],Color("748d9e"),3)
	for i in range(9):draw_line(Vector2(-161+i*40,floor_y),Vector2(-155+i*40,floor_y+20),Color("748d9e"),4,true)
	if boom<=0:
		for side in [-1,1]:
			var wheel:=Vector2(x+side*51,57+shake)
			draw_circle(wheel,17,Color("263246"))
			draw_circle(wheel,12,Color("9bb1bc"))
			draw_circle(wheel,5,Color("e5d7b0"))
			var spoke:=Vector2(cos(age*10),sin(age*10))*11
			draw_line(wheel-spoke,wheel+spoke,Color("34445b"),3,true)
		var hull:=PackedVector2Array([Vector2(x-76,-11+shake),Vector2(x+76,-11+shake),Vector2(x+62,45+shake),Vector2(x-62,45+shake)])
		draw_colored_polygon(hull,Color("956741"))
		for y in [4,22,40]:draw_line(Vector2(x-64,y+shake),Vector2(x+64,y+shake),Color("d3a876"),4,true)
		for side in [-1,1]:draw_line(Vector2(x+side*57,-9+shake),Vector2(x+side*49,43+shake),Color("9fb0b7"),7,true)
		for row in range(3):
			for col in range(5-row):coin_icon(Vector2(x-51+col*26+row*13,-18-row*20+shake),14)
		draw_line(Vector2(x-80,-9+shake),Vector2(x+80,-9+shake),Color("e7c28a"),8,true)
	else:
		var flash:=PackedVector2Array()
		for i in range(24):
			var a:float=i*TAU/24
			flash.append(Vector2(cos(a),sin(a))*(70+boom*35)*(1.0 if i%2==0 else 0.66)+Vector2(0,-15))
		var glow:=Color("ffda73")
		glow.a=maxf(0,1-boom/1.3)
		draw_colored_polygon(flash,glow)
		for side in [-1,1]:
			var p:=Vector2(side*(48+boom*45),25+boom*19)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-29,-16),p+Vector2(27,-20),p+Vector2(20,17),p+Vector2(-25,14)]),Color("b48555"))
			draw_circle(p+Vector2(side*14,24),15,Color("657988"))
		for i in range(19):
			var a:float=-PI+0.20+i*2.75/18
			var speed:float=45+(i%5)*19
			var p:=Vector2(cos(a)*speed*boom,sin(a)*speed*boom+35*boom*boom-12)
			coin_icon(p,10+i%3)

func vault_story(age:float)->void:
	var opening:=smoothstep(0.45,1.65,age)
	var frame:=StyleBoxFlat.new()
	frame.bg_color=Color("aa7945")
	frame.border_color=Color("f4d492")
	frame.set_border_width_all(8)
	frame.set_corner_radius_all(10)
	draw_style_box(frame,Rect2(-84,-74,168,144))
	draw_rect(Rect2(-69,-59,138,118),Color("17263f"))
	for side in [-1,1]:
		var outer:float=side*72
		var inner:float=side*(4+opening*65)
		var door:=PackedVector2Array([Vector2(outer,-60),Vector2(inner,-60+opening*10),Vector2(inner,59-opening*8),Vector2(outer,59)])
		draw_colored_polygon(door,Color("d0a05c"))
		draw_polyline(door+PackedVector2Array([door[0]]),Color("f9e0a0"),3,true)
	if opening>0.4:
		for i in range(22):
			var t:float=fmod(age*0.7+i*0.137,1.0)
			var spread:float=(i%7-3)*12
			var at:=Vector2(spread*(0.3+t),35-sin(t*PI)*122)
			coin_icon(at,9+i%3)
	for i in range(8):
		var a:float=i*TAU/8+age*0.1
		var p:=Vector2(cos(a)*132,sin(a)*85)
		draw_line(p-Vector2(0,5),p+Vector2(0,5),Color("ffe6a1"),2,true)
		draw_line(p-Vector2(5,0),p+Vector2(5,0),Color("ffe6a1"),2,true)
