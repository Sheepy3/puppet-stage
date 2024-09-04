extends HTTPRequest
var image:Image

### awkwardly placed global vars
var is_multiplayer:bool = false
var local_volume:float
var cursor_color:Color
var port:int =9999
var ip:String ="localhost"

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

func _on_request_completed(_result: int, _response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("HTTPS Request completed!")
	image = Image.new()
	var unpacked_headers = " ".join(headers)

	var regex = RegEx.new()
	regex.compile(r"image/([^\s]+)")
	var result = regex.search(unpacked_headers)
	result = result.get_string(1).to_upper()
	print(result)
	var format
	
	match result:
		"PNG":
			format = {"loader": "load_png_from_buffer", "name": "PNG"}
		"SVG":
			format = {"loader": "load_svg_from_buffer", "name": "SVG"}
		"WEBP":
			format = {"loader": "load_webp_from_buffer", "name": "WEBP"}
		"JPEG":
			format = {"loader": "load_jpg_from_buffer", "name": "JPEG"}
		_:
			push_error("Unable to grab content type from header.")

	var error = image.call(format["loader"], body)
	if error == OK:
		return
	
	push_error("Unable to grab image from URL.")
