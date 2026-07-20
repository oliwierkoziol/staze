extends Node

var gra: Node = null


func setup(game: Node) -> void:
	gra = game


func is_ready() -> bool:
	return gra != null and MultiplayerManager.is_online()


@rpc("any_peer", "call_remote", "reliable")
func request_move(unit_id: int, q: int, r: int) -> void:
	if not MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.host_handle_move_request(unit_id, q, r)


@rpc("any_peer", "call_remote", "reliable")
func request_basic_attack(unit_id: int, target_id: int) -> void:
	if not MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.host_handle_attack_request(unit_id, target_id)


@rpc("any_peer", "call_remote", "reliable")
func request_skill(unit_id: int, skill_id: String, q: int, r: int) -> void:
	if not MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.host_handle_skill_request(unit_id, skill_id, Vector2i(q, r))


@rpc("any_peer", "call_remote", "reliable")
func request_general_skill(skill_id: String, q: int, r: int) -> void:
	if not MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.host_handle_general_skill_request(skill_id, Vector2i(q, r))


@rpc("any_peer", "call_remote", "reliable")
func request_end_turn() -> void:
	if not MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.host_handle_end_turn_request()


@rpc("any_peer", "call_remote", "reliable")
func request_start_match() -> void:
	if not MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.host_start_online_match()


@rpc("authority", "call_remote", "reliable")
func match_config(config: Dictionary) -> void:
	MultiplayerManager.match_config_received.emit(config)
	if gra == null:
		return
	gra.apply_online_match_config(config)


@rpc("authority", "call_remote", "reliable")
func state_sync(state: Dictionary) -> void:
	if MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.apply_remote_state(state)


@rpc("authority", "call_remote", "reliable")
func battle_ended(winner_side: String, reason: String = "") -> void:
	if gra == null:
		return
	gra.apply_online_battle_ended(winner_side, reason)


@rpc("authority", "call_remote", "reliable")
func peer_forfeit(winner_side: String) -> void:
	battle_ended.rpc(winner_side, "forfeit")


func send_move(unit_id: int, cell: Vector2i) -> void:
	request_move.rpc_id(1, unit_id, cell.x, cell.y)


func send_basic_attack(unit_id: int, target_id: int) -> void:
	request_basic_attack.rpc_id(1, unit_id, target_id)


func send_skill(unit_id: int, skill_id: String, cell: Vector2i) -> void:
	request_skill.rpc_id(1, unit_id, skill_id, cell.x, cell.y)


func send_general_skill(skill_id: String, cell: Vector2i) -> void:
	request_general_skill.rpc_id(1, skill_id, cell.x, cell.y)


func send_end_turn() -> void:
	request_end_turn.rpc_id(1)


func send_start_match() -> void:
	request_start_match.rpc_id(1)


func broadcast_match_config(config: Dictionary) -> void:
	match_config.rpc(config)


func broadcast_state() -> void:
	if not is_ready() or not MultiplayerManager.is_host() or gra == null:
		return
	state_sync.rpc(gra.capture_online_state())


func broadcast_battle_ended(winner_side: String) -> void:
	if not is_ready() or not MultiplayerManager.is_host():
		return
	battle_ended.rpc(winner_side, "")


@rpc("authority", "call_remote", "reliable")
func begin_battle(state: Dictionary) -> void:
	if MultiplayerManager.is_host():
		return
	if gra == null:
		return
	gra.apply_remote_state(state)


func broadcast_begin_battle() -> void:
	if not is_ready() or not MultiplayerManager.is_host() or gra == null:
		return
	begin_battle.rpc(gra.capture_online_state())


@rpc("any_peer", "call_remote", "reliable")
func request_setup_move(unit_id: int, q: int, r: int) -> void:
	if not MultiplayerManager.is_host() or gra == null:
		return
	gra.host_handle_setup_move_request(unit_id, q, r)


func send_setup_move(unit_id: int, cell: Vector2i) -> void:
	request_setup_move.rpc_id(1, unit_id, cell.x, cell.y)


func broadcast_forfeit(winner_side: String) -> void:
	if not is_ready() or not MultiplayerManager.is_host():
		return
	peer_forfeit.rpc(winner_side)
