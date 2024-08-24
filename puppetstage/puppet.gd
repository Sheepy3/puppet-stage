extends Node2D
var dragging
var drag_start
var start_position
var final_position
#@export var name:String
@export var sprite:String
var prev_sprite:String
@export var focused:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		update_position.rpc(position)

func _changesprite():
	pass


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging = true
				drag_start = get_global_mouse_position()
				start_position = position
			else:
				# Stop dragging
				dragging = false
				

@rpc("any_peer","call_local")
func update_position(sent_final_position):
	position = sent_final_position

@rpc("any_peer","call_local")
func update_sprite(spriteurl):
	sprite = spriteurl
	if not HttpHandler.is_multiplayer:
		_on_multiplayer_synchronizer_synchronized() 

func _on_update_pressed() -> void:
	if (prev_sprite != sprite) || (sprite != null):
		update_sprite(%SpriteURL.text)
		print("called")
	pass # Replace with function body.

func _on_multiplayer_synchronizer_synchronized() -> void:
	if prev_sprite != sprite:
		var new_sprite = await HttpHandler.make_request(%SpriteURL.text)
		if new_sprite:
			$Sprite2D.set_texture(new_sprite)
		prev_sprite = sprite
	pass # Replace with function body.


func _on_size_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
