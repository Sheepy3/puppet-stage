extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var puppet_scene: PackedScene
var cursor:PackedScene = preload("res://cursor/Cursor.tscn")
var idx
var bus_index
var spectrum_analyzer
var analyzer_instance:AudioEffectInstance
var test:AudioEffectSpectrumAnalyzerInstance
var ip:String
func _ready():
	bus_index = AudioServer.get_bus_index("Record")
	analyzer_instance = AudioServer.get_bus_effect_instance(bus_index, 1)
	multiplayer.peer_connected.connect(_spawn_cursor)

func _process(_delta):
	if analyzer_instance:
		var magnitude = analyzer_instance.get_magnitude_for_frequency_range(0, 10000,1)

func _on_host_pressed():
	peer.create_server(135)
	HttpHandler.is_multiplayer = true
	multiplayer.multiplayer_peer = peer
	%NetworkStatus.text = "HOST"
	%Host.hide()
	%Join.hide()
	_spawn_cursor()

func _on_join_pressed(ip = "localhost"):
	peer.create_client(ip, 135)
	HttpHandler.is_multiplayer = true
	multiplayer.multiplayer_peer = peer
	%NetworkStatus.text = "PEER"
	%Host.hide()
	%Join.hide()

func _spawn_cursor(id = 1):
	if not multiplayer.is_server():
		return
	#print(id)
	var new_cursor = cursor.instantiate()
	new_cursor.name = str(id)
	call_deferred("add_child",new_cursor,true)

func _on_spawn_puppet_pressed() -> void:
	_spawn_puppet.rpc()


@rpc("any_peer", "call_local")
func _spawn_puppet():
	if multiplayer.is_server():
		var new_puppet = puppet_scene.instantiate()
		add_child(new_puppet, true)
