extends HTTPRequest
var image:Image
var is_multiplayer:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	request_completed.connect(self._on_request_completed)
	download_chunk_size = 4196000
	use_threads = true
	pass # Replace with function body.


func make_request(url) -> Texture:
	var error = request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	await request_completed
	var texture = ImageTexture.create_from_image(image)
	return texture


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("function called")
	#var image = Image.new()
	image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

#	var texture = ImageTexture.create_from_image(image)
