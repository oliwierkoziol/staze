extends Node

signal session_ready(peer: MultiplayerPeer, room_code: String)
signal connection_failed(reason: String)

const STUN_SERVER := "stun:stun.l.google.com:19302"

var _socket: WebSocketPeer = WebSocketPeer.new()
var _as_host := false
var _room_code := ""
var _peer: WebRTCMultiplayerPeer
var _poll_timer: Timer
var _signaling_url := ""
var _socket_ready := false


func start(url: String, as_host: bool, join_code: String = "") -> void:
	_as_host = as_host
	_room_code = join_code
	_signaling_url = url
	var err := _socket.connect_to_url(url)
	if err != OK:
		connection_failed.emit("Nie udalo sie polaczyc z serwerem sygnalizacji")
		return
	_poll_timer = Timer.new()
	_poll_timer.wait_time = 0.05
	_poll_timer.timeout.connect(_poll)
	add_child(_poll_timer)
	_poll_timer.start()


func _poll() -> void:
	_socket.poll()
	var state := _socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN and not _socket_ready:
		_socket_ready = true
		if _as_host:
			_send({"type": "create_room"})
		else:
			_send({"type": "join_room", "room_code": _room_code})
	if state == WebSocketPeer.STATE_CLOSING or state == WebSocketPeer.STATE_CLOSED:
		if _peer == null:
			connection_failed.emit("Polaczenie z serwerem sygnalizacji zostalo zamkniete")
		return
	while _socket.get_available_packet_count() > 0:
		var packet: PackedByteArray = _socket.get_packet()
		if _socket.was_string_packet():
			_handle_message(JSON.parse_string(packet.get_string_from_utf8()))


func _handle_message(data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var message: Dictionary = data
	match str(message.get("type", "")):
		"room_created":
			_room_code = str(message.get("room_code", ""))
			_setup_webrtc_host()
		"room_joined":
			_room_code = str(message.get("room_code", ""))
			_setup_webrtc_client()
		"room_error":
			connection_failed.emit(str(message.get("reason", "Nie udalo sie dolaczyc do pokoju")))
		"signal":
			_handle_signal(message)


func _send(payload: Dictionary) -> void:
	if _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	_socket.send_text(JSON.stringify(payload))


func _setup_webrtc_host() -> void:
	_peer = WebRTCMultiplayerPeer.new()
	var err := _peer.create_mesh(1)
	if err != OK:
		connection_failed.emit("Nie udalo sie utworzyc sesji WebRTC")
		return
	multiplayer.multiplayer_peer = _peer
	var peer_connection: WebRTCPeerConnection = _peer.get_peer(1)
	if peer_connection == null:
		connection_failed.emit("Brak polaczenia WebRTC")
		return
	peer_connection.initialize({"iceServers": [{"urls": [STUN_SERVER]}]})
	peer_connection.session_description_created.connect(_on_host_sdp_created.bind(1))
	peer_connection.ice_candidate_created.connect(_on_ice_candidate_created.bind(1))
	peer_connection.create_offer()
	session_ready.emit(_peer, _room_code)


func _setup_webrtc_client() -> void:
	_peer = WebRTCMultiplayerPeer.new()
	var err := _peer.create_client(1)
	if err != OK:
		connection_failed.emit("Nie udalo sie utworzyc klienta WebRTC")
		return
	multiplayer.multiplayer_peer = _peer
	var peer_connection: WebRTCPeerConnection = _peer.get_peer(1)
	if peer_connection == null:
		connection_failed.emit("Brak polaczenia WebRTC")
		return
	peer_connection.initialize({"iceServers": [{"urls": [STUN_SERVER]}]})
	peer_connection.session_description_created.connect(_on_client_sdp_created)
	peer_connection.ice_candidate_created.connect(_on_ice_candidate_created.bind(1))


func _on_host_sdp_created(type: String, sdp: String, _peer_id: int) -> void:
	var peer_connection: WebRTCPeerConnection = _peer.get_peer(1)
	if peer_connection != null:
		peer_connection.set_local_description(type, sdp)
	_send({"type": "signal", "room_code": _room_code, "payload": {"kind": "offer", "sdp": sdp, "type": type}})


func _on_client_sdp_created(type: String, sdp: String) -> void:
	var peer_connection: WebRTCPeerConnection = _peer.get_peer(1)
	if peer_connection != null:
		peer_connection.set_local_description(type, sdp)
		_send({"type": "signal", "room_code": _room_code, "payload": {"kind": "answer", "sdp": sdp, "type": type}})


func _on_ice_candidate_created(media: String, index: int, name: String, candidate: String, _peer_id: int) -> void:
	_send({
		"type": "signal",
		"room_code": _room_code,
		"payload": {"kind": "ice", "media": media, "index": index, "name": name, "candidate": candidate},
	})


func _handle_signal(message: Dictionary) -> void:
	var payload: Dictionary = message.get("payload", {})
	if typeof(payload) != TYPE_DICTIONARY:
		return
	var peer_connection: WebRTCPeerConnection = _peer.get_peer(1) if _peer != null else null
	if peer_connection == null:
		return
	match str(payload.get("kind", "")):
		"offer":
			peer_connection.set_remote_description(str(payload.get("type", "offer"), str(payload.get("sdp", ""))))
			peer_connection.create_answer()
			if not _as_host:
				session_ready.emit(_peer, _room_code)
		"answer":
			peer_connection.set_remote_description(str(payload.get("type", "answer"), str(payload.get("sdp", ""))))
		"ice":
			peer_connection.add_ice_candidate(str(payload.get("media", "")), int(payload.get("index", 0)), str(payload.get("name", "")), str(payload.get("candidate", "")))


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _poll_timer != null and is_instance_valid(_poll_timer):
		_poll_timer.stop()
