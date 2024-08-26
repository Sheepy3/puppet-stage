extends Sprite2D
@onready var Puppet = get_parent()
@onready var EditPanel = %Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func default_scale_resize(image:Image) -> Image:
	const resize_width = 1000
	var height:float = image.get_height()
	var width = image.get_width()
	var ratio = height/width
	#print(height)
	#print(width)
	#print(ratio)
	var new_image = Image.new()
	new_image.copy_from(image)
	new_image.generate_mipmaps()
	new_image.resize(resize_width, resize_width*ratio)
	return new_image

@rpc("any_peer","call_local")
func update_sprite(url):
	#print(multiplayer.get_unique_id())
	if multiplayer.is_server():
		Puppet.puppet_sprite = url
		Puppet.prev_sprite = Puppet.puppet_sprite
		print("updating sprite")
		var new_sprite = await HttpHandler.make_request(Puppet.puppet_sprite)
		new_sprite = default_scale_resize(new_sprite)
		if new_sprite:
			var new_texture = ImageTexture.create_from_image(new_sprite)
			%Sprite2D.set_texture(new_texture)
			update_size(%Size_Slider.value)
			update_sprite_local.rpc(new_sprite.get_width(),new_sprite.get_height(),new_sprite.get_format(),new_sprite.get_data())
		
@rpc("authority","call_remote")
func update_sprite_local(width,height,format,data):
	print("called")
	#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PackedByteArray) static
	var new_sprite = Image.create_from_data(width,height,true,format,data)
	var new_texture = ImageTexture.create_from_image(new_sprite)
	set_texture(new_texture)
	
@rpc("any_peer","call_local")
func update_size(size:float = 1):
	var new_scale = Vector2(size,size)
	set_scale(new_scale)
	var updated_collision_shape = %CollisionShape2D.get_shape()
	#print(updated_collision_shape)
	updated_collision_shape.set_radius(400*size)
	%CollisionShape2D.set_shape(updated_collision_shape)
	pass
