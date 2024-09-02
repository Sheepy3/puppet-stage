extends Node2D
var dragging:bool = false
var drag_start
var start_position
var final_position

@export var puppet_sprite:String
var prev_sprite:String
@export var focused:bool
@export var panel_visible:bool = false
@export var possession_color:String
@export var possessor:int
@export var flip:bool
var Sprite
var EditPanel
var mouse_over:bool = false
var shape_material:Material


func _ready():
	Sprite = %Sprite2D
	EditPanel = %Panel
	shape_material = %Sprite2D.material

func _process(_delta: float) -> void:
	%Possessor.text = str(possessor)
	%Focused.text = str(focused)
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		pass
	if focused:
		if multiplayer.get_unique_id() == possessor:
			var vibrato_factor = remap(HttpHandler.local_volume,0.1,0.5,1.0,1.5)
			var rotate_factor = remap(HttpHandler.local_volume,0.1,0.5,10,90)
			if rotate_factor < 20:
				rotate_factor = 0
			if rotate_factor > 60:
				rotate_factor = randi_range(-20,20)
			var vibrato = Vector2(vibrato_factor,vibrato_factor)
			if flip:
				rotate_factor *= -1
			talk_driver.rpc(vibrato,rotate_factor)



@rpc("any_peer","call_local")
func talk_driver(vibrato, rotate_factor):
	scale = scale.lerp(vibrato,0.1)
	%Sprite2D.rotation_degrees = lerpf(%Sprite2D.rotation_degrees,rotate_factor,0.1)
	pass


func _input(event):
	if event is InputEventMouseButton:
		if %Area2D.get_overlapping_areas():
			for areas in %Area2D.get_overlapping_areas():
				update_possessor.rpc(int(str(areas.name)))
			focused = true
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			panel_visible = !panel_visible
			if panel_visible:
				%Panel.show()
			else:
				%Panel.hide()
		else:
			focused = false
			update_possessor.rpc(0)
	if event.is_action_pressed("flip"):
		flip_sprite.rpc()


@rpc("any_peer","call_local")
func flip_sprite():
	flip = !flip

@rpc("any_peer","call_local")
func update_possessor(possessorid):
	possessor = possessorid
	%Possessor.text = str(possessor)





@rpc("any_peer","call_local")
func update_position(sent_final_position):
	position = sent_final_position


func _on_send_to_origin_pressed() -> void:
	position = Vector2(0,0)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && get_window().has_focus():
		if event.pressed == true:
			for areas in %Area2D.get_overlapping_areas():
				focused = true
			
			if dragging != true:
				start_position = position
				drag_start = get_global_mouse_position()
			dragging = true
			shape_material.set_shader_parameter("color_input",Vector4(0.2,0.2,0.2,1.0))
		else:
			dragging = false
			shape_material.set_shader_parameter("color_input",Vector4(0.0,0.0,0.0,1.0))
	print(dragging)
