extends Panel

@onready var Sprite = %Sprite2D
@onready var Puppet = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_update_pressed() -> void:
	Puppet.puppet_sprite = %SpriteURL.text
	if (Puppet.prev_sprite != Puppet.puppet_sprite) || (Puppet.puppet_sprite != null):
		Sprite.update_sprite.rpc(Puppet.puppet_sprite)
		print("called")
	pass # Replace with function body.

func _on_size_slider_value_changed(value: float) -> void:
	Sprite.update_size.rpc(value)
	pass # Replace with function body.
