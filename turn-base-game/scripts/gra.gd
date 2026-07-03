extends Control

const SAMPLE_UNITS := [
	{
		"id": 1,
		"name": "Miecznicy",
		"short_name": "MI",
		"side": "player",
		"count": 24,
		"hp": 35,
		"dmg": "5-8",
		"def": 7,
		"move_range": 4,
		"attack_range": 1,
		"action_name": "Ciecie",
		"skill_names": ["Tarcza", "Szarza", "Mur stali"],
		"cooldowns": [0, 2, 4],
		"resistance": "Ogien 10%",
		"buffs": "Obrona +2",
		"debuffs": "Brak",
		"grid_x": 0,
		"grid_y": 3
	},
	{
		"id": 2,
		"name": "Lucznicy",
		"short_name": "LU",
		"side": "player",
		"count": 18,
		"hp": 22,
		"dmg": "4-6",
		"def": 4,
		"move_range": 3,
		"attack_range": 6,
		"action_name": "Strzal",
		"skill_names": ["Precyzja", "Grad strzal", "Odskok"],
		"cooldowns": [0, 3, 2],
		"resistance": "Lod 15%",
		"buffs": "Cel +1",
		"debuffs": "Brak",
		"grid_x": 0,
		"grid_y": 7
	},
	{
		"id": 3,
		"name": "Wilczy jezdzcy",
		"short_name": "WJ",
		"side": "enemy",
		"count": 16,
		"hp": 28,
		"dmg": "6-10",
		"def": 5,
		"move_range": 6,
		"attack_range": 1,
		"action_name": "Rozdarcie",
		"skill_names": ["Doskok", "Krzyk", "Szal"],
		"cooldowns": [0, 2, 5],
		"resistance": "Trucizna 20%",
		"buffs": "Brak",
		"debuffs": "Atak -1",
		"grid_x": 14,
		"grid_y": 3
	},
	{
		"id": 4,
		"name": "Szamani",
		"short_name": "SZ",
		"side": "enemy",
		"count": 9,
		"hp": 26,
		"dmg": "8-12",
		"def": 3,
		"move_range": 3,
		"attack_range": 5,
		"action_name": "Piorun",
		"skill_names": ["Totem", "Iskra", "Burza"],
		"cooldowns": [1, 0, 4],
		"resistance": "Elektrycznosc 25%",
		"buffs": "Brak",
		"debuffs": "Morale -1",
		"grid_x": 14,
		"grid_y": 7
	}
]

const GRID_COLUMNS := 15
const GRID_ROWS := 11

@onready var board: Node2D = $BattleLayer/PlanszaWalki
@onready var hud: CanvasLayer = $HUD
@onready var unit_name_label: Label = $HUD/RootMargin/RootLayout/LeftPanel/LeftMargin/LeftContent/UnitName
@onready var unit_stats_label: Label = $HUD/RootMargin/RootLayout/LeftPanel/LeftMargin/LeftContent/UnitStats
@onready var basic_attack_button: Button = $HUD/RootMargin/RootLayout/LeftPanel/LeftMargin/LeftContent/BasicAttackButton
@onready var general_skills_label: Label = $HUD/RootMargin/RootLayout/RightPanel/RightMargin/RightContent/GeneralSkills
@onready var general_rule_label: Label = $HUD/RootMargin/RootLayout/RightPanel/RightMargin/RightContent/GeneralRule

var units: Array = []
var selected_unit_id := -1
var current_turn := "player"
var is_animating := false
var highlight_mode := "move"


func _ready() -> void:
	_validate_setup()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disable_hud_mouse(hud)
	units = SAMPLE_UNITS.map(func(unit: Dictionary) -> Dictionary: return unit.duplicate(true))
	board.set_units(units)
	board.unit_selected.connect(_on_unit_selected)
	board.cell_clicked.connect(_on_cell_clicked)
	board.cell_right_clicked.connect(_on_cell_right_clicked)
	board.animation_finished.connect(_on_board_animation_finished)
	basic_attack_button.pressed.connect(_on_basic_attack_button_pressed)
	general_skills_label.text = "Tura:\nGracz rusza jedna jednostka, potem rusza przeciwnik."
	_on_unit_selected(units[0])
	_update_turn_label()
	_update_basic_attack_button()


func _on_unit_selected(unit_data: Dictionary) -> void:
	if is_animating:
		return

	selected_unit_id = unit_data.id
	highlight_mode = "move"
	board.set_selected_unit(unit_data.id)
	_update_highlighted_cells(unit_data)
	_update_basic_attack_button()
	unit_name_label.text = "%s (%s)" % [unit_data.name, unit_data.side]
	unit_stats_label.text = "\n".join([
		"Liczebnosc: %s" % unit_data.count,
		"HP jednostki: %s" % unit_data.hp,
		"Obrazenia: %s" % unit_data.dmg,
		"Obrona: %s" % unit_data.def,
		"Ruch: %s" % unit_data.move_range,
		"Zasieg ataku: %s" % unit_data.attack_range,
		"Atak podstawowy: %s" % unit_data.action_name,
		"Umiejetnosci: %s" % ", ".join(unit_data.skill_names),
		"Cooldowny: %s" % ", ".join(unit_data.cooldowns.map(func(value: int) -> String: return str(value))),
		"Odpornosci: %s" % unit_data.resistance,
		"Buffy: %s" % unit_data.buffs,
		"Debuffy: %s" % unit_data.debuffs
	])


func _on_cell_clicked(cell: Vector2i) -> void:
	if is_animating:
		return

	var unit := _find_unit_by_id(selected_unit_id)
	if unit.is_empty():
		board.set_highlighted_cells([])
		return
	
	if highlight_mode == "attack":
		var target := _find_unit_at_cell(cell)
		if not target.is_empty() and target.side != unit.side and _is_in_attack_range(unit, cell):
			_perform_basic_attack(unit, target)
		return

	if cell.x == unit.grid_x and cell.y == unit.grid_y:
		_update_highlighted_cells(unit)
		return


func _on_cell_right_clicked(cell: Vector2i) -> void:
	if current_turn != "player" or is_animating:
		return

	var unit := _find_unit_by_id(selected_unit_id)
	if unit.is_empty() or unit.side != "player":
		return

	if highlight_mode == "attack":
		return

	var path := _find_path(unit, Vector2i(unit.grid_x, unit.grid_y), cell)
	if path.is_empty() or path.size() > int(unit.move_range):
		return

	is_animating = true
	unit.grid_x = cell.x
	unit.grid_y = cell.y
	_sync_board()
	board.animate_unit_path(unit.id, path)
	await board.animation_finished
	_end_player_turn()


func _end_player_turn() -> void:
	current_turn = "enemy"
	selected_unit_id = -1
	highlight_mode = "move"
	board.set_selected_unit(-1)
	board.set_highlighted_cells([])
	board.set_prioritize_cell_click_on_left(false)
	_update_basic_attack_button()
	_update_turn_label()
	_enemy_take_turn()


func _enemy_take_turn() -> void:
	var enemy_unit := _find_first_enemy_unit()
	if enemy_unit.is_empty():
		current_turn = "player"
		_update_turn_label()
		return

	var target := _find_nearest_player_unit(enemy_unit)
	if target.is_empty():
		current_turn = "player"
		_update_turn_label()
		return

	var best_path := _find_best_enemy_path(enemy_unit, target)
	if not best_path.is_empty():
		var destination: Vector2i = best_path[best_path.size() - 1]
		is_animating = true
		enemy_unit.grid_x = destination.x
		enemy_unit.grid_y = destination.y
		_sync_board()
		board.animate_unit_path(enemy_unit.id, best_path)
		await board.animation_finished

	target = _find_nearest_player_unit(enemy_unit)
	if not enemy_unit.is_empty() and not target.is_empty() and _is_in_attack_range(enemy_unit, Vector2i(target.grid_x, target.grid_y)):
		_perform_basic_attack(enemy_unit, target, false)

	current_turn = "player"
	_update_turn_label()

	var first_player: Dictionary = _find_first_player_unit()
	if not first_player.is_empty():
		_on_unit_selected(first_player)


func _find_unit_by_id(unit_id: int) -> Dictionary:
	for unit in units:
		if unit.id == unit_id:
			return unit
	return {}


func _find_first_enemy_unit() -> Dictionary:
	for unit in units:
		if unit.side == "enemy":
			return unit
	return {}


func _find_first_player_unit() -> Dictionary:
	for unit in units:
		if unit.side == "player":
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


func _is_occupied(cell: Vector2i) -> bool:
	for unit in units:
		if unit.grid_x == cell.x and unit.grid_y == cell.y:
			return true
	return false


func _find_best_enemy_path(enemy_unit: Dictionary, target: Dictionary) -> Array[Vector2i]:
	var reachable_cells: Array[Vector2i] = _get_reachable_cells(enemy_unit)
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
	var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
	if selected_unit.is_empty():
		board.set_highlighted_cells([])
	else:
		_update_highlighted_cells(selected_unit)
	_update_basic_attack_button()


func _update_turn_label() -> void:
	var turn_name: String = "Gracz" if current_turn == "player" else "Przeciwnik"
	general_rule_label.text = "Aktywna tura: %s\nKolejnosc: gracz -> przeciwnik -> gracz" % turn_name


func _update_highlighted_cells(unit: Dictionary) -> void:
	if unit.is_empty() or current_turn != "player" or unit.side != "player":
		board.set_highlighted_cells([])
		board.set_prioritize_cell_click_on_left(false)
		return
 
	if highlight_mode == "attack":
		board.set_highlighted_cells(_get_attackable_cells(unit), true)
		board.set_prioritize_cell_click_on_left(true)
		return

	board.set_highlighted_cells(_get_reachable_cells(unit))
	board.set_prioritize_cell_click_on_left(false)


func _get_reachable_cells(unit: Dictionary) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var blocked: Dictionary = _get_blocked_cells(unit.id)
	var distances: Dictionary = {origin: 0}
	var frontier: Array[Vector2i] = [origin]
	var reachable: Array[Vector2i] = []

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_distance: int = distances[current]
		if current_distance >= int(unit.move_range):
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


func _is_in_attack_range(unit: Dictionary, cell: Vector2i) -> bool:
	return _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) <= int(unit.attack_range)


func _perform_basic_attack(attacker: Dictionary, target: Dictionary, end_turn_after := true) -> void:
	var casualties: int = _calculate_casualties(attacker, target)
	target.count = max(0, int(target.count) - casualties)
	if target.count <= 0:
		units.erase(target)
	_sync_board()
	if end_turn_after:
		_end_player_turn()


func _calculate_casualties(attacker: Dictionary, target: Dictionary) -> int:
	var average_damage: float = _get_average_damage(attacker.dmg)
	var damage_per_unit: int = max(1, int(round(average_damage)) - int(target.def))
	var total_damage: int = damage_per_unit * int(attacker.count)
	return max(1, int(total_damage / max(1, int(target.hp))))


func _get_average_damage(damage_text: String) -> float:
	var parts: PackedStringArray = damage_text.split("-")
	if parts.size() != 2:
		return float(int(damage_text))
	return (float(int(parts[0])) + float(int(parts[1]))) / 2.0


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


func _get_blocked_cells(excluded_unit_id: int) -> Dictionary:
	var blocked: Dictionary = {}
	for unit in units:
		if unit.id == excluded_unit_id:
			continue
		blocked[Vector2i(unit.grid_x, unit.grid_y)] = true
	return blocked


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

	assert(_hex_distance(Vector2i(0, 3), Vector2i(0, 7)) == _hex_distance(Vector2i(0, 7), Vector2i(0, 3)))
	assert(_get_attackable_cells(SAMPLE_UNITS[0]).has(Vector2i(1, 3)))
	assert(not _get_attackable_cells(SAMPLE_UNITS[0]).has(Vector2i(0, 3)))
	assert(_calculate_casualties(SAMPLE_UNITS[0], SAMPLE_UNITS[2]) >= 1)


func _on_board_animation_finished(_unit_id: int) -> void:
	is_animating = false


func _on_basic_attack_button_pressed() -> void:
	var unit := _find_unit_by_id(selected_unit_id)
	if unit.is_empty() or current_turn != "player" or unit.side != "player":
		return
	highlight_mode = "move" if highlight_mode == "attack" else "attack"
	_update_highlighted_cells(unit)
	_update_basic_attack_button()


func _update_basic_attack_button() -> void:
	var unit := _find_unit_by_id(selected_unit_id)
	var can_use_attack: bool = not unit.is_empty() and current_turn == "player" and unit.side == "player"
	basic_attack_button.disabled = not can_use_attack
	basic_attack_button.text = "Anuluj atak" if highlight_mode == "attack" and can_use_attack else "Atak podstawowy"


func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var ac: Vector3i = _oddr_to_cube(a)
	var bc: Vector3i = _oddr_to_cube(b)
	return int((abs(ac.x - bc.x) + abs(ac.y - bc.y) + abs(ac.z - bc.z)) / 2)


func _oddr_to_cube(cell: Vector2i) -> Vector3i:
	var x: int = cell.x - int((cell.y - (cell.y & 1)) / 2)
	var z: int = cell.y
	var y: int = -x - z
	return Vector3i(x, y, z)
