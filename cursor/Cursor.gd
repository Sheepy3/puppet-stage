extends Node2D

func _ready() -> void:
	pass # Replace with function body.

func _enter_tree():
	#print(name)
	set_multiplayer_authority(name.to_int())
	$Area2D.name = name
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	if is_multiplayer_authority():
		position = get_global_mouse_position()

func _input(input:InputEvent) -> void:
	if input is InputEventMouseButton:
		pass
