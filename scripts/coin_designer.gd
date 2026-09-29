extends Node
signal applied(texture:Texture2D)
const FILE_PATH:="user://coin-design.png"
var hud
var bridge:Object
var picking:=false
var source:Image
var preview:Image
var picture:TextureRect
var confirm:Button
var zoom:=1.0
var pan:=Vector2.ZERO
var current:Texture2D
var dialog:FileDialog
func _ready()->void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	if Engine.has_singleton("SlowCoinSpeech"):
		bridge=Engine.get_singleton("SlowCoinSpeech")
		if bridge.has_signal("image_selected"):
			bridge.connect("image_selected",load_selected)
			bridge.connect("image_failed",on_failed)
	if FileAccess.file_exists(FILE_PATH):
		var saved:=Image.load_from_file(FILE_PATH)
		if saved!=null and not saved.is_empty():current=ImageTexture.create_from_image(saved)
func show_editor()->void:
	var content=hud.sheet("我的定制金币","选择图片 → 圆形裁切 → 简化币面\n仅保存在本机，不上传图片")
	picture=TextureRect.new()
	picture.custom_minimum_size=Vector2(220,180)
	picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture=ImageTexture.create_from_image(preview) if preview!=null else current
	content.add_child(picture)
	hud.button(content,"选择一张图片",pick_image).custom_minimum_size.y=42
	for item in [["放大",1.0,3.0,zoom],["左右",-1.0,1.0,pan.x],["上下",-1.0,1.0,pan.y]]:
		var row:=HBoxContainer.new()
		content.add_child(row)
		hud.label(row,item[0],12)
		var slider:=HSlider.new()
		slider.min_value=item[1];slider.max_value=item[2];slider.value=item[3];slider.step=0.02
		slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size=Vector2(150,24)
		row.add_child(slider)
		slider.value_changed.connect(func(value):
			if item[0]=="放大":zoom=value
			elif item[0]=="左右":pan.x=value
			else:pan.y=value
			render_preview())
	confirm=hud.button(content,"应用到所有金币",commit,true)
	confirm.custom_minimum_size.y=42
	confirm.disabled=preview==null
	hud.button(content,"恢复默认币面",reset_design).custom_minimum_size.y=38
	hud.button(content,"返回皮肤商店",func():hud.skin_preview_closed.emit()).custom_minimum_size.y=38
func pick_image()->void:
	picking=true
	if bridge!=null and bridge.has_method("pick_image"):
		bridge.call("pick_image")
	else:
		dialog=FileDialog.new()
		dialog.use_native_dialog=true
		dialog.access=FileDialog.ACCESS_FILESYSTEM
		dialog.file_mode=FileDialog.FILE_MODE_OPEN_FILE
		dialog.filters=PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp;图片"])
		add_child(dialog)
		dialog.file_selected.connect(load_selected)
		dialog.canceled.connect(func():on_failed(""))
		dialog.popup_centered_ratio(0.8)
func load_selected(path:String)->void:
	picking=false
	if is_instance_valid(dialog):dialog.queue_free()
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null or file.get_length()>32*1024*1024:
		on_failed("图片太大或无法读取，请选择小于 32 MB 的图片")
		return
	source=Image.load_from_file(path)
	if source==null or source.is_empty():on_failed("这张图片无法读取，请换一张");return
	if maxi(source.get_width(),source.get_height())>1024:
		var ratio:=1024.0/maxi(source.get_width(),source.get_height())
		source.resize(maxi(1,int(source.get_width()*ratio)),maxi(1,int(source.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
	zoom=1;pan=Vector2.ZERO
	preview=simplify(source,zoom,pan)
	show_editor()
func on_failed(message:String)->void:
	picking=false
	show_editor()
	if not message.is_empty():hud.toast(message)
func render_preview()->void:
	if source==null:return
	preview=simplify(source,zoom,pan)
	picture.texture=ImageTexture.create_from_image(preview)
	confirm.disabled=false
static func simplify(input:Image,scale:float,offset:Vector2)->Image:
	var edge:=maxf(1,minf(input.get_width(),input.get_height())/maxf(1,scale))
	var origin:=Vector2((input.get_width()-edge)*(offset.x+1)/2,(input.get_height()-edge)*(offset.y+1)/2)
	var crop:=input.get_region(Rect2i(Vector2i(origin),Vector2i(int(edge),int(edge))))
	crop.resize(256,256,Image.INTERPOLATE_LANCZOS)
	crop.convert(Image.FORMAT_RGBA8)
	var result:=Image.create(256,256,false,Image.FORMAT_RGBA8)
	for y in range(256):
		for x in range(256):
			var radius:=Vector2(x-127.5,y-127.5).length()/127.5
			if radius>1:result.set_pixel(x,y,Color(0,0,0,0));continue
			var color:=crop.get_pixel(x,y)
			var gray:=color.get_luminance()*color.a+(1-color.a)
			var neighbor:=crop.get_pixel(mini(x+1,255),mini(y+1,255)).get_luminance()
			var tone:=clampf(roundf(gray*3)/3-absf(gray-neighbor)*0.7,0,1)
			result.set_pixel(x,y,Color(tone,tone,tone,1))
	return result
func commit()->void:
	if preview==null:return
	var temporary:=FILE_PATH+".tmp.png"
	if preview.save_png(temporary)!=OK or DirAccess.rename_absolute(temporary,FILE_PATH)!=OK:
		hud.toast("保存失败，原币面保持不变");return
	current=ImageTexture.create_from_image(preview)
	applied.emit(current)
	hud.toast("定制币面已应用 · 新旧金币同步更新")
func reset_design()->void:
	if FileAccess.file_exists(FILE_PATH) and DirAccess.remove_absolute(FILE_PATH)!=OK:
		hud.toast("无法清除定制币面，请重试");return
	current=null;source=null;preview=null
	applied.emit(null)
	show_editor()
