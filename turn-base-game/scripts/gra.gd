extends Control

const BATTLE_CONFIG_PATH := "res://data/battle_config.json"
const GRID_COLUMNS := 15
const GRID_ROWS := 11
const OBSTACLE_TYPES: Array[String] = ["woda", "kamienie", "drzewa"]
const OBSTACLE_SAFE_BORDER_COLUMNS := 4
const MAX_EVENT_LOG_ENTRIES := 60
const CARD_SELECTED_FONT_COLOR := Color(0.99, 0.95, 0.84, 1.0)
const LOG_COLOR_YELLOW := Color(0.95, 0.82, 0.25, 1.0)
const LOG_COLOR_PLAYER := Color(0.35, 0.65, 0.95, 1.0)
const LOG_COLOR_ENEMY := Color(0.92, 0.35, 0.30, 1.0)
const LOG_COLOR_DAMAGE := Color(0.92, 0.35, 0.30, 1.0)

@onready var board: Node2D = $BattleLayer/PlanszaWalki
@onready var hud: CanvasLayer = $HUD
@onready var left_content: VBoxContainer = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent
@onready var turn_queue_list: HBoxContainer = $HUD/Overlay/TopBar/TopMargin/TopQueueScroll/TopQueueList
@onready var unit_portrait: TextureRect = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitPortrait
@onready var unit_name_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitHeaderText/UnitName
@onready var unit_meta_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitHeaderText/UnitMeta
@onready var unit_stats_display: VBoxContainer = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitStatsPanel/UnitStatsMargin/UnitStats
@onready var unit_status_panel: HBoxContainer = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitStatusPanel/UnitStatusMargin/UnitStatus
@onready var actions_label: Label = get_node_or_null("HUD/Overlay/LeftPanel/LeftMargin/LeftContent/ActionsPanel/ActionsMargin/ActionsLabel")
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
var pending_skill_id := ""
var unit_configs: Array[Dictionary] = []
var skill_library: Dictionary = {}
var setup_mode := true
var setup_drag_unit_id := -1
var setup_controls: HBoxContainer
var start_battle_button: Button
var reset_battle_button: Button
var reload_json_button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disable_hud_mouse(hud)
	_build_setup_controls()
	board.cell_clicked.connect(_on_cell_clicked)
	board.cell_left_released.connect(_on_cell_left_released)
	board.cell_right_clicked.connect(_on_cell_right_clicked)
	board.cell_hovered.connect(_on_board_cell_hovered)
	board.animation_finished.connect(_on_board_animation_finished)
	action_attack_button.pressed.connect(_on_attack_button_pressed)
	action_skill_1_button.pressed.connect(_on_skill_button_pressed.bind(0))
	action_skill_2_button.pressed.connect(_on_skill_button_pressed.bind(1))
	action_skill_3_button.pressed.connect(_on_skill_button_pressed.bind(2))
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	general_name_label.text = "KAPITAN ALARIC"
	general_level_label.text = "Poziom 5"
	general_skills_label.text = "\n".join([
		"Pole testowe skilli: glowna jednostka moze zmieniac skille przez skill_ids.",
		"Wsparcie Testowe stoi obok do przyszlych testow skilli sojuszniczych."
	])
	_clear_unit_details()
	event_log_label.bbcode_enabled = true
	_reload_json_into_setup()


func _build_setup_controls() -> void:
	setup_controls = HBoxContainer.new()
	setup_controls.add_theme_constant_override("separation", 8)
	left_content.add_child(setup_controls)
	left_content.move_child(setup_controls, 3)

	start_battle_button = _make_setup_button("START")
	start_battle_button.pressed.connect(_on_start_battle_pressed)
	setup_controls.add_child(start_battle_button)

	reset_battle_button = _make_setup_button("RESET")
	reset_battle_button.pressed.connect(_on_reset_battle_pressed)
	setup_controls.add_child(reset_battle_button)

	reload_json_button = _make_setup_button("RELOAD JSON")
	reload_json_button.pressed.connect(_on_reload_json_pressed)
	setup_controls.add_child(reload_json_button)


func _make_setup_button(text: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 36)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	return button


func _reload_json_into_setup() -> void:
	_load_battle_config()
	_validate_setup()
	_enter_setup_mode()


func _enter_setup_mode() -> void:
	setup_mode = true
	units = unit_configs.map(func(unit: Dictionary) -> Dictionary: return _prepare_unit(unit.duplicate(true)))
	obstacles = []
	selected_unit_id = -1
	setup_drag_unit_id = -1
	active_unit_id = -1
	current_turn = ""
	pending_action = ""
	pending_skill_id = ""
	is_animating = false
	round_number = 1
	turn_queue_index = -1
	event_log.clear()
	board.set_selected_unit(-1)
	board.set_hovered_move_path([])
	board.set_units(units)
	board.reset_unit_positions(units)
	board.set_obstacles(obstacles)
	_rebuild_turn_queue()
	_clear_unit_details()
	_log_event(_color_log_text("Tryb przygotowania: ustaw jednostki i kliknij START.", LOG_COLOR_YELLOW))
	_sync_board()


func _on_start_battle_pressed() -> void:
	if not setup_mode:
		return
	setup_mode = false
	selected_unit_id = -1
	active_unit_id = -1
	current_turn = ""
	pending_action = ""
	pending_skill_id = ""
	round_number = 1
	turn_queue_index = -1
	event_log.clear()
	obstacles = _generate_obstacles()
	board.set_obstacles(obstacles)
	_log_event(_color_log_text("Bitwa rozpoczeta.", LOG_COLOR_YELLOW))
	_rebuild_turn_queue()
	_start_next_activation()


func _on_reset_battle_pressed() -> void:
	_enter_setup_mode()


func _on_reload_json_pressed() -> void:
	_load_battle_config()
	_validate_setup()
	if setup_mode:
		_enter_setup_mode()
		return
	_apply_live_reload()


func _load_battle_config() -> void:
	var file: FileAccess = FileAccess.open(BATTLE_CONFIG_PATH, FileAccess.READ)
	assert(file != null, "Nie mozna otworzyc pliku konfiguracyjnego: %s" % BATTLE_CONFIG_PATH)

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(typeof(parsed) == TYPE_DICTIONARY, "Plik konfiguracyjny musi zawierac obiekt JSON.")

	var config: Dictionary = parsed
	var raw_units: Array = config.get("units", [])
	unit_configs.clear()
	for raw_unit in raw_units:
		assert(typeof(raw_unit) == TYPE_DICTIONARY, "Kazda jednostka w JSON musi byc obiektem.")
		var unit_data: Dictionary = _normalize_unit_config(raw_unit)
		unit_configs.append(unit_data)

	var raw_skill_library: Dictionary = config.get("skill_library", {})
	skill_library.clear()
	for skill_id in raw_skill_library.keys():
		var raw_skill: Variant = raw_skill_library[skill_id]
		assert(typeof(raw_skill) == TYPE_DICTIONARY, "Kazdy skill w JSON musi byc obiektem.")
		var skill_data: Dictionary = _normalize_skill_config(str(skill_id), raw_skill)
		skill_library[str(skill_id)] = skill_data


func _normalize_unit_config(raw_unit: Dictionary) -> Dictionary:
	var normalized: Dictionary = raw_unit.duplicate(true)
	for key in ["id", "grid_x", "grid_y", "hp", "dmg", "def", "speed", "count", "move_range", "attack_range"]:
		normalized[key] = int(normalized.get(key, 0))
	for key in ["name", "short_name", "role", "side", "resistance"]:
		normalized[key] = str(normalized.get(key, ""))

	var normalized_skill_ids: Array[String] = []
	for skill_id in normalized.get("skill_ids", []):
		normalized_skill_ids.append(str(skill_id))
	normalized["skill_ids"] = normalized_skill_ids
	return normalized


func _normalize_skill_config(skill_id: String, raw_skill: Dictionary) -> Dictionary:
	var normalized: Dictionary = raw_skill.duplicate(true)
	normalized["id"] = str(normalized.get("id", skill_id))
	normalized["name"] = str(normalized.get("name", skill_id))
	normalized["description"] = str(normalized.get("description", ""))
	normalized["ap_cost"] = int(normalized.get("ap_cost", 0))
	normalized["cooldown"] = int(normalized.get("cooldown", 0))
	normalized["range"] = int(normalized.get("range", 0))
	normalized["target_type"] = str(normalized.get("target_type", ""))
	normalized["effect_type"] = str(normalized.get("effect_type", ""))
	return normalized


func _prepare_unit(unit: Dictionary) -> Dictionary:
	for stat_name in ["hp", "dmg", "def", "speed", "move_range", "attack_range"]:
		unit["base_%s" % stat_name] = int(unit[stat_name])
	unit["max_hp"] = int(unit["base_hp"])
	unit["max_total_hp"] = int(unit["base_hp"]) * int(unit["count"])
	unit["current_total_hp"] = int(unit["max_total_hp"])
	unit["current_hp"] = int(unit["base_hp"])
	unit["remaining_move"] = int(unit.move_range)
	unit["action_points"] = 1
	unit["active_effects"] = []
	unit["skill_cooldowns"] = {}
	unit["buffs"] = "Brak"
	unit["debuffs"] = "Brak"
	_recalculate_unit_stats(unit)
	return unit


func _on_unit_selected(unit_data: Dictionary) -> void:
	if is_animating:
		return
	_show_unit_details(unit_data)


func _show_unit_details(unit_data: Dictionary) -> void:
	selected_unit_id = unit_data.id
	board.set_selected_unit(unit_data.id)
	if setup_mode or unit_data.side == "player":
		_update_highlighted_cells(unit_data)
	else:
		board.set_highlighted_cells([], [])
	_render_unit_details(unit_data)
	_update_action_buttons()
	_refresh_turn_queue()


func _render_unit_details(unit_data: Dictionary) -> void:
	unit_portrait.visible = true
	unit_name_label.text = unit_data.name.to_upper()
	unit_meta_label.text = "Poziom 1"
	unit_stats_display.set_values({
		"hp": "%s / %s" % [unit_data.get("current_hp", unit_data.hp), unit_data.get("max_hp", unit_data.hp)],
		"dmg": str(unit_data.dmg),
		"def": str(unit_data.def),
		"speed": str(unit_data.speed),
		"count": str(unit_data.count),
		"move": "%s / %s" % [_get_display_move(unit_data), unit_data.move_range],
		"action_points": str(_get_display_action_points(unit_data)),
	})
	unit_status_panel.set_unit(unit_data)
	if actions_label != null:
		actions_label.text = "Umiejetnosci: %s" % _format_skill_list(unit_data)
	_update_action_placeholders(unit_data)


func _apply_live_reload() -> void:
	var current_units_by_id: Dictionary = {}
	for unit in units:
		current_units_by_id[int(unit.id)] = unit

	var rebuilt_units: Array = []
	for unit_config in unit_configs:
		var rebuilt_unit: Dictionary = _prepare_unit(unit_config.duplicate(true))
		var existing_unit: Dictionary = current_units_by_id.get(int(rebuilt_unit.id), {})
		if not existing_unit.is_empty():
			_reapply_runtime_state(rebuilt_unit, existing_unit)
		rebuilt_units.append(rebuilt_unit)

	units = rebuilt_units
	selected_unit_id = selected_unit_id if not _find_unit_by_id(selected_unit_id).is_empty() else -1
	active_unit_id = active_unit_id if not _find_unit_by_id(active_unit_id).is_empty() else -1
	_rebuild_turn_queue()
	if not _find_unit_by_id(active_unit_id).is_empty():
		turn_queue_index = maxi(turn_queue.find(active_unit_id) - 1, -1)
	board.set_units(units)
	board.reset_unit_positions(units)
	_sync_board()
	_log_event(_color_log_text("Przeladowano JSON w trakcie rozgrywki.", LOG_COLOR_YELLOW))


func _reapply_runtime_state(target_unit: Dictionary, existing_unit: Dictionary) -> void:
	target_unit["grid_x"] = int(existing_unit.grid_x)
	target_unit["grid_y"] = int(existing_unit.grid_y)
	var old_max_total_hp: int = max(1, int(existing_unit.get("max_total_hp", target_unit["max_total_hp"])))
	var old_current_total_hp: int = max(0, int(existing_unit.get("current_total_hp", old_max_total_hp)))
	var hp_ratio: float = float(old_current_total_hp) / float(old_max_total_hp)
	target_unit["current_total_hp"] = int(round(float(target_unit["max_total_hp"]) * hp_ratio))
	target_unit["remaining_move"] = int(existing_unit.get("remaining_move", target_unit.move_range))
	target_unit["action_points"] = int(existing_unit.get("action_points", 1))
	target_unit["active_effects"] = existing_unit.get("active_effects", []).duplicate(true)
	target_unit["skill_cooldowns"] = existing_unit.get("skill_cooldowns", {}).duplicate(true)
	_recalculate_unit_stats(target_unit)


func _format_skill_list(unit_data: Dictionary) -> String:
	var skill_ids: Array = unit_data.get("skill_ids", [])
	if skill_ids.is_empty():
		return "Brak"
	var names: Array[String] = []
	for skill_id in skill_ids:
		names.append(_get_skill_name(str(skill_id)))
	return ", ".join(names)


func _clear_unit_details() -> void:
	unit_portrait.visible = false
	unit_name_label.text = "BRAK JEDNOSTEK"
	unit_meta_label.text = ""
	unit_stats_display.clear_values()
	unit_status_panel.clear()
	if actions_label != null:
		actions_label.text = ""
	action_skill_1_button.text = "UM. 1"
	action_skill_2_button.text = "UM. 2"
	action_skill_3_button.text = "UM. 3"
	action_skill_1_button.tooltip_text = ""
	action_skill_2_button.tooltip_text = ""
	action_skill_3_button.tooltip_text = ""


func _clear_selected_unit() -> void:
	selected_unit_id = -1
	setup_drag_unit_id = -1
	pending_action = ""
	pending_skill_id = ""
	board.set_selected_unit(-1)
	board.set_highlighted_cells([], [])
	board.set_hovered_move_path([])
	_clear_unit_details()
	_update_action_buttons()
	_refresh_turn_queue()


func _on_cell_clicked(cell: Vector2i) -> void:
	if setup_mode:
		_handle_setup_cell_pressed(cell)
		return

	if is_animating or not _is_player_turn():
		return

	var active_unit := _get_active_unit()
	if active_unit.is_empty() or active_unit.side != "player":
		return

	if pending_skill_id != "":
		_try_use_skill(active_unit, pending_skill_id, cell)
		return

	var clicked_unit := _find_unit_at_cell(cell)
	if pending_action == "attack":
		if not clicked_unit.is_empty() and clicked_unit.side != active_unit.side and _can_unit_attack(active_unit) and _is_in_attack_range(active_unit, cell):
			_perform_basic_attack(active_unit, clicked_unit)
		return

	if not clicked_unit.is_empty():
		if clicked_unit.id == selected_unit_id:
			_clear_selected_unit()
			return
		selected_unit_id = clicked_unit.id
		_show_unit_details(clicked_unit)
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
	pending_skill_id = ""
	_sync_board()
	board.animate_unit_path(active_unit.id, path)
	await board.animation_finished
	_log_event("%s przemieszcza sie." % _unit_name_log_text(active_unit))
	_sync_board()
	if not _can_unit_continue_turn(active_unit):
		_end_current_activation()


func _on_cell_right_clicked(_cell: Vector2i) -> void:
	return


func _on_cell_left_released(cell: Vector2i) -> void:
	if not setup_mode or setup_drag_unit_id == -1:
		return

	var dragged_unit: Dictionary = _find_unit_by_id(setup_drag_unit_id)
	setup_drag_unit_id = -1
	if dragged_unit.is_empty():
		return
	if cell.x == -1 or not _can_place_setup_unit(dragged_unit, cell):
		board.set_hovered_move_path([])
		return

	dragged_unit["grid_x"] = cell.x
	dragged_unit["grid_y"] = cell.y
	board.snap_unit_to_cell(int(dragged_unit.id), cell)
	_show_unit_details(dragged_unit)
	_sync_board()


func _handle_setup_cell_pressed(cell: Vector2i) -> void:
	var clicked_unit: Dictionary = _find_unit_at_cell(cell)
	if not clicked_unit.is_empty():
		setup_drag_unit_id = int(clicked_unit.id)
		_show_unit_details(clicked_unit)
		return

	if selected_unit_id == -1:
		return

	var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
	if selected_unit.is_empty() or not _can_place_setup_unit(selected_unit, cell):
		return

	selected_unit["grid_x"] = cell.x
	selected_unit["grid_y"] = cell.y
	board.snap_unit_to_cell(int(selected_unit.id), cell)
	_show_unit_details(selected_unit)
	_sync_board()


func _end_current_activation() -> void:
	var unit := _get_active_unit()
	if not unit.is_empty():
		_advance_unit_effects(unit)
	pending_action = ""
	pending_skill_id = ""
	selected_unit_id = -1
	board.set_selected_unit(-1)
	board.set_highlighted_cells([], [])
	board.set_hovered_move_path([])
	_update_action_buttons()
	_start_next_activation()


func _enemy_take_turn() -> void:
	var enemy_unit := _get_active_unit()
	if enemy_unit.is_empty() or enemy_unit.side != "enemy":
		return
	await get_tree().create_timer(3.0).timeout

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
	var forced_target := _get_forced_target(enemy_unit)
	if not forced_target.is_empty():
		return forced_target

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


func _get_forced_target(unit: Dictionary) -> Dictionary:
	for effect in unit.get("active_effects", []):
		if effect.get("forced_target_id", -1) == -1:
			continue
		var target: Dictionary = _find_unit_by_id(int(effect.forced_target_id))
		if not target.is_empty():
			return target
	return {}


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
	for unit in units:
		_recalculate_unit_stats(unit)
	board.set_units(units)
	board.set_obstacles(obstacles)
	var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
	if selected_unit.is_empty():
		board.set_highlighted_cells([], [])
		board.set_hovered_move_path([])
		_clear_unit_details()
	else:
		_update_highlighted_cells(selected_unit)
		_render_unit_details(selected_unit)
	_update_turn_label()
	_update_action_buttons()
	_refresh_turn_queue()


func _update_turn_label() -> void:
	if setup_mode:
		general_rule_label.text = "Tryb przygotowania: zlap jednostke lewym przyciskiem, przeciagnij i pusc na wolnym hexie. START rozpoczyna bitwe."
		return
	var active_unit := _get_active_unit()
	var turn_name := "Brak"
	if current_turn == "player":
		turn_name = "Gracz"
	elif current_turn == "enemy":
		turn_name = "Przeciwnik"
	var active_name: String = active_unit.name if not active_unit.is_empty() else "-"
	if units.is_empty():
		general_rule_label.text = "Aktywna jednostka: -\nNa planszy nie ma zadnych jednostek. Tura %s." % round_number
		return
	general_rule_label.text = "Aktywna jednostka: %s (%s)\nLPM porusza albo wybiera cel ataku/skilla. Tura %s." % [active_name, turn_name, round_number]


func _update_highlighted_cells(unit: Dictionary) -> void:
	if unit.is_empty():
		board.set_highlighted_cells([], [])
		board.set_hovered_move_path([])
		return

	if setup_mode:
		board.set_highlighted_cells(_get_setup_placeable_cells(unit), [])
		_on_board_cell_hovered(board.get_hovered_cell())
		return

	if unit.side != "player":
		board.set_highlighted_cells([], [])
		board.set_hovered_move_path([])
		return

	var move_budget: int = unit.move_range if unit.id != active_unit_id else _get_remaining_move(unit)
	var move_cells: Array[Vector2i] = _get_reachable_cells(unit, move_budget)
	var attack_cells: Array[Vector2i] = []
	if unit.id == active_unit_id and pending_action == "attack":
		attack_cells = _get_attackable_cells(unit)
		move_cells = []
	elif unit.id == active_unit_id and pending_skill_id != "":
		attack_cells = _get_skill_target_cells(unit, pending_skill_id)
		move_cells = []
	board.set_highlighted_cells(move_cells, attack_cells)
	_on_board_cell_hovered(board.get_hovered_cell())


func _on_board_cell_hovered(cell: Vector2i) -> void:
	if setup_mode:
		if selected_unit_id == -1 or cell.x == -1:
			board.set_hovered_move_path([])
			return
		var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
		if selected_unit.is_empty() or not _can_place_setup_unit(selected_unit, cell):
			board.set_hovered_move_path([])
			return
		board.set_hovered_move_path([cell])
		return

	if is_animating or pending_action == "attack" or pending_skill_id != "":
		board.set_hovered_move_path([])
		return

	var active_unit := _get_active_unit()
	if active_unit.is_empty() or active_unit.side != "player":
		board.set_hovered_move_path([])
		return

	if selected_unit_id != active_unit.id:
		board.set_hovered_move_path([])
		return

	if cell.x == -1:
		board.set_hovered_move_path([])
		return

	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell)
	if path.is_empty() or path.size() > _get_remaining_move(active_unit):
		board.set_hovered_move_path([])
		return

	board.set_hovered_move_path(path)


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


func _get_setup_placeable_cells(unit: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if _can_place_setup_unit(unit, cell):
				cells.append(cell)
	return cells


func _can_place_setup_unit(unit: Dictionary, cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= GRID_COLUMNS or cell.y < 0 or cell.y >= GRID_ROWS:
		return false
	if cell == Vector2i(unit.grid_x, unit.grid_y):
		return true
	var occupant: Dictionary = _find_unit_at_cell(cell)
	return occupant.is_empty()


func _get_attackable_cells(unit: Dictionary) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var attackable: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if cell == origin:
				continue
			if _is_in_attack_range(unit, cell):
				attackable.append(cell)
	return attackable


func _get_skill_target_cells(unit: Dictionary, skill_id: String) -> Array[Vector2i]:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return []
	if str(skill.get("target_type", "")) == "self":
		return [Vector2i(unit.grid_x, unit.grid_y)]

	var skill_range: int = int(skill.get("range", 0))
	var cells: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if cell == Vector2i(unit.grid_x, unit.grid_y):
				continue
			if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > skill_range:
				continue
			if _is_attack_blocked(unit, cell):
				continue
			cells.append(cell)
	return cells


func _is_in_attack_range(unit: Dictionary, cell: Vector2i) -> bool:
	if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(unit.attack_range):
		return false
	return not _is_attack_blocked(unit, cell)


func _perform_basic_attack(attacker: Dictionary, target: Dictionary, end_turn_after := true) -> void:
	attacker.action_points = max(0, int(attacker.get("action_points", 0)) - 1)
	pending_action = ""
	pending_skill_id = ""
	var total_damage: int = _calculate_damage(attacker, target)
	var casualties: int = _apply_damage_to_unit(target, total_damage)
	_log_event(
		"%s uderza %s za %s obrazen i zadaje %s strat." % [
			_unit_name_log_text(attacker),
			_unit_name_log_text(target),
			_color_log_text(str(total_damage), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(target)
	_sync_board()
	if end_turn_after:
		_end_current_activation()


func _calculate_damage(attacker: Dictionary, target: Dictionary, damage_multiplier := 1.0) -> int:
	var scaled_damage: int = max(1, int(ceil(float(attacker.dmg) * damage_multiplier)))
	var damage_per_unit: int = max(1, scaled_damage - int(target.def))
	return max(1, damage_per_unit * int(attacker.count))


func _apply_damage_to_unit(target: Dictionary, total_damage: int) -> int:
	var previous_count: int = int(target.count)
	var current_total_hp: int = int(target.get("current_total_hp", int(target.get("base_hp", target.hp)) * previous_count))
	target["current_total_hp"] = max(0, current_total_hp - max(1, total_damage))
	_refresh_unit_health_state(target)
	return max(0, previous_count - int(target.count))


func _calculate_tick_damage(effect_damage: int) -> int:
	return max(1, effect_damage)


func _cleanup_destroyed_unit(target: Dictionary) -> void:
	if target.count > 0:
		return
	_log_event("%s zostaje rozbite." % _unit_name_log_text(target))
	units.erase(target)
	turn_queue.erase(target.id)
	if turn_queue_index >= turn_queue.size():
		turn_queue_index = turn_queue.size() - 1
	if target.id == selected_unit_id:
		selected_unit_id = -1


func _try_use_skill(unit: Dictionary, skill_id: String, cell: Vector2i) -> void:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return
	if not _can_use_skill(unit, skill_id):
		return

	if str(skill.get("target_type", "")) == "self":
		if cell != Vector2i(unit.grid_x, unit.grid_y):
			return
		_execute_skill(unit, unit, skill)
		return

	var target := _find_unit_at_cell(cell)
	if target.is_empty():
		return
	var target_type := str(skill.get("target_type", ""))
	if target_type == "enemy_unit" and target.side == unit.side:
		return
	if target_type == "ally_unit" and (target.side != unit.side or target.id == unit.id):
		return
	if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(skill.get("range", 0)):
		return
	if _is_attack_blocked(unit, cell):
		return
	_execute_skill(unit, target, skill)


func _execute_skill(caster: Dictionary, target: Dictionary, skill: Dictionary) -> void:
	caster.action_points = max(0, int(caster.action_points) - int(skill.get("ap_cost", 0)))
	caster.skill_cooldowns[skill.get("id", "")] = int(skill.get("cooldown", 0))
	pending_action = ""
	pending_skill_id = ""

	match String(skill.get("effect_type", "")):
		"taunt_burst":
			_execute_taunt_burst(caster)
		"knee_shot":
			_execute_knee_shot(caster, target)
		"poison_dagger":
			_execute_poison_dagger(caster, target)
		"eagle_eye":
			_execute_eagle_eye(caster)
		"heavy_strike":
			_execute_heavy_strike(caster, target)

	_sync_board()
	_end_current_activation()


func _execute_taunt_burst(caster: Dictionary) -> void:
	var affected := []
	for other in units:
		if other.side == caster.side:
			continue
		var distance := _hex_distance(Vector2i(caster.grid_x, caster.grid_y), Vector2i(other.grid_x, other.grid_y))
		if distance > 2:
			continue
		_apply_or_refresh_effect(other, {
			"id": "taunt_%s" % caster.id,
			"name": "Prowokacja",
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [
				{"stat": "dmg", "mode": "percent", "value": -20}
			],
			"forced_target_id": caster.id
		})
		affected.append(other.name)
	if affected.is_empty():
		_log_event("%s uzywa Prowokacji, ale nikt nie jest w zasiegu." % _unit_name_log_text(caster))
		return
	_log_event("%s prowokuje: %s." % [_unit_name_log_text(caster), ", ".join(affected)])


func _execute_knee_shot(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.7)
	var casualties := _apply_damage_to_unit(target, total_damage)
	_apply_or_refresh_effect(target, {
		"id": "immobilize",
		"name": "Unieruchomienie",
		"category": "debuff",
		"remaining_turns": 1,
		"stat_changes": [
			{"stat": "move_range", "mode": "set", "value": 0}
		]
	})
	_log_event(
		"%s trafia %s Strzalem w Kolano za %s obrazen i %s strat, unieruchamiajac cel." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(target),
			_color_log_text(str(total_damage), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(target)


func _execute_poison_dagger(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.7)
	var casualties := _apply_damage_to_unit(target, total_damage)
	_apply_or_refresh_effect(target, {
		"id": "toksyna",
		"name": "Toksyna",
		"category": "debuff",
		"remaining_turns": 3,
		"stat_changes": [
			{"stat": "def", "mode": "percent", "value": -15}
		],
		"tick_damage": max(1, int(ceil(float(caster.dmg) * 0.5)))
	})
	_log_event(
		"%s zatruwa %s Sztyletem za %s obrazen i %s strat." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(target),
			_color_log_text(str(total_damage), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(target)


func _execute_eagle_eye(caster: Dictionary) -> void:
	caster["remaining_move"] = 0
	_apply_or_refresh_effect(caster, {
		"id": "sokole_oko",
		"name": "Sokole Oko",
		"category": "buff",
		"remaining_turns": 2,
		"stat_changes": [
			{"stat": "attack_range", "mode": "flat", "value": 2},
			{"stat": "dmg", "mode": "percent", "value": 25}
		]
	})
	_log_event("%s przygotowuje Sokole Oko na nastepna ture." % _unit_name_log_text(caster))


func _execute_heavy_strike(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target)
	var casualties := _apply_damage_to_unit(target, total_damage)
	var pushed: bool = _try_push_unit_away(caster, target)
	if not pushed and target.count > 0:
		_apply_or_refresh_effect(target, {
			"id": "ogluszenie",
			"name": "Ogluszenie",
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [],
			"skip_turn": true
		})
	_log_event(
		"%s uderza %s poteznie za %s obrazen i %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(target),
			_color_log_text(str(total_damage), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			" Cel zostaje odepchniety." if pushed else " Cel wpada w blokade i zostaje ogluszony."
		]
	)
	_cleanup_destroyed_unit(target)


func _can_use_skill(unit: Dictionary, skill_id: String) -> bool:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return false
	if int(unit.get("action_points", 0)) < int(skill.get("ap_cost", 0)):
		return false
	return int(unit.get("skill_cooldowns", {}).get(skill_id, 0)) == 0


func _apply_or_refresh_effect(unit: Dictionary, effect_data: Dictionary) -> void:
	var effects: Array = unit.get("active_effects", [])
	for existing in effects:
		if str(existing.get("id", "")) != str(effect_data.get("id", "")):
			continue
		existing["remaining_turns"] = int(effect_data.get("remaining_turns", 0))
		existing["stat_changes"] = effect_data.get("stat_changes", [])
		if effect_data.has("tick_damage"):
			existing["tick_damage"] = int(effect_data.get("tick_damage", 0))
		if effect_data.has("forced_target_id"):
			existing["forced_target_id"] = int(effect_data.get("forced_target_id", -1))
		_recalculate_unit_stats(unit)
		return
	effects.append(effect_data.duplicate(true))
	unit["active_effects"] = effects
	_recalculate_unit_stats(unit)


func _process_turn_start(unit: Dictionary) -> void:
	_advance_skill_cooldowns(unit)
	var effects: Array = unit.get("active_effects", [])
	var skipped_turn := false
	for effect in effects:
		var tick_damage: int = int(effect.get("tick_damage", 0))
		if bool(effect.get("skip_turn", false)):
			skipped_turn = true
			unit["remaining_move"] = 0
			unit["action_points"] = 0
		if tick_damage <= 0:
			continue
		var total_damage := _calculate_tick_damage(tick_damage)
		var casualties := _apply_damage_to_unit(unit, total_damage)
		_log_event(
			"%s cierpi przez %s, traci %s HP i %s jednostek." % [
				_unit_name_log_text(unit),
				str(effect.get("name", "efekt")),
				_color_log_text(str(total_damage), LOG_COLOR_DAMAGE),
				_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
			]
		)
		if unit.count <= 0:
			_cleanup_destroyed_unit(unit)
			return
	if skipped_turn:
		_log_event("%s jest ogluszona i traci ture." % _unit_name_log_text(unit))
	_recalculate_unit_stats(unit)


func _advance_skill_cooldowns(unit: Dictionary) -> void:
	var cooldowns: Dictionary = unit.get("skill_cooldowns", {})
	for skill_id in cooldowns.keys():
		var remaining: int = int(cooldowns[skill_id])
		if remaining > 0:
			cooldowns[skill_id] = remaining - 1
	unit["skill_cooldowns"] = cooldowns


func _advance_unit_effects(unit: Dictionary) -> void:
	var kept_effects: Array = []
	for effect in unit.get("active_effects", []):
		effect["remaining_turns"] = int(effect.get("remaining_turns", 0)) - 1
		if int(effect["remaining_turns"]) > 0:
			kept_effects.append(effect)
	unit["active_effects"] = kept_effects
	_recalculate_unit_stats(unit)


func _recalculate_unit_stats(unit: Dictionary) -> void:
	unit["hp"] = int(unit.get("base_hp", unit.hp))
	unit["dmg"] = int(unit.get("base_dmg", unit.dmg))
	unit["def"] = int(unit.get("base_def", unit.def))
	unit["speed"] = int(unit.get("base_speed", unit.speed))
	unit["move_range"] = int(unit.get("base_move_range", unit.move_range))
	unit["attack_range"] = int(unit.get("base_attack_range", unit.attack_range))

	var buff_names: Array[String] = []
	var debuff_names: Array[String] = []
	for effect in unit.get("active_effects", []):
		for change in effect.get("stat_changes", []):
			_apply_stat_change(unit, change)
		if str(effect.get("category", "")) == "buff":
			buff_names.append(str(effect.get("name", "")))
		elif str(effect.get("category", "")) == "debuff":
			debuff_names.append(str(effect.get("name", "")))

	unit["dmg"] = max(1, int(unit.dmg))
	unit["def"] = max(0, int(unit.def))
	unit["speed"] = max(0, int(unit.speed))
	unit["move_range"] = max(0, int(unit.move_range))
	unit["attack_range"] = max(1, int(unit.attack_range))
	unit["buffs"] = "Brak" if buff_names.is_empty() else ", ".join(buff_names)
	unit["debuffs"] = "Brak" if debuff_names.is_empty() else ", ".join(debuff_names)
	_refresh_unit_health_state(unit)


func _refresh_unit_health_state(unit: Dictionary) -> void:
	var unit_hp: int = max(1, int(unit.get("base_hp", unit.get("max_hp", 1))))
	var total_hp: int = max(0, int(unit.get("current_total_hp", unit_hp * int(unit.count))))
	unit["max_hp"] = unit_hp
	unit["max_total_hp"] = max(unit_hp, int(unit.get("max_total_hp", unit_hp * max(1, int(unit.count)))))
	unit["current_total_hp"] = total_hp
	if total_hp <= 0:
		unit["count"] = 0
		unit["current_hp"] = 0
		return
	unit["count"] = int(ceil(float(total_hp) / float(unit_hp)))
	var remainder: int = total_hp % unit_hp
	unit["current_hp"] = unit_hp if remainder == 0 else remainder


func _apply_stat_change(unit: Dictionary, change: Dictionary) -> void:
	var stat_name := str(change.get("stat", ""))
	if stat_name == "" or not unit.has(stat_name):
		return

	var current_value: int = int(unit.get(stat_name, 0))
	var base_value: int = int(unit.get("base_%s" % stat_name, current_value))
	var mode := str(change.get("mode", "flat"))
	var next_value := current_value

	match mode:
		"flat":
			next_value = current_value + int(change.get("value", 0))
		"percent":
			var multiplier := 1.0 + float(change.get("value", 0)) / 100.0
			var percent_result: int = int(ceil(float(base_value) * multiplier))
			var delta_from_base: int = percent_result - base_value
			next_value = current_value + delta_from_base
		"set":
			next_value = int(change.get("value", current_value))

	unit[stat_name] = next_value


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


func _try_push_unit_away(source: Dictionary, target: Dictionary) -> bool:
	var destination: Vector2i = _get_push_destination(source, target)
	if destination == Vector2i(-1, -1):
		return false
	target["grid_x"] = destination.x
	target["grid_y"] = destination.y
	board.snap_unit_to_cell(int(target.id), destination)
	return true


func _get_push_destination(source: Dictionary, target: Dictionary) -> Vector2i:
	var source_cube: Vector3i = _oddr_to_cube(Vector2i(source.grid_x, source.grid_y))
	var target_cube: Vector3i = _oddr_to_cube(Vector2i(target.grid_x, target.grid_y))
	var direction: Vector3i = target_cube - source_cube
	var pushed_cube: Vector3i = target_cube + direction
	var pushed_cell: Vector2i = _cube_to_oddr(pushed_cube)
	if pushed_cell.x < 0 or pushed_cell.x >= GRID_COLUMNS or pushed_cell.y < 0 or pushed_cell.y >= GRID_ROWS:
		return Vector2i(-1, -1)
	if _is_cell_obstacle(pushed_cell):
		return Vector2i(-1, -1)
	var occupant: Dictionary = _find_unit_at_cell(pushed_cell)
	if not occupant.is_empty():
		return Vector2i(-1, -1)
	return pushed_cell


func _generate_obstacles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var occupied: Dictionary = {}
	var obstacle_types_by_cell: Dictionary = {}
	for unit in units:
		occupied[Vector2i(unit.grid_x, unit.grid_y)] = true

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var type_count: int = rng.randi_range(2, OBSTACLE_TYPES.size())
	var shuffled_types: Array[String] = OBSTACLE_TYPES.duplicate()
	shuffled_types.shuffle()

	for type_index in range(type_count):
		var type: String = shuffled_types[type_index]
		var cluster_size: int = rng.randi_range(1, 4)
		var cluster: Array[Vector2i] = _generate_cluster(cluster_size, occupied, obstacle_types_by_cell, type, rng)
		for cell in cluster:
			occupied[cell] = true
			obstacle_types_by_cell[cell] = type
			result.append({"grid_x": cell.x, "grid_y": cell.y, "type": type})
	return result


func _generate_cluster(target_size: int, occupied: Dictionary, obstacle_types_by_cell: Dictionary, obstacle_type: String, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var attempts: int = 0
	while attempts < 200:
		attempts += 1
		var start: Vector2i = _random_empty_cell(occupied, obstacle_types_by_cell, obstacle_type, rng)
		if start == Vector2i(-1, -1):
			continue
		var cluster: Array[Vector2i] = [start]
		var cluster_cells: Dictionary = {start: true}
		var frontier: Array[Vector2i] = [start]
		while cluster.size() < target_size and not frontier.is_empty():
			frontier.shuffle()
			var current: Vector2i = frontier.pop_front()
			var neighbors: Array[Vector2i] = _get_neighbors(current)
			neighbors.shuffle()
			for neighbor in neighbors:
				if not _can_place_obstacle_cell(neighbor, occupied, obstacle_types_by_cell, obstacle_type, cluster_cells):
					continue
				cluster.append(neighbor)
				cluster_cells[neighbor] = true
				frontier.append(neighbor)
				if cluster.size() >= target_size:
					break
		return cluster
	return []


func _random_empty_cell(occupied: Dictionary, obstacle_types_by_cell: Dictionary, obstacle_type: String, rng: RandomNumberGenerator) -> Vector2i:
	var x_min: int = OBSTACLE_SAFE_BORDER_COLUMNS
	var x_max: int = GRID_COLUMNS - OBSTACLE_SAFE_BORDER_COLUMNS - 1
	var attempts: int = 0
	while attempts < 100:
		attempts += 1
		var cell := Vector2i(rng.randi_range(x_min, x_max), rng.randi_range(0, GRID_ROWS - 1))
		if _can_place_obstacle_cell(cell, occupied, obstacle_types_by_cell, obstacle_type):
			return cell
	return Vector2i(-1, -1)


func _is_obstacle_column_allowed(column: int) -> bool:
	return column >= OBSTACLE_SAFE_BORDER_COLUMNS and column < GRID_COLUMNS - OBSTACLE_SAFE_BORDER_COLUMNS


func _can_place_obstacle_cell(cell: Vector2i, occupied: Dictionary, obstacle_types_by_cell: Dictionary, obstacle_type: String, cluster_cells: Dictionary = {}) -> bool:
	if occupied.has(cell) or cluster_cells.has(cell) or not _is_obstacle_column_allowed(cell.x):
		return false
	for neighbor in _get_neighbors(cell):
		if cluster_cells.has(neighbor):
			continue
		var neighbor_type: String = str(obstacle_types_by_cell.get(neighbor, ""))
		if neighbor_type != "" and neighbor_type != obstacle_type:
			return false
	return true


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
	for unit in unit_configs:
		assert(unit.grid_x >= 0 and unit.grid_x < GRID_COLUMNS)
		assert(unit.grid_y >= 0 and unit.grid_y < GRID_ROWS)
		assert(unit.dmg >= 1)
		assert(unit.speed >= 1)
		for skill_id in unit.get("skill_ids", []):
			assert(skill_library.has(skill_id), "Brak skilla w bibliotece: %s" % skill_id)

	assert(_hex_distance(Vector2i(0, 3), Vector2i(0, 7)) == _hex_distance(Vector2i(0, 7), Vector2i(0, 3)))


func _on_board_animation_finished(_unit_id: int) -> void:
	is_animating = false
	_refresh_turn_queue()


func _update_action_buttons() -> void:
	if setup_mode:
		action_attack_button.disabled = true
		action_attack_button.button_pressed = false
		action_attack_button.text = "ATAK PODSTAWOWY"
		action_skill_1_button.disabled = true
		action_skill_2_button.disabled = true
		action_skill_3_button.disabled = true
		end_turn_button.disabled = true
		return

	var unit := _get_active_unit()
	var can_act: bool = not unit.is_empty() and _is_player_turn() and unit.side == "player" and selected_unit_id == unit.id
	var can_use_attack: bool = can_act and _can_unit_attack(unit)
	action_attack_button.disabled = not can_use_attack
	action_attack_button.button_pressed = pending_action == "attack"
	action_attack_button.text = "ATAK PODSTAWOWY" if pending_action != "attack" else "WYBIERZ CEL"
	_update_skill_button(action_skill_1_button, unit, 0, can_act)
	_update_skill_button(action_skill_2_button, unit, 1, can_act)
	_update_skill_button(action_skill_3_button, unit, 2, can_act)
	end_turn_button.disabled = not _is_player_turn() or unit.is_empty()


func _update_skill_button(button: Button, unit: Dictionary, index: int, can_act: bool) -> void:
	var skill := _get_skill_at(unit, index)
	if skill.is_empty():
		button.disabled = true
		return
	button.disabled = not can_act or not _can_use_skill(unit, str(skill.get("id", "")))


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

	if unit.id == selected_unit_id:
		_clear_selected_unit()
		return

	pending_action = ""
	pending_skill_id = ""
	_on_unit_selected(unit)


func _on_turn_queue_gui_input(_event: InputEvent, _unit_id: int) -> void:
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
	var labels: Array[String] = [
		_build_skill_button_label(unit, 0),
		_build_skill_button_label(unit, 1),
		_build_skill_button_label(unit, 2)
	]
	action_skill_1_button.text = labels[0]
	action_skill_2_button.text = labels[1]
	action_skill_3_button.text = labels[2]
	action_skill_1_button.tooltip_text = _build_skill_tooltip(unit, 0)
	action_skill_2_button.tooltip_text = _build_skill_tooltip(unit, 1)
	action_skill_3_button.tooltip_text = _build_skill_tooltip(unit, 2)


func _build_skill_button_label(unit: Dictionary, index: int) -> String:
	var skill := _get_skill_at(unit, index)
	if skill.is_empty():
		return "UM. %s\nPLACEHOLDER" % str(index + 1)
	var cooldown: int = int(unit.get("skill_cooldowns", {}).get(skill.get("id", ""), 0))
	var suffix := "" if cooldown == 0 else "\nCD %s" % cooldown
	return "UM. %s\n%s%s" % [str(index + 1), str(skill.get("name", "")).to_upper(), suffix]


func _build_skill_tooltip(unit: Dictionary, index: int) -> String:
	var skill: Dictionary = _get_skill_at(unit, index)
	if skill.is_empty():
		return "Brak umiejetnosci."

	var target_label := _skill_target_label(str(skill.get("target_type", "")))
	var lines: Array[String] = [
		str(skill.get("name", "")),
		"Koszt AP: %s" % str(skill.get("ap_cost", 0)),
		"Cooldown: %s" % str(skill.get("cooldown", 0)),
		"Zasieg: %s" % str(skill.get("range", 0)),
		"Cel: %s" % target_label
	]
	var description: String = str(skill.get("description", ""))
	if description != "":
		lines.append("")
		lines.append(description)
	return "\n".join(lines)


func _skill_target_label(target_type: String) -> String:
	match target_type:
		"self":
			return "Na siebie"
		"enemy_unit":
			return "Wroga jednostka"
		"ally_unit":
			return "Sojusznicza jednostka"
	return "Brak"


func _get_skill_at(unit: Dictionary, index: int) -> Dictionary:
	if unit.is_empty():
		return {}
	var skill_ids: Array = unit.get("skill_ids", [])
	if index < 0 or index >= skill_ids.size():
		return {}
	return skill_library.get(str(skill_ids[index]), {})


func _get_skill_name(skill_id: String) -> String:
	var skill: Dictionary = skill_library.get(skill_id, {})
	return str(skill.get("name", skill_id))


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
		board.set_hovered_move_path([])
		_clear_unit_details()
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
	pending_skill_id = ""
	_process_turn_start(unit)
	if _find_unit_by_id(unit.id).is_empty():
		_sync_board()
		_start_next_activation()
		return
	if not _can_unit_continue_turn(unit):
		_sync_board()
		_end_current_activation()
		return
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
	if int(unit.move_range) <= 0:
		return 0
	return min(int(unit.get("remaining_move", unit.get("move_range", 0))), int(unit.move_range))


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

	pending_skill_id = ""
	pending_action = "" if pending_action == "attack" else "attack"
	selected_unit_id = unit.id
	_update_highlighted_cells(unit)
	_update_action_buttons()
	_refresh_turn_queue()


func _on_skill_button_pressed(index: int) -> void:
	if not _is_player_turn() or is_animating:
		return

	var unit := _get_active_unit()
	var skill := _get_skill_at(unit, index)
	if skill.is_empty() or not _can_use_skill(unit, str(skill.get("id", ""))):
		return

	pending_action = ""
	pending_skill_id = "" if pending_skill_id == str(skill.get("id", "")) else str(skill.get("id", ""))
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
