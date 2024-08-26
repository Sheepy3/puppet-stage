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


func _process(_delta):
	if analyzer_instance:
		var magnitude = analyzer_instance.get_magnitude_for_frequency_range(0, 10000,1)


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
			%Menu.show()
		else:
			%Menu.hide()


@rpc("any_peer", "call_local")
func _spawn_puppet():
	if multiplayer.is_server():
		var new_puppet = puppet_scene.instantiate()
		add_child(new_puppet, true)
