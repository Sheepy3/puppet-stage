extends Camera2D


@export var speed = 2
var velocity 
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	position += velocity

	%Coordinates.text = str(Vector2i(position))
