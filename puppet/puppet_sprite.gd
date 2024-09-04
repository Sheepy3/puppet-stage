extends Sprite2D
@onready var Puppet
@onready var EditPanel = %Panel


#@export var base_scale:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Puppet = get_owner()
	print(Puppet)
	if multiplayer.get_unique_id() != 1:
		update_size.rpc()
	generate_collision()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func default_scale_resize(image:Image) -> Image:
	const resize_width = 1000
	var height:float = image.get_height()
	var width = image.get_width()
	var ratio = height/width
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
			generate_collision()
			
				#%Area2D.scale = Puppet.scale
				
				#update_sprite_local.rpc(new_sprite.get_width(),new_sprite.get_height(),new_sprite.get_format(),new_sprite.get_data())
		
func generate_collision():
	for child in %Area2D.get_children():
		child.queue_free()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(texture.get_image())
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture.get_size()))
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.position -= Vector2(bitmap.get_size()/2)
		%Area2D.add_child(collision_polygon)
		
		
@rpc("authority","call_remote")
func update_sprite_local(width,height,format,data):
	print("called")
	#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PackedByteArray) static
	var new_sprite = Image.create_from_data(width,height,true,format,data)
	var new_texture = ImageTexture.create_from_image(new_sprite)
	set_texture(new_texture)
	
@rpc("any_peer","call_local")
func update_size(size:float = 0.4):
	var base_scale = Vector2(size,size)
	set_scale(base_scale)
