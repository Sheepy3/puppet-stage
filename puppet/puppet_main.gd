extends Node2D
var dragging
var drag_start
var start_position
var final_position

@export var puppet_sprite:String
var prev_sprite:String
@export var focused:bool
@export var panel_visible:bool
@export var possession_color:String

@onready var Sprite = %Sprite2D
@onready var EditPanel = %Panel

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
