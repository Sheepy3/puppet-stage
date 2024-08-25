extends Node2D
var dragging
var drag_start
var start_position
var final_position

@export var sprite:String
var prev_sprite:String
@export var focused:bool
@export var panel_visible:bool
@export var possession_color:String

func _process(_delta: float) -> void:
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		update_position.rpc(position)
	if focused:
		pass

func _input(event):
	if event is InputEventMouseButton:
		if %Area2D.get_overlapping_areas():
			focused = true
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					dragging = true
					drag_start = get_global_mouse_position()
					start_position = position
				else:
					dragging = false
			if event.button_index == MOUSE_BUTTON_RIGHT &&  event.pressed:
				panel_visible = !panel_visible
				if panel_visible:
					%Panel.show()
				else:
					%Panel.hide()
		else:
			focused = false
	pass




@rpc("any_peer","call_local")
func update_position(sent_final_position):
	position = sent_final_position

@rpc("any_peer","call_local")
func update_sprite(url):
	print(multiplayer.get_unique_id())
	if multiplayer.is_server():
		sprite = url
		prev_sprite = sprite
		print("updating sprite")
		var new_sprite = await HttpHandler.make_request(sprite)
		new_sprite = default_scale_resize(new_sprite)
		if new_sprite:
			var new_texture = ImageTexture.create_from_image(new_sprite)
			%Sprite2D.set_texture(new_texture)
			update_size(%Size_Slider.value)
			update_sprite_local.rpc(new_sprite.get_width(),new_sprite.get_height(),new_sprite.get_format(),new_sprite.get_data())
		
@rpc("authority","call_remote")
func update_sprite_local(width,height,format,data):
	print("called")
	#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PackedByteArray) static
	var new_sprite = Image.create_from_data(width,height,false,format,data)
	var new_texture = ImageTexture.create_from_image(new_sprite)
	%Sprite2D.set_texture(new_texture)
	
@rpc("any_peer","call_local")
func update_size(size):
	var new_scale = Vector2(size,size)
	%Sprite2D.set_scale(new_scale)
	var updated_collision_shape = %CollisionShape2D.get_shape()
	print(updated_collision_shape)
	updated_collision_shape.set_radius(400*size)
	%CollisionShape2D.set_shape(updated_collision_shape)
	pass

func _on_update_pressed() -> void:
	sprite = %SpriteURL.text
	if (prev_sprite != sprite) || (sprite != null):
		update_sprite.rpc(sprite)
		print("called")
	pass # Replace with function body.

func _on_size_slider_value_changed(value: float) -> void:
	update_size.rpc(value)
	pass # Replace with function body.

func default_scale_resize(image:Image) -> Image:
	const resize_width = 1000
	var height:float = image.get_height()
	var width = image.get_width()
	var ratio = height/width
	#print(height)
	#print(width)
	#print(ratio)
	var new_image = Image.new()
	new_image.copy_from(image)
	new_image.generate_mipmaps()
	new_image.resize(resize_width, resize_width*ratio)
	return new_image
