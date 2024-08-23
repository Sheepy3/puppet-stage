extends Control
var dragging
var drag_start
var start_position
var final_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		update_position.rpc(position)


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
