extends Control

const SAMPLE_UNITS := [
	{
		"id": 1,
		"name": "Miecznicy",
		"short_name": "MI",
		"role": "Piechota ciezka",
		"side": "player",
		"count": 24,
		"hp": 35,
		"dmg": 7,
		"def": 7,
		"speed": 5,
		"move_range": 4,
		"attack_range": 1,
		"action_name": "Ciecie",
		"skill_names": ["Tarcza", "Szarza", "Mur stali"],
		"resistance": "Ogien 10%",
		"buffs": "Brak",
		"debuffs": "Brak",
		"grid_x": 0,
		"grid_y": 3
	},
	{
		"id": 2,
		"name": "Lucznicy",
		"short_name": "LU",
		"role": "Strzelcy",
		"side": "player",
		"count": 18,
		"hp": 22,
		"dmg": 5,
		"def": 4,
		"speed": 6,
		"move_range": 3,
		"attack_range": 6,
		"action_name": "Strzal",
		"skill_names": ["Precyzja", "Grad strzal", "Odskok"],
		"resistance": "Lod 15%",
		"buffs": "Brak",
		"debuffs": "Brak",
		"grid_x": 0,
		"grid_y": 7
	},
	{
		"id": 3,
		"name": "Pikinierzy",
		"short_name": "PI",
		"role": "Piechota defensywna",
		"side": "player",
		"count": 20,
		"hp": 30,
		"dmg": 6,
		"def": 8,
		"speed": 4,
		"move_range": 3,
		"attack_range": 2,
		"action_name": "Pchniecie pika",
		"skill_names": ["Mur pik", "Kontratak", "Utrzymanie linii"],
		"resistance": "Szarza 25%",
		"buffs": "Premia przeciw kawalerii",
		"debuffs": "Slabszy w zwarciu bocznym",
		"grid_x": 0,
		"grid_y": 1
	},
	{
		"id": 4,
		"name": "Kawaleria",
		"short_name": "KA",
		"role": "Uderzenie mobilne",
		"side": "player",
		"count": 12,
		"hp": 42,
		"dmg": 10,
		"def": 6,
		"speed": 8,
		"move_range": 7,
		"attack_range": 1,
		"action_name": "Szarza",
		"skill_names": ["Tratowanie", "Odskok", "Przelamanie"],
		"resistance": "Morale 15%",
		"buffs": "Pierwszy atak +2 DMG",
		"debuffs": "Brak",
		"grid_x": 0,
		"grid_y": 5
	},
	{
		"id": 5,
		"name": "Asasyni",
		"short_name": "AS",
		"role": "Zabojcy",
		"side": "player",
		"count": 8,
		"hp": 18,
		"dmg": 14,
		"def": 3,
		"speed": 9,
		"move_range": 5,
		"attack_range": 1,
		"action_name": "Skrytobojstwo",
		"skill_names": ["Dym", "Krwawienie", "Zanik"],
		"resistance": "Trucizna 35%",
		"buffs": "Premia z pierwszego ciosu",
		"debuffs": "Niska wytrzymalosc",
		"grid_x": 0,
		"grid_y": 9
	},
	{
		"id": 6,
		"name": "Wilczy jezdzcy",
		"short_name": "WJ",
		"role": "Najezdzcy",
		"side": "enemy",
		"count": 16,
		"hp": 28,
		"dmg": 8,
		"def": 5,
		"speed": 7,
		"move_range": 6,
		"attack_range": 1,
		"action_name": "Rozdarcie",
		"skill_names": ["Doskok", "Krzyk", "Szal"],
		"resistance": "Trucizna 20%",
		"buffs": "Brak",
		"debuffs": "Brak",
		"grid_x": 14,
		"grid_y": 3
	},
	{
		"id": 7,
		"name": "Szamani",
		"short_name": "SZ",
		"role": "Wsparcie",
		"side": "enemy",
		"count": 9,
		"hp": 26,
		"dmg": 10,
		"def": 3,
		"speed": 6,
		"move_range": 3,
		"attack_range": 5,
		"action_name": "Piorun",
		"skill_names": ["Totem", "Iskra", "Burza"],
		"resistance": "Elektrycznosc 25%",
		"buffs": "Brak",
		"debuffs": "Brak",
		"grid_x": 14,
		"grid_y": 7
	}
]

const GRID_COLUMNS := 15
const GRID_ROWS := 11
const OBSTACLE_TYPES: Array[String] = ["woda", "kamienie", "drzewa"]
const MAX_EVENT_LOG_ENTRIES := 60
const CARD_FONT_COLOR := Color(0.92, 0.88, 0.78, 1.0)
const CARD_SELECTED_FONT_COLOR := Color(0.99, 0.95, 0.84, 1.0)
const LOG_COLOR_YELLOW := Color(0.95, 0.82, 0.25, 1.0)
const LOG_COLOR_PLAYER := Color(0.35, 0.65, 0.95, 1.0)
const LOG_COLOR_ENEMY := Color(0.92, 0.35, 0.30, 1.0)
const LOG_COLOR_DAMAGE := Color(0.92, 0.35, 0.30, 1.0)

@onready var board: Node2D = $BattleLayer/PlanszaWalki
@onready var hud: CanvasLayer = $HUD
@onready var turn_queue_list: HBoxContainer = $HUD/Overlay/TopBar/TopMargin/TopQueueScroll/TopQueueList
@onready var unit_name_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitName
@onready var unit_meta_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitMeta
@onready var unit_stats_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitStatsPanel/UnitStatsMargin/UnitStats
@onready var actions_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/ActionsPanel/ActionsMargin/ActionsLabel
@onready var action_attack_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/AttackActionButton
@onready var action_skill_1_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/Skill1ActionButton
@onready var action_skill_2_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/Skill2ActionButton
@onready var action_skill_3_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/Skill3ActionButton
@onready var end_turn_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/EndTurnButton
@onready var general_name_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralName
@onready var general_level_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralLevel
@onready var general_skills_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralSkillsPanel/GeneralSkillsMargin/GeneralSkills
@onready var general_rule_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralRule
@onready var event_log_scroll: ScrollContainer = $HUD/Overlay/RightPanel/RightMargin/RightContent/EventLogPanel/EventLogScroll
@onready var event_log_label: RichTextLabel = $HUD/Overlay/RightPanel/RightMargin/RightContent/EventLogPanel/EventLogScroll/EventLog

var units: Array = []
var obstacles: Array[Dictionary] = []
var selected_unit_id := -1
var active_unit_id := -1
var current_turn := ""
var is_animating := false
var event_log: Array[String] = []
var round_number := 1
var turn_queue: Array[int] = []
var turn_queue_index := -1
var pending_action := ""


func _ready() -> void:
	_validate_setup()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disable_hud_mouse(hud)
	units = SAMPLE_UNITS.map(func(unit: Dictionary) -> Dictionary: return unit.duplicate(true))
	for unit in units:
		unit.remaining_move = int(unit.move_range)
		unit.action_points = 1
	board.set_units(units)
	obstacles = _generate_obstacles()
	board.set_obstacles(obstacles)
	board.cell_clicked.connect(_on_cell_clicked)
	board.cell_right_clicked.connect(_on_cell_right_clicked)
	board.animation_finished.connect(_on_board_animation_finished)
	action_attack_button.pressed.connect(_on_attack_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	general_name_label.text = "KAPITAN ALARIC"
	general_level_label.text = "Poziom 5"
	general_skills_label.text = "\n".join([
		"Szarza bojowa: sojusznicy zyskuja +25% DMG na 2 tury.",
		"Wezwanie bastionu: +3 DEF i odpornosc na oslabienie na 2 tury."
	])
	event_log_label.bbcode_enabled = true
	_log_event(_color_log_text("Bitwa rozpoczeta.", LOG_COLOR_YELLOW))
	_rebuild_turn_queue()
	_start_next_activation()


func _on_unit_selected(unit_data: Dictionary) -> void:
	if is_animating:
		return
 
	_show_unit_details(unit_data)


func _show_unit_details(unit_data: Dictionary) -> void:
	selected_unit_id = unit_data.id
	board.set_selected_unit(unit_data.id)
	if unit_data.side == "player":
		_update_highlighted_cells(unit_data)
	else:
		board.set_highlighted_cells([], [])
	_render_unit_details(unit_data)
	_update_action_buttons()
	_refresh_turn_queue()


func _render_unit_details(unit_data: Dictionary) -> void:
	unit_name_label.text = unit_data.name.to_upper()
	unit_meta_label.text = "Poziom 1 - %s - %s" % [unit_data.role, "Gracz" if unit_data.side == "player" else "Przeciwnik"]
	unit_stats_label.text = "\n".join([
		"HP  %s" % unit_data.hp,
		"DMG %s" % unit_data.dmg,
		"DEF %s" % unit_data.def,
		"Szybkosc %s" % unit_data.speed,
		"Liczebnosc  %s" % unit_data.count,
		"Ruch  %s / %s" % [_get_display_move(unit_data), unit_data.move_range],
		"Punkty akcji  %s" % _get_display_action_points(unit_data),
		"Zasieg ataku  %s" % unit_data.attack_range,
		"",
		"Odpornosci  %s" % unit_data.resistance,
		"Buffy  %s" % unit_data.buffs,
		"Debuffy  %s" % unit_data.debuffs
	])
	actions_label.text = "\n".join([
		"Atak podstawowy: %s" % unit_data.action_name,
		"Umiejetnosci: %s" % ", ".join(unit_data.skill_names)
	])
	_update_action_placeholders(unit_data)


func _on_cell_clicked(cell: Vector2i) -> void:
	if is_animating or not _is_player_turn():
		return

	var active_unit := _get_active_unit()
	if active_unit.is_empty() or active_unit.side != "player":
		return

	var clicked_unit := _find_unit_at_cell(cell)
	if not clicked_unit.is_empty():
		if clicked_unit.side == "player":
			selected_unit_id = clicked_unit.id
			_show_unit_details(clicked_unit)
		return

	if pending_action == "attack":
		if not clicked_unit.is_empty() and clicked_unit.side != active_unit.side and _can_unit_attack(active_unit) and _is_in_attack_range(active_unit, cell):
			_perform_basic_attack(active_unit, clicked_unit)
		return

	if selected_unit_id != active_unit.id:
		selected_unit_id = active_unit.id
		_show_unit_details(active_unit)

	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell)
	if path.is_empty() or path.size() > _get_remaining_move(active_unit):
		return

	is_animating = true
	active_unit.grid_x = cell.x
	active_unit.grid_y = cell.y
	active_unit.remaining_move = max(0, _get_remaining_move(active_unit) - path.size())
	pending_action = ""
	_sync_board()
	board.animate_unit_path(active_unit.id, path)
	await board.animation_finished
	_log_event("%s przemieszcza sie." % _unit_name_log_text(active_unit))
	_sync_board()
	if not _can_unit_continue_turn(active_unit):
		_end_current_activation()


func _on_cell_right_clicked(cell: Vector2i) -> void:
	return


func _end_current_activation() -> void:
	pending_action = ""
	selected_unit_id = -1
	board.set_selected_unit(-1)
	board.set_highlighted_cells([], [])
	_update_action_buttons()
	_start_next_activation()


func _enemy_take_turn() -> void:
	var enemy_unit := _get_active_unit()
	if enemy_unit.is_empty() or enemy_unit.side != "enemy":
		return

	var target := _find_nearest_player_unit(enemy_unit)
	if target.is_empty():
		_end_current_activation()
		return

	var best_path := _find_best_enemy_path(enemy_unit, target)
	if not best_path.is_empty():
		var destination: Vector2i = best_path[best_path.size() - 1]
		is_animating = true
		enemy_unit.grid_x = destination.x
		enemy_unit.grid_y = destination.y
		enemy_unit.remaining_move = max(0, _get_remaining_move(enemy_unit) - best_path.size())
		_sync_board()
		board.animate_unit_path(enemy_unit.id, best_path)
		await board.animation_finished
		_log_event("%s przemieszcza sie." % _unit_name_log_text(enemy_unit))

	target = _find_nearest_player_unit(enemy_unit)
	if not enemy_unit.is_empty() and not target.is_empty() and _can_unit_attack(enemy_unit) and _is_in_attack_range(enemy_unit, Vector2i(target.grid_x, target.grid_y)):
		_perform_basic_attack(enemy_unit, target, false)
		_end_current_activation()
		return

	_end_current_activation()


func _find_unit_by_id(unit_id: int) -> Dictionary:
	for unit in units:
		if unit.id == unit_id:
			return unit
	return {}


func _find_unit_at_cell(cell: Vector2i) -> Dictionary:
	for unit in units:
		if unit.grid_x == cell.x and unit.grid_y == cell.y:
			return unit
	return {}


func _find_nearest_player_unit(enemy_unit: Dictionary) -> Dictionary:
	var nearest: Dictionary = {}
	var best_distance: float = INF
	for unit in units:
		if unit.side != "player":
			continue

		var distance: int = _hex_distance(
			Vector2i(enemy_unit.grid_x, enemy_unit.grid_y),
			Vector2i(unit.grid_x, unit.grid_y)
		)
		if distance < best_distance:
			best_distance = distance
			nearest = unit
	return nearest


func _find_best_enemy_path(enemy_unit: Dictionary, target: Dictionary) -> Array[Vector2i]:
	var reachable_cells: Array[Vector2i] = _get_reachable_cells(enemy_unit, _get_remaining_move(enemy_unit))
	var best_path: Array[Vector2i] = []
	var best_distance: int = _hex_distance(Vector2i(enemy_unit.grid_x, enemy_unit.grid_y), Vector2i(target.grid_x, target.grid_y))
	for cell in reachable_cells:
		var candidate_path: Array[Vector2i] = _find_path(enemy_unit, Vector2i(enemy_unit.grid_x, enemy_unit.grid_y), cell)
		if candidate_path.is_empty():
			continue

		var candidate_distance: int = _hex_distance(cell, Vector2i(target.grid_x, target.grid_y))
		if candidate_distance < best_distance:
			best_distance = candidate_distance
			best_path = candidate_path
	return best_path


func _sync_board() -> void:
	board.set_units(units)
	board.set_obstacles(obstacles)
	var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
	if selected_unit.is_empty():
		board.set_highlighted_cells([], [])
	else:
		_update_highlighted_cells(selected_unit)
		_render_unit_details(selected_unit)
	_update_turn_label()
	_update_action_buttons()
	_refresh_turn_queue()


func _update_turn_label() -> void:
	var active_unit := _get_active_unit()
	var turn_name := "Brak"
	if current_turn == "player":
		turn_name = "Gracz"
	elif current_turn == "enemy":
		turn_name = "Przeciwnik"
	var active_name: String = active_unit.name if not active_unit.is_empty() else "-"
	general_rule_label.text = "Aktywna jednostka: %s (%s)\nLPM porusza albo wybiera cel ataku. PPM pokazuje statystyki. Tura %s." % [active_name, turn_name, round_number]


func _update_highlighted_cells(unit: Dictionary) -> void:
	if unit.is_empty() or unit.side != "player":
		board.set_highlighted_cells([], [])
		return

	var move_budget: int = unit.move_range if unit.id != active_unit_id else _get_remaining_move(unit)
	var attack_cells: Array[Vector2i] = []
	if unit.id == active_unit_id and pending_action == "attack":
		attack_cells = _get_attackable_enemy_cells(unit)
	board.set_highlighted_cells(_get_reachable_cells(unit, move_budget), attack_cells)


func _get_reachable_cells(unit: Dictionary, max_distance: int) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var blocked: Dictionary = _get_blocked_cells(unit.id)
	var distances: Dictionary = {origin: 0}
	var frontier: Array[Vector2i] = [origin]
	var reachable: Array[Vector2i] = []

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_distance: int = distances[current]
		if current_distance >= max_distance:
			continue

		for neighbor in _get_neighbors(current):
			if blocked.has(neighbor) or distances.has(neighbor):
				continue
			distances[neighbor] = current_distance + 1
			frontier.append(neighbor)
			reachable.append(neighbor)

	return reachable


func _get_attackable_cells(unit: Dictionary) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var attackable: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if cell == origin:
				continue
			if _hex_distance(origin, cell) <= int(unit.attack_range):
				attackable.append(cell)
	return attackable


func _get_attackable_enemy_cells(unit: Dictionary) -> Array[Vector2i]:
	if not _can_unit_attack(unit):
		return []

	var attackable: Array[Vector2i] = []
	for other in units:
		if other.side == unit.side:
			continue
		var cell := Vector2i(other.grid_x, other.grid_y)
		if _is_in_attack_range(unit, cell):
			attackable.append(cell)
	return attackable


func _is_in_attack_range(unit: Dictionary, cell: Vector2i) -> bool:
	if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(unit.attack_range):
		return false
	return not _is_attack_blocked(unit, cell)


func _perform_basic_attack(attacker: Dictionary, target: Dictionary, end_turn_after := true) -> void:
	attacker.action_points = max(0, int(attacker.get("action_points", 0)) - 1)
	pending_action = ""
	var casualties: int = _calculate_casualties(attacker, target)
	target.count = max(0, int(target.count) - casualties)
	_log_event(
		"%s uderza %s i zadaje %s strat." % [
			_unit_name_log_text(attacker),
			_unit_name_log_text(target),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	if target.count <= 0:
		_log_event("%s zostaje rozbite." % _unit_name_log_text(target))
		units.erase(target)
		turn_queue.erase(target.id)
		if turn_queue_index >= turn_queue.size():
			turn_queue_index = turn_queue.size() - 1
	if target.id == selected_unit_id:
		selected_unit_id = attacker.id if attacker.side == "player" else -1
	_sync_board()
	if end_turn_after:
		_end_current_activation()


func _calculate_casualties(attacker: Dictionary, target: Dictionary) -> int:
	var damage_per_unit: int = max(1, int(attacker.dmg) - int(target.def))
	var total_damage: int = damage_per_unit * int(attacker.count)
	return max(1, int(total_damage / max(1, int(target.hp))))


func _find_path(unit: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	if start == goal:
		return []

	var blocked: Dictionary = _get_blocked_cells(unit.id)
	if blocked.has(goal):
		return []

	var came_from: Dictionary = {start: start}
	var frontier: Array[Vector2i] = [start]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == goal:
			break

		for neighbor in _get_neighbors(current):
			if blocked.has(neighbor) or came_from.has(neighbor):
				continue
			came_from[neighbor] = current
			frontier.append(neighbor)

	if not came_from.has(goal):
		return []

	var path: Array[Vector2i] = []
	var step: Vector2i = goal
	while step != start:
		path.push_front(step)
		step = came_from[step]
	return path


func _generate_obstacles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var occupied: Dictionary = {}
	for unit in SAMPLE_UNITS:
		occupied[Vector2i(unit.grid_x, unit.grid_y)] = true

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var type_count: int = rng.randi_range(2, OBSTACLE_TYPES.size())
	var shuffled_types: Array[String] = OBSTACLE_TYPES.duplicate()
	shuffled_types.shuffle()

	for type_index in range(type_count):
		var type: String = shuffled_types[type_index]
		var cluster_size: int = rng.randi_range(1, 4)
		var cluster: Array[Vector2i] = _generate_cluster(cluster_size, occupied, rng)
		for cell in cluster:
			occupied[cell] = true
			result.append({"grid_x": cell.x, "grid_y": cell.y, "type": type})
	return result


func _generate_cluster(target_size: int, occupied: Dictionary, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var attempts: int = 0
	while attempts < 200:
		attempts += 1
		var start: Vector2i = _random_empty_cell(occupied, rng)
		if start == Vector2i(-1, -1):
			continue
		var cluster: Array[Vector2i] = [start]
		var frontier: Array[Vector2i] = [start]
		occupied[start] = true
		while cluster.size() < target_size and not frontier.is_empty():
			frontier.shuffle()
			var current: Vector2i = frontier.pop_front()
			var neighbors: Array[Vector2i] = _get_neighbors(current)
			neighbors.shuffle()
			for neighbor in neighbors:
				if occupied.has(neighbor):
					continue
				occupied[neighbor] = true
				cluster.append(neighbor)
				frontier.append(neighbor)
				if cluster.size() >= target_size:
					break
		return cluster
	return []


func _random_empty_cell(occupied: Dictionary, rng: RandomNumberGenerator) -> Vector2i:
	var x_min: int = 2
	var x_max: int = GRID_COLUMNS - 3
	var attempts: int = 0
	while attempts < 100:
		attempts += 1
		var cell := Vector2i(rng.randi_range(x_min, x_max), rng.randi_range(0, GRID_ROWS - 1))
		if not occupied.has(cell):
			return cell
	return Vector2i(-1, -1)


func _get_blocked_cells(excluded_unit_id: int) -> Dictionary:
	var blocked: Dictionary = {}
	for unit in units:
		if unit.id == excluded_unit_id:
			continue
		blocked[Vector2i(unit.grid_x, unit.grid_y)] = true
	for obstacle in obstacles:
		blocked[Vector2i(int(obstacle.grid_x), int(obstacle.grid_y))] = true
	return blocked


func _is_cell_obstacle(cell: Vector2i) -> bool:
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y:
			return true
	return false


func _is_attack_blocked(attacker: Dictionary, target_cell: Vector2i) -> bool:
	var origin: Vector2i = Vector2i(attacker.grid_x, attacker.grid_y)
	if origin == target_cell:
		return false
	var line_cells: Array[Vector2i] = _get_hex_line(origin, target_cell)
	for cell in line_cells:
		if cell == origin or cell == target_cell:
			continue
		if _is_cell_obstacle(cell):
			return true
	return false


func _get_hex_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var start_cube: Vector3i = _oddr_to_cube(start)
	var end_cube: Vector3i = _oddr_to_cube(end)
	var distance: int = _hex_distance(start, end)
	if distance == 0:
		return [start]
	var line: Array[Vector2i] = []
	for step in range(distance + 1):
		var t: float = float(step) / float(distance)
		var cube: Vector3i = _cube_round(_cube_lerp(start_cube, end_cube, t))
		line.append(_cube_to_oddr(cube))
	return line


func _cube_lerp(a: Vector3i, b: Vector3i, t: float) -> Vector3:
	return Vector3(lerpf(a.x, b.x, t), lerpf(a.y, b.y, t), lerpf(a.z, b.z, t))


func _cube_round(cube: Vector3) -> Vector3i:
	var rx: int = int(round(cube.x))
	var ry: int = int(round(cube.y))
	var rz: int = int(round(cube.z))
	var dx: float = absf(rx - cube.x)
	var dy: float = absf(ry - cube.y)
	var dz: float = absf(rz - cube.z)
	if dx > dy and dx > dz:
		rx = -ry - rz
	elif dy > dz:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector3i(rx, ry, rz)


func _cube_to_oddr(cube: Vector3i) -> Vector2i:
	var x: int = cube.x + int((cube.z - (cube.z & 1)) / 2)
	return Vector2i(x, cube.z)


func _get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var offsets: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0)
	]
	if cell.y % 2 == 0:
		offsets.append_array([
			Vector2i(0, -1),
			Vector2i(-1, -1),
			Vector2i(0, 1),
			Vector2i(-1, 1)
		])
	else:
		offsets.append_array([
			Vector2i(1, -1),
			Vector2i(0, -1),
			Vector2i(1, 1),
			Vector2i(0, 1)
		])

	var neighbors: Array[Vector2i] = []
	for offset in offsets:
		var next: Vector2i = cell + offset
		if next.x >= 0 and next.x < GRID_COLUMNS and next.y >= 0 and next.y < GRID_ROWS:
			neighbors.append(next)
	return neighbors


func _disable_hud_mouse(node: Node) -> void:
	if node is Control:
		if node is BaseButton:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in node.get_children():
		_disable_hud_mouse(child)


func _validate_setup() -> void:
	for unit in SAMPLE_UNITS:
		assert(unit.grid_x >= 0 and unit.grid_x < GRID_COLUMNS)
		assert(unit.grid_y >= 0 and unit.grid_y < GRID_ROWS)
		assert(unit.dmg >= 1)
		assert(unit.speed >= 1)

	for obstacle in obstacles:
		assert(obstacle.grid_x >= 0 and obstacle.grid_x < GRID_COLUMNS)
		assert(obstacle.grid_y >= 0 and obstacle.grid_y < GRID_ROWS)
		assert(obstacle.type in ["woda", "kamienie", "drzewa"])
		for unit in SAMPLE_UNITS:
			assert(not (unit.grid_x == obstacle.grid_x and unit.grid_y == obstacle.grid_y), "Przeszkoda pokrywa sie z jednostka")

	assert(_hex_distance(Vector2i(0, 3), Vector2i(0, 7)) == _hex_distance(Vector2i(0, 7), Vector2i(0, 3)))
	assert(_get_attackable_cells(SAMPLE_UNITS[0]).has(Vector2i(1, 3)))
	assert(not _get_attackable_cells(SAMPLE_UNITS[0]).has(Vector2i(0, 3)))
	assert(_calculate_casualties(SAMPLE_UNITS[0], SAMPLE_UNITS[5]) >= 1)


func _on_board_animation_finished(_unit_id: int) -> void:
	is_animating = false
	_refresh_turn_queue()


func _update_action_buttons() -> void:
	var unit := _get_active_unit()
	var can_use_attack: bool = (
		not unit.is_empty()
		and _is_player_turn()
		and unit.side == "player"
		and _can_unit_attack(unit)
		and not _get_attackable_enemy_cells(unit).is_empty()
		and selected_unit_id == unit.id
	)
	action_attack_button.disabled = not can_use_attack
	action_attack_button.button_pressed = pending_action == "attack"
	action_attack_button.text = "ATAK PODSTAWOWY" if pending_action != "attack" else "WYBIERZ CEL"
	end_turn_button.disabled = not _is_player_turn() or unit.is_empty()


func _color_log_text(text: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(false), text]


func _unit_name_log_text(unit: Dictionary) -> String:
	var color: Color = LOG_COLOR_PLAYER if unit.side == "player" else LOG_COLOR_ENEMY
	return _color_log_text(unit.name, color)


func _log_event(text: String) -> void:
	event_log.append(text)
	while event_log.size() > MAX_EVENT_LOG_ENTRIES:
		event_log.pop_front()
	event_log_label.text = "\n".join(event_log)
	call_deferred("_scroll_event_log_to_bottom")


func _scroll_event_log_to_bottom() -> void:
	event_log_scroll.scroll_vertical = int(event_log_label.get_content_height())


func _refresh_turn_queue() -> void:
	for child in turn_queue_list.get_children():
		child.queue_free()

	for unit_id in _get_visible_turn_queue():
		var unit := _find_unit_by_id(unit_id)
		if unit.is_empty():
			continue

		var button := Button.new()
		button.custom_minimum_size = Vector2(124, 60)
		button.clip_text = true
		button.text = "%s\n%s %s\nSPD %s RUCH %s" % [
			unit.count,
			unit.short_name,
			unit.name,
			unit.speed,
			_get_display_move(unit)
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = is_animating
		button.add_theme_color_override("font_color", CARD_SELECTED_FONT_COLOR if unit.id == selected_unit_id else Color(0.95, 0.95, 0.92, 1.0))
		button.add_theme_stylebox_override("normal", _make_turn_queue_card_style(unit, unit.id == selected_unit_id))
		button.add_theme_stylebox_override("hover", _make_turn_queue_card_style(unit, unit.id == selected_unit_id, true))
		button.add_theme_stylebox_override("pressed", _make_turn_queue_card_style(unit, true, true))
		button.pressed.connect(_on_turn_queue_pressed.bind(unit.id))
		button.gui_input.connect(_on_turn_queue_gui_input.bind(unit.id))
		turn_queue_list.add_child(button)


func _on_turn_queue_pressed(unit_id: int) -> void:
	if is_animating:
		return

	var unit := _find_unit_by_id(unit_id)
	if unit.is_empty():
		return

	pending_action = ""
	_on_unit_selected(unit)


func _on_turn_queue_gui_input(event: InputEvent, unit_id: int) -> void:
	return


func _make_turn_queue_card_style(unit: Dictionary, selected: bool, hovered := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var player_bg := Color(0.09, 0.16, 0.26, 0.96)
	var enemy_bg := Color(0.24, 0.10, 0.10, 0.96)
	var selected_bg := Color(0.23, 0.19, 0.08, 0.98)
	var player_border := Color(0.35, 0.65, 0.95, 0.95)
	var enemy_border := Color(0.92, 0.35, 0.30, 0.95)
	var selected_border := Color(0.90, 0.77, 0.34, 1.0)

	style.bg_color = selected_bg if selected else player_bg if unit.side == "player" else enemy_bg
	style.border_color = selected_border if selected else player_border if unit.side == "player" else enemy_border
	if hovered and not selected:
		style.bg_color = style.bg_color.lightened(0.08)
		style.border_color = style.border_color.lightened(0.08)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	return style


func _update_action_placeholders(unit: Dictionary) -> void:
	var skills: Array = unit.get("skill_names", [])
	var labels: Array[String] = [
		"UM. 1\n%s" % _skill_name_at(skills, 0),
		"UM. 2\n%s" % _skill_name_at(skills, 1),
		"UM. 3\n%s" % _skill_name_at(skills, 2)
	]
	action_skill_1_button.text = labels[0]
	action_skill_2_button.text = labels[1]
	action_skill_3_button.text = labels[2]


func _skill_name_at(skills: Array, index: int) -> String:
	if index >= 0 and index < skills.size():
		return str(skills[index]).to_upper()
	return "PLACEHOLDER"


func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var ac: Vector3i = _oddr_to_cube(a)
	var bc: Vector3i = _oddr_to_cube(b)
	return int((abs(ac.x - bc.x) + abs(ac.y - bc.y) + abs(ac.z - bc.z)) / 2)


func _oddr_to_cube(cell: Vector2i) -> Vector3i:
	var x: int = cell.x - int((cell.y - (cell.y & 1)) / 2)
	var z: int = cell.y
	var y: int = -x - z
	return Vector3i(x, y, z)


func _rebuild_turn_queue() -> void:
	turn_queue = []
	for unit in units:
		turn_queue.append(int(unit.id))
	turn_queue.sort_custom(func(a: int, b: int) -> bool:
		var unit_a: Dictionary = _find_unit_by_id(a)
		var unit_b: Dictionary = _find_unit_by_id(b)
		if int(unit_a.speed) == int(unit_b.speed):
			if unit_a.side == unit_b.side:
				return a < b
			return unit_a.side == "player"
		return int(unit_a.speed) > int(unit_b.speed)
	)
	turn_queue_index = -1


func _start_next_activation() -> void:
	if not _has_units_on_side("player") or not _has_units_on_side("enemy"):
		active_unit_id = -1
		current_turn = ""
		selected_unit_id = -1
		board.set_selected_unit(-1)
		board.set_highlighted_cells([], [])
		_update_turn_label()
		_update_action_buttons()
		_refresh_turn_queue()
		return

	while true:
		if turn_queue.is_empty():
			_rebuild_turn_queue()
			if turn_queue.is_empty():
				return

		turn_queue_index += 1
		if turn_queue_index >= turn_queue.size():
			round_number += 1
			_rebuild_turn_queue()
			continue

		var next_unit := _find_unit_by_id(turn_queue[turn_queue_index])
		if next_unit.is_empty():
			turn_queue.remove_at(turn_queue_index)
			turn_queue_index -= 1
			continue

		_start_unit_activation(next_unit)
		return


func _start_unit_activation(unit: Dictionary) -> void:
	active_unit_id = unit.id
	current_turn = unit.side
	unit.remaining_move = int(unit.move_range)
	unit.action_points = 1
	pending_action = ""
	selected_unit_id = unit.id if unit.side == "player" else -1
	board.set_selected_unit(selected_unit_id)
	_sync_board()
	if unit.side == "enemy":
		_enemy_take_turn()


func _get_active_unit() -> Dictionary:
	return _find_unit_by_id(active_unit_id)


func _is_player_turn() -> bool:
	return current_turn == "player"


func _get_remaining_move(unit: Dictionary) -> int:
	return int(unit.get("remaining_move", unit.get("move_range", 0)))


func _get_display_move(unit: Dictionary) -> int:
	return _get_remaining_move(unit) if unit.id == active_unit_id else int(unit.move_range)


func _get_display_action_points(unit: Dictionary) -> int:
	return int(unit.get("action_points", 0)) if unit.id == active_unit_id else 1


func _can_unit_attack(unit: Dictionary) -> bool:
	return int(unit.get("action_points", 0)) > 0


func _can_unit_continue_turn(unit: Dictionary) -> bool:
	return _get_remaining_move(unit) > 0 or _can_unit_attack(unit)


func _has_units_on_side(side: String) -> bool:
	for unit in units:
		if unit.side == side:
			return true
	return false


func _get_visible_turn_queue() -> Array[int]:
	var visible_queue: Array[int] = []
	if turn_queue.is_empty():
		return visible_queue

	var start_index: int = maxi(turn_queue_index, 0)
	for offset in range(turn_queue.size()):
		var index: int = (start_index + offset) % turn_queue.size()
		visible_queue.append(turn_queue[index])
	return visible_queue


func _on_attack_button_pressed() -> void:
	if not _is_player_turn() or is_animating or action_attack_button.disabled:
		return

	var unit := _get_active_unit()
	if unit.is_empty():
		return

	pending_action = "" if pending_action == "attack" else "attack"
	selected_unit_id = unit.id
	_update_highlighted_cells(unit)
	_update_action_buttons()
	_refresh_turn_queue()


func _on_end_turn_pressed() -> void:
	if not _is_player_turn() or is_animating:
		return

	var unit := _get_active_unit()
	if unit.is_empty():
		return

	_end_current_activation()
