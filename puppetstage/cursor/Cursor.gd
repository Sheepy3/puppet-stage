extends Node2D
#var point:Resource = preload("res://vector_brush/point.tscn")
#var points:PackedVector2Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Cursor ready:", name, "Authority:", get_multiplayer_authority())
	pass # Replace with function body.

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	if is_multiplayer_authority():
		position = get_global_mouse_position()
		pass

func _input(input:InputEvent) -> void:
	if input is InputEventMouseButton:
		pass
