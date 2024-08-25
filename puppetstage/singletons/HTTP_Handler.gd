extends HTTPRequest
var image:Image
var is_multiplayer:bool = false


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
	image = Image.new()
	
	var image_formats = [
		{"loader": "load_png_from_buffer", "name": "PNG"},
		{"loader": "load_jpg_from_buffer", "name": "JPEG"},
		{"loader": "load_svg_from_buffer", "name": "SVG"},
		{"loader": "load_webp_from_buffer", "name": "WEBP"}
	]
	
	for format in image_formats:
		var error = image.call(format["loader"], body)
		if error == OK:
			return
		push_warning("format ",format["name"]," loading failed.")
	
	push_error("Unable to grab image from URL.")
