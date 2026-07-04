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
const MAX_EVENT_LOG_ENTRIES := 60
const CARD_FONT_COLOR := Color(0.92, 0.88, 0.78, 1.0)
const CARD_SELECTED_FONT_COLOR := Color(0.99, 0.95, 0.84, 1.0)
const LOG_COLOR_YELLOW := Color(0.95, 0.82, 0.25, 1.0)
const LOG_COLOR_PLAYER := Color(0.35, 0.65, 0.95, 1.0)
const LOG_COLOR_ENEMY := Color(0.92, 0.35, 0.30, 1.0)
const LOG_COLOR_DAMAGE := Color(0.92, 0.35, 0.30, 1.0)

@onready var board: Node2D = $BattleLayer/PlanszaWalki
@onready var hud: CanvasLayer = $HUD
@onready var turn_label: Label = $HUD/Overlay/TopBar/TopMargin/TurnLabel
@onready var unit_name_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitName
@onready var unit_meta_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitMeta
@onready var unit_stats_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitStatsPanel/UnitStatsMargin/UnitStats
@onready var actions_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/ActionsPanel/ActionsMargin/ActionsLabel
@onready var action_attack_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/AttackActionButton
@onready var action_skill_1_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/Skill1ActionButton
@onready var action_skill_2_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/Skill2ActionButton
@onready var action_skill_3_button: Button = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/ActionBar/Skill3ActionButton
@onready var general_name_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralName
@onready var general_level_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralLevel
@onready var general_skills_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralSkillsPanel/GeneralSkillsMargin/GeneralSkills
@onready var general_rule_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralRule
@onready var event_log_scroll: ScrollContainer = $HUD/Overlay/RightPanel/RightMargin/RightContent/EventLogPanel/EventLogScroll
@onready var event_log_label: RichTextLabel = $HUD/Overlay/RightPanel/RightMargin/RightContent/EventLogPanel/EventLogScroll/EventLog
@onready var unit_list: HBoxContainer = $HUD/Overlay/BottomBar/BottomMargin/BottomLayout/UnitListPanel/UnitListMargin/UnitListScroll/UnitList

var units: Array = []
var selected_unit_id := -1
var current_turn := "player"
var is_animating := false
var event_log: Array[String] = []
var round_number := 1


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
	general_name_label.text = "KAPITAN ALARIC"
	general_level_label.text = "Poziom 5"
	general_skills_label.text = "\n".join([
		"Szarza bojowa: sojusznicy zyskuja +25% DMG na 2 tury.",
		"Wezwanie bastionu: +3 DEF i odpornosc na oslabienie na 2 tury."
	])
	event_log_label.bbcode_enabled = true
	_log_event(_color_log_text("Bitwa rozpoczeta.", LOG_COLOR_YELLOW))
	_on_unit_selected(units[0])
	_update_turn_label()
	_update_basic_attack_button()
	_refresh_unit_selector()


func _on_unit_selected(unit_data: Dictionary) -> void:
	if is_animating:
		return

	selected_unit_id = unit_data.id
	board.set_selected_unit(unit_data.id)
	_update_highlighted_cells(unit_data)
	_update_basic_attack_button()
	unit_name_label.text = unit_data.name.to_upper()
	unit_meta_label.text = "Poziom 1 - %s - %s" % [unit_data.role, "Gracz" if unit_data.side == "player" else "Przeciwnik"]
	unit_stats_label.text = "\n".join([
		"HP  %s" % unit_data.hp,
		"DMG %s" % unit_data.dmg,
		"DEF %s" % unit_data.def,
		"Liczebnosc  %s" % unit_data.count,
		"Ruch  %s" % unit_data.move_range,
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
	_refresh_unit_selector()


func _on_cell_clicked(cell: Vector2i) -> void:
	if is_animating:
		return

	var unit := _find_unit_by_id(selected_unit_id)
	if unit.is_empty():
		board.set_highlighted_cells([])
		return

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

	var path := _find_path(unit, Vector2i(unit.grid_x, unit.grid_y), cell)
	if path.is_empty() or path.size() > int(unit.move_range):
		return

	is_animating = true
	unit.grid_x = cell.x
	unit.grid_y = cell.y
	_sync_board()
	board.animate_unit_path(unit.id, path)
	await board.animation_finished
	_log_event("%s przemieszcza sie." % _unit_name_log_text(unit))
	_end_player_turn()


func _end_player_turn() -> void:
	current_turn = "enemy"
	selected_unit_id = -1
	board.set_selected_unit(-1)
	board.set_highlighted_cells([], [])
	board.set_prioritize_cell_click_on_left(false)
	_update_basic_attack_button()
	_refresh_unit_selector()
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
		_log_event("%s przemieszcza sie." % _unit_name_log_text(enemy_unit))

	target = _find_nearest_player_unit(enemy_unit)
	if not enemy_unit.is_empty() and not target.is_empty() and _is_in_attack_range(enemy_unit, Vector2i(target.grid_x, target.grid_y)):
		_perform_basic_attack(enemy_unit, target, false)

	current_turn = "player"
	round_number += 1
	_update_turn_label()

	var first_player: Dictionary = _find_first_player_unit()
	if not first_player.is_empty():
		_on_unit_selected(first_player)
	else:
		_refresh_unit_selector()


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
		_on_unit_selected(selected_unit)
	_update_basic_attack_button()
	_refresh_unit_selector()


func _update_turn_label() -> void:
	var turn_name: String = "Gracz" if current_turn == "player" else "Przeciwnik"
	turn_label.text = "TURA %s" % round_number
	general_rule_label.text = "Aktywna tura: %s\nLewy klik atakuje wroga w zasiegu. Prawy klik porusza jednostke." % turn_name


func _update_highlighted_cells(unit: Dictionary) -> void:
	if unit.is_empty() or current_turn != "player" or unit.side != "player":
		board.set_highlighted_cells([], [])
		board.set_prioritize_cell_click_on_left(false)
		return

	var attack_cells: Array[Vector2i] = _get_attackable_enemy_cells(unit)
	board.set_highlighted_cells(_get_reachable_cells(unit), attack_cells)
	board.set_prioritize_cell_click_on_left(not attack_cells.is_empty())


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


func _get_attackable_enemy_cells(unit: Dictionary) -> Array[Vector2i]:
	var attackable: Array[Vector2i] = []
	for other in units:
		if other.side == unit.side:
			continue
		var cell := Vector2i(other.grid_x, other.grid_y)
		if _is_in_attack_range(unit, cell):
			attackable.append(cell)
	return attackable


func _is_in_attack_range(unit: Dictionary, cell: Vector2i) -> bool:
	return _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) <= int(unit.attack_range)


func _perform_basic_attack(attacker: Dictionary, target: Dictionary, end_turn_after := true) -> void:
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
	if target.id == selected_unit_id:
		selected_unit_id = -1
	_sync_board()
	if end_turn_after:
		_end_player_turn()


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
		assert(unit.dmg >= 1)

	assert(_hex_distance(Vector2i(0, 3), Vector2i(0, 7)) == _hex_distance(Vector2i(0, 7), Vector2i(0, 3)))
	assert(_get_attackable_cells(SAMPLE_UNITS[0]).has(Vector2i(1, 3)))
	assert(not _get_attackable_cells(SAMPLE_UNITS[0]).has(Vector2i(0, 3)))
	assert(_calculate_casualties(SAMPLE_UNITS[0], SAMPLE_UNITS[5]) >= 1)


func _on_board_animation_finished(_unit_id: int) -> void:
	is_animating = false
	_refresh_unit_selector()


func _update_basic_attack_button() -> void:
	var unit := _find_unit_by_id(selected_unit_id)
	var can_use_attack: bool = (
		not unit.is_empty()
		and current_turn == "player"
		and unit.side == "player"
		and not _get_attackable_enemy_cells(unit).is_empty()
	)
	action_attack_button.disabled = not can_use_attack
	action_attack_button.text = "ATAK PODSTAWOWY"


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


func _refresh_unit_selector() -> void:
	for child in unit_list.get_children():
		child.queue_free()

	for unit in units:
		if unit.side != "player":
			continue

		var button := Button.new()
		button.custom_minimum_size = Vector2(124, 60)
		button.clip_text = true
		button.text = "%s\n%s %s\nHP %s DMG %s" % [
			unit.count,
			unit.short_name,
			unit.name,
			unit.hp,
			unit.dmg
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = current_turn != "player" or is_animating
		button.add_theme_color_override("font_color", CARD_SELECTED_FONT_COLOR if unit.id == selected_unit_id else CARD_FONT_COLOR)
		button.add_theme_stylebox_override("normal", _make_unit_card_style(unit.id == selected_unit_id))
		button.add_theme_stylebox_override("hover", _make_unit_card_style(true))
		button.add_theme_stylebox_override("pressed", _make_unit_card_style(true))
		button.pressed.connect(_on_unit_card_pressed.bind(unit.id))
		unit_list.add_child(button)


func _on_unit_card_pressed(unit_id: int) -> void:
	if current_turn != "player" or is_animating:
		return

	var unit := _find_unit_by_id(unit_id)
	if unit.is_empty():
		return

	_on_unit_selected(unit)


func _make_unit_card_style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.15, 0.07, 0.96) if selected else Color(0.08, 0.08, 0.07, 0.96)
	style.border_color = Color(0.90, 0.77, 0.34, 1.0) if selected else Color(0.57, 0.46, 0.18, 0.92)
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
