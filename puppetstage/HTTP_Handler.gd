extends HTTPRequest
var image:Image
var is_multiplayer:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	request_completed.connect(self._on_request_completed)
	download_chunk_size = 4196000
	use_threads = true
	pass # Replace with function body.


func make_request(url) -> Image:
	print(url)
	var error = request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	await request_completed
	#var texture = ImageTexture.create_from_image(image)
	return image


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("HTTPS Request completed!")
	#var image = Image.new()
	image = Image.new()
	
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_warning("PNG loading failed.")
	else:
		return
	error = image.load_jpg_from_buffer(body)
	if error != OK:
		push_warning("JPEG loading failed.")
	else:
		return
	error = image.load_svg_from_buffer(body)
	if error != OK:
		push_warning("SVG loading failed.")
	else:
		return
	error = image.load_webp_from_buffer(body)
	if error != OK:
		push_warning("WEBP loading failed.")
	else:
		return
	push_error("unable to grab image from url.")

#	var texture = ImageTexture.create_from_image(image)
