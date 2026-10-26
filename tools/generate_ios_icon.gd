extends SceneTree
func _initialize() -> void:
	var image := Image.new()
	var error := image.load_svg_from_string(FileAccess.get_file_as_string("res://assets/icon.svg"), 2.0)
	if error != OK:
		quit(1)
		return
	image.resize(1024, 1024, Image.INTERPOLATE_LANCZOS)
	var background := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	background.fill(Color("112b3a"))
	background.blend_rect(image, Rect2i(0, 0, 1024, 1024), Vector2i.ZERO)
	image = background
	image.convert(Image.FORMAT_RGB8)
	DirAccess.make_dir_recursive_absolute("res://assets/ios-icons")
	quit(image.save_png("res://assets/ios-icons/icon-1024.png"))
