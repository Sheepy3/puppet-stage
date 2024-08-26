extends Node2D

###networking
var peer = ENetMultiplayerPeer.new()
var cursor:PackedScene = preload("res://cursor/Cursor.tscn")
@export var puppet_scene: PackedScene
var ip:String
var port:int

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
	%SpawnPuppet.hide()
	%TiledBg.position = %Camera2D.get_screen_center_position() 


var magreading:Array = [0,0,0]

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
	peer.create_server(135)
	HttpHandler.is_multiplayer = true
	multiplayer.multiplayer_peer = peer
	%NetworkStatus.text = "HOST"
	%Networking_UI.hide()
	%SpawnPuppet.show()
	_spawn_cursor()

func _on_join_pressed():
	peer.create_client(ip, 135)
	HttpHandler.is_multiplayer = true
	multiplayer.multiplayer_peer = peer
	%NetworkStatus.text = "PEER"
	%Networking_UI.hide()
	%SpawnPuppet.show()

func _on_spawn_puppet_pressed() -> void:
	_spawn_puppet.rpc()

func _spawn_cursor(id = 1):
	if not multiplayer.is_server():
		return
	#print(id)
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
