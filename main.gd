extends Node2D

###networking
var peer = ENetMultiplayerPeer.new()
var cursor:PackedScene = preload("res://cursor/Cursor.tscn")
@export var puppet_scene: PackedScene
var ip:String = "localhost"#"localhost"
var port:int = 9999
var external_address

###microphone
var idx
var bus_index
var spectrum_analyzer
var analyzer_instance:AudioEffectInstance
#var test:AudioEffectSpectrumAnalyzerInstance

###menu
var menuopen:bool = true


func _ready():
	bus_index = AudioServer.get_bus_index("Record")
	analyzer_instance = AudioServer.get_bus_effect_instance(bus_index, 1)
	multiplayer.peer_connected.connect(_spawn_cursor)
	#multiplayer.connected_to_server.connect(_connection_successful)
	%SpawnPuppet.hide()
	%TiledBg.position = %Camera2D.get_screen_center_position() 
	
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var map_result_udp = upnp.add_port_mapping(9999,9999,"godot_udp", "UDP",0)
			var map_result_tcp = upnp.add_port_mapping(9999,9999,"godot_tcp", "TCP",0)
			
			if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999,9999,"","UDP")
			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999,9999,"","TCP")
		external_address = upnp.query_external_address()

var magreading:Array = [0,0,0]
#func _connection_successful():
#	print(multiplayer.get_peers())
#	print("hi")
func _process(_delta):
	if analyzer_instance:
		magreading.pop_front()
		var magnitude = analyzer_instance.get_magnitude_for_frequency_range(0, 10000,1)
		magreading.append(remap(magnitude.length(),0,0.5,0.1,0.5))
		var sum:float
		for num in magreading:
			sum+=num
		sum = sum/3
		HttpHandler.local_volume = remap(magnitude.length(),0,0.5,0.1,0.5)
	
func _on_host_pressed():
	peer.create_server(9999)
	#peer.set_bind_ip(external_address)
	HttpHandler.is_multiplayer = true
	multiplayer.multiplayer_peer = peer
	%NetworkStatus.text = "HOST"
	%Networking_UI.hide()
	%SpawnPuppet.show()
	%IP_Label.text = external_address
	_spawn_cursor()

func _on_join_pressed():
	var error = peer.create_client(ip, port)
	
	if error != OK:
		print("FUCK")
	#print(peer)
	HttpHandler.is_multiplayer = true
	multiplayer.multiplayer_peer = peer
	#print(multiplayer.get_unique_id())
	%NetworkStatus.text = "PEER"
	%Networking_UI.hide()
	%SpawnPuppet.show()

func _on_spawn_puppet_pressed() -> void:
	_spawn_puppet.rpc()

func _spawn_cursor(id = 1):
#	print("running this shit")
	if not multiplayer.is_server():
		return
	var new_cursor = cursor.instantiate()
	new_cursor.name = str(id)
	call_deferred("add_child",new_cursor,true)

func _input(event:InputEvent):
	if event.is_action_pressed("menu_open"):
		menuopen = !menuopen
		if menuopen:
			%UI.show()
		else:
			%UI.hide()
	if event.is_action_pressed("reset_camera"):
		%Camera2D.position = Vector2(0,0)

@rpc("any_peer", "call_local")
func _spawn_puppet():
	if multiplayer.is_server():
		#var unique_name = "meow"
		var new_puppet = puppet_scene.instantiate()
		#new_puppet.name = unique_name
		add_child(new_puppet, true)
		new_puppet.position = $Camera2D.get_screen_center_position()
		_spawn_puppet_local.rpc()

@rpc("authority","call_remote")
func _spawn_puppet_local():
	var new_puppet = puppet_scene.instantiate()
	add_child(new_puppet, true)
	new_puppet.position = $Camera2D.get_screen_center_position()


func _on_port_input_text_changed() -> void:
	port = int($"CanvasLayer/UI/Main Menu/VBoxContainer/Networking_UI/PortInput".text)# Replace with function body.


func _on_ip_input_text_changed() -> void:
	ip = $"CanvasLayer/UI/Main Menu/VBoxContainer/Networking_UI/IPInput".text
