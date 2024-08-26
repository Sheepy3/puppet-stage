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
@onready var Sprite = %Sprite2D
@onready var EditPanel = %Panel

func _process(_delta: float) -> void:
	#if possessor !=0:
	%Possessor.text = str(possessor)
	if dragging:
		position = start_position + get_global_mouse_position() - drag_start
		update_position.rpc(position)
	if focused:
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
	pass

@rpc("any_peer","call_local")
func update_possessor(possessorid):
	possessor = possessorid
	%Possessor.text = str(possessor)


func custom_handle_input(event):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed && !panel_visible && focused:
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
