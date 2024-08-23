extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var puppet_scene: PackedScene
var effect
var recording
#var analyzer_instance
var idx
var bus_name = "Record"
var bus_index
var spectrum_analyzer
var analyzer_instance

func _ready():
	print(AudioServer.get_input_device_list())
	AudioServer.set_input_device("Microphone (4- USB PnP Audio Device)")
	bus_index = AudioServer.get_bus_index(bus_name)
	# Add AudioEffectSpectrumAnalyzer to the bus
	#spectrum_analyzer = AudioEffectSpectrumAnalyzer.new()
	#AudioServer.add_bus_effect(bus_index, spectrum_analyzer)
	# Get the instance of the analyzer
	analyzer_instance = AudioServer.get_bus_effect_instance(bus_index, AudioServer.get_bus_effect_count(bus_index) - 1)
	# Set up AudioStreamPlayer with microphone input
	var mic_player = AudioStreamPlayer.new()
	mic_player.stream = AudioStreamMicrophone.new()
	add_child(mic_player)
	mic_player.play()

func _process(_delta):
	if analyzer_instance:
		var magnitude = analyzer_instance.get_magnitude_for_frequency_range(0, 10000)
		
		print("Volume (linear):", magnitude)
		
func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(_add_player)
	%Host.hide()
	%Join.hide()

func _on_join_pressed():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
	%Host.hide()
	%Join.hide()

func _on_spawn_puppet_pressed() -> void:
	_spawn_puppet.rpc()
		
		
@rpc("any_peer", "call_local")
func _spawn_puppet():
	if multiplayer.is_server():
		var new_puppet = puppet_scene.instantiate()
		add_child(new_puppet, true)
