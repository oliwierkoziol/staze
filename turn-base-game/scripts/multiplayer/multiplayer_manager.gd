extends Node

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal connection_failed(reason: String)
signal room_ready(room_code: String)
signal host_ready(port: int)
signal match_config_received(config: Dictionary)

const DEFAULT_PORT := 7777
const MAX_CLIENTS := 1
const STUN_SERVER := "stun:stun.l.google.com:19302"
const SIGNALING_URL := "ws://127.0.0.1:9090"

enum Role { NONE, HOST, CLIENT }

var role := Role.NONE
var local_side := "player"
var scenario_id := ""
var scenario_name := ""
var obstacle_seed := 0
var orc_general_is_kishak := false
var match_started := false
var room_code := ""
var transport := "none" # enet | webrtc

var _peer: MultiplayerPeer
var _signaling: Node


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func is_online() -> bool:
	return role != Role.NONE and multiplayer.multiplayer_peer != null


func is_host() -> bool:
	return role == Role.HOST


func is_client() -> bool:
	return role == Role.CLIENT


func get_local_peer_id() -> int:
	return multiplayer.get_unique_id()


func create_host_enet(port: int = DEFAULT_PORT) -> Error:
	_close_peer()
	var enet := ENetMultiplayerPeer.new()
	var err := enet.create_server(port, MAX_CLIENTS)
	if err != OK:
		connection_failed.emit("Nie udalo sie utworzyc serwera ENet (%s)" % error_string(err))
		return err
	_peer = enet
	multiplayer.multiplayer_peer = enet
	role = Role.HOST
	local_side = "player"
	transport = "enet"
	host_ready.emit(port)
	return OK


func join_host_enet(address: String, port: int = DEFAULT_PORT) -> Error:
	var normalized := _normalize_enet_address(address)
	if normalized == "":
		connection_failed.emit("Niepoprawny adres IP hosta. Uzyj np. 127.0.0.1 lub adres LAN.")
		return ERR_INVALID_PARAMETER
	_close_peer()
	var enet := ENetMultiplayerPeer.new()
	var err := enet.create_client(normalized, port)
	if err != OK:
		connection_failed.emit("Nie udalo sie polaczyc z %s:%d (%s)" % [normalized, port, error_string(err)])
		return err
	_peer = enet
	multiplayer.multiplayer_peer = enet
	role = Role.CLIENT
	local_side = "enemy"
	transport = "enet"
	return OK


func _normalize_enet_address(address: String) -> String:
	var trimmed := address.strip_edges()
	if trimmed.is_empty():
		return ""
	if trimmed.contains(":"):
		trimmed = trimmed.split(":", false, 1)[0].strip_edges()
	if trimmed.to_lower() == "localhost":
		return "127.0.0.1"
	if trimmed.is_valid_ip_address():
		return trimmed
	var resolved: String = IP.resolve_hostname(trimmed, IP.TYPE_IPV4)
	return resolved if resolved.is_valid_ip_address() else ""


func create_host_webrtc(signaling_url: String = SIGNALING_URL) -> void:
	_close_peer()
	transport = "webrtc"
	role = Role.HOST
	local_side = "player"
	_start_signaling(signaling_url, true)


func join_webrtc(room: String, signaling_url: String = SIGNALING_URL) -> void:
	_close_peer()
	transport = "webrtc"
	role = Role.CLIENT
	local_side = "enemy"
	room_code = room
	_start_signaling(signaling_url, false)


func disconnect_session() -> void:
	match_started = false
	scenario_id = ""
	scenario_name = ""
	obstacle_seed = 0
	room_code = ""
	role = Role.NONE
	transport = "none"
	_close_peer()


func set_lobby_scenario(id: String, name: String) -> void:
	scenario_id = id
	scenario_name = name


func prepare_match_seed() -> void:
	obstacle_seed = randi()


func _close_peer() -> void:
	if _signaling != null and is_instance_valid(_signaling):
		_signaling.queue_free()
		_signaling = null
	if _peer != null:
		_peer.close()
		_peer = null
	multiplayer.multiplayer_peer = null


func _start_signaling(url: String, as_host: bool) -> void:
	var script := load("res://scripts/multiplayer/signaling_client.gd")
	_signaling = Node.new()
	_signaling.set_script(script)
	add_child(_signaling)
	_signaling.session_ready.connect(_on_signaling_session_ready)
	_signaling.connection_failed.connect(_on_signaling_failed)
	_signaling.start(url, as_host, room_code)


func _on_signaling_session_ready(peer: MultiplayerPeer, code: String) -> void:
	_peer = peer
	multiplayer.multiplayer_peer = peer
	room_code = code
	room_ready.emit(code)


func _on_signaling_failed(reason: String) -> void:
	disconnect_session()
	connection_failed.emit(reason)


func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)


func _on_connected_to_server() -> void:
	peer_connected.emit(multiplayer.get_unique_id())


func _on_connection_failed() -> void:
	disconnect_session()
	connection_failed.emit("Polaczenie nieudane")


func _on_server_disconnected() -> void:
	disconnect_session()
	peer_disconnected.emit(1)
