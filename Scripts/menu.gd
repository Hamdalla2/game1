extends Control

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
var t = 0

func _ready():
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	peer.lobby_created.connect(_on_lobby_created)
	peer.peer_connected.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	getLobbies()

func _process(delta: float):
	Steam.run_callbacks()
	t += delta
	if t >= 1.0:
		t -= 1.0
		getLobbies()
	$FPS.text = str(Engine.get_frames_per_second())

func _on_button_pressed():
	if lobby_id == 0:
		$Button.disabled = true
		peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	else:
		peer.connect_lobby(lobby_id)

func _on_lobby_joined(_id):
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_lobby_created(connected, id):
	if connected:
		multiplayer.multiplayer_peer = peer
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", "game1sever")
		Steam.setLobbyJoinable(lobby_id, true)
		get_tree().change_scene_to_file("res://Scenes/level.tscn")
	else:
		$Button.disabled = false

func _on_lobby_match_list(lobbies):
	if lobbies.size() > 0:
		for lobby in lobbies:
			lobby_id = lobby
			$Server.text = "online"
			$Server.add_theme_color_override("font_color", "00ee00")
	else:
		lobby_id = 0
		$Server.text = "offline"
		$Server.add_theme_color_override("font_color", "ee0000")

func getLobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("name", "game1sever", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
