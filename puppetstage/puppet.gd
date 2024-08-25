extends Node2D
var dragging
var drag_start
var start_position
var final_position

@export var sprite:String
var prev_sprite:String
@export var focused:bool


func _process(_delta: float) -> void:
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		update_position.rpc(position)
	$Panel/VBoxContainer/Sprite_Label.text = sprite
	$Panel/VBoxContainer/Sprite_Label2.text = prev_sprite

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = get_global_mouse_position()
				start_position = position
			else:
				dragging = false

@rpc("any_peer","call_local")
func update_position(sent_final_position):
	position = sent_final_position

@rpc("any_peer","call_local")
func update_sprite(data):
	print(multiplayer.get_unique_id())
	if multiplayer.is_server():
		sprite = data
		prev_sprite = sprite
		print("updating sprite")
		var new_sprite = await HttpHandler.make_request(sprite)
		if new_sprite:
			var new_texture = ImageTexture.create_from_image(new_sprite)
			%Sprite2D.set_texture(new_texture)
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
