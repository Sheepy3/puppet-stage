extends Node2D
var dragging
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

func _ready():
	Sprite = %Sprite2D
	EditPanel = %Panel


func _process(_delta: float) -> void:
	#var scale = Sprite.base_scale
	#if possessor !=0:
	%Possessor.text = str(possessor)
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		update_position.rpc(position)
	if focused:
		if multiplayer.get_unique_id() == possessor:
			print()
			var vibrato_factor = remap(HttpHandler.local_volume,0.1,0.5,1.0,1.5)
			var rotate_factor = remap(HttpHandler.local_volume,0.1,0.5,10,90)
			if rotate_factor < 20:
				rotate_factor = 0
			if rotate_factor > 60:
				rotate_factor = randi_range(-20,20)
			var vibrato = Vector2(vibrato_factor,vibrato_factor)
			if flip:
				rotate_factor *= -1
			#print(vibrato)
			talk_driver.rpc(vibrato,rotate_factor)
			#%Sprite_Rotation_Point.rotation_degrees = lerpf(rotation_degrees,rotate_factor,0.1)
			#var vibrato = lerpf(,HttpHandler.local_volume,0.1)
		pass

@rpc("any_peer","call_local")
func talk_driver(vibrato, rotate_factor):
	scale = scale.lerp(vibrato,0.1)
	%Sprite_Rotation_Point.rotation_degrees = lerpf(%Sprite_Rotation_Point.rotation_degrees,rotate_factor,0.1)
	pass


func _input(event):
	if event is InputEventMouseButton:
		if %Area2D.get_overlapping_areas():
			print("clicked")
			for areas in %Area2D.get_overlapping_areas():
				update_possessor.rpc(int(str(areas.name)))
			focused = true
			custom_handle_input(event)
			
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


func custom_handle_input(event):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed && !panel_visible && focused && get_window().has_focus():
			dragging = true
			drag_start = get_global_mouse_position()
			start_position = position
		else:
			dragging = false
	if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
		
		panel_visible = !panel_visible
		if panel_visible:
			%Panel.show()
			#%Area2D.hide()
		else:
			%Panel.hide()
			#%Area2D.show()

@rpc("any_peer","call_local")
func update_position(sent_final_position):
	position = sent_final_position


func _on_send_to_origin_pressed() -> void:
	position = Vector2(0,0)
