extends Control

const BATTLE_CONFIG_PATH := "res://data/battle_config.json"
const TERRAIN_TYPES_PATH := "res://data/terrain_types.json"
const GRID_COLUMNS := 15
const GRID_ROWS := 10
const SETUP_COLUMNS := 3
const OBSTACLE_TYPES: Array[String] = ["woda", "kamienie", "krzok"]
const MAX_EVENT_LOG_ENTRIES := 60
const CARD_SELECTED_FONT_COLOR := Color(0.99, 0.95, 0.84, 1.0)
const TURN_QUEUE_CARD_SIZE := Vector2(128.0, 56.0)
const TURN_QUEUE_PORTRAIT_SIZE := Vector2(42.0, 50.0)
const TURN_QUEUE_PLACEHOLDER_PORTRAIT: Texture2D = preload("res://assets/ui/unit1.png")
const LOG_COLOR_YELLOW := Color(0.95, 0.82, 0.25, 1.0)
const LOG_COLOR_PLAYER := Color(0.35, 0.65, 0.95, 1.0)
const LOG_COLOR_ENEMY := Color(0.92, 0.35, 0.30, 1.0)
const LOG_COLOR_DAMAGE := Color(0.92, 0.35, 0.30, 1.0)
const TEAM_SETUP_SCENE: PackedScene = preload("res://scenes/team_setup.tscn")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")

var OBSTACLE_PORTRAITS: Dictionary = {
	"woda": preload("res://assets/mapTiles/water.png"),
	"kamienie": preload("res://assets/mapTiles/rock1.png"),
	"krzok": load("res://assets/mapTiles/bush.png"),
}
const OBSTACLE_NAMES: Dictionary = {
	"woda": "Woda",
	"kamienie": "Kamienie",
	"krzok": "Krzak",
}
const OBSTACLE_DESCRIPTIONS: Dictionary = {
	"woda": "Wejscie do wody zuzywa caly pozostaly ruch w tej turze.",
	"kamienie": "Przez kamienie nie da sie przejsc. Blokuja linie strzalu.",
	"krzok": "Jednostka w krzaku jest niewidzialna dla wrogow poza sasiednim krzakiem.",
}

@onready var board: Node2D = $BattleLayer/PlanszaWalki
@onready var hud: CanvasLayer = $HUD
@onready var left_panel: NinePatchRect = $HUD/Overlay/LeftPanel
@onready var left_content: VBoxContainer = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent
@onready var top_bar: NinePatchRect = $HUD/Overlay/TopBar
@onready var turn_queue_list: HBoxContainer = $HUD/Overlay/TopBar/TopMargin/TopQueueScroll/TopQueueList
@onready var setup_hint: VBoxContainer = $HUD/Overlay/SetupHint
@onready var unit_portrait: TextureRect = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitPortrait
@onready var unit_name_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitHeaderText/UnitName
@onready var unit_meta_label: Label = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitHeader/UnitHeaderMargin/UnitHeaderContent/UnitHeaderText/UnitMeta
@onready var unit_stats_display: VBoxContainer = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitStatsPanel/UnitStatsMargin/UnitStats
@onready var unit_status_panel: HBoxContainer = $HUD/Overlay/LeftPanel/LeftMargin/LeftContent/UnitStatusPanel/UnitStatusMargin/UnitStatus
@onready var unit_abilities_panel_frame: NinePatchRect = $HUD/Overlay/UnitAbilitiesPanel
@onready var unit_abilities_panel: VBoxContainer = $HUD/Overlay/UnitAbilitiesPanel/UnitAbilitiesMargin/UnitAbilities
@onready var actions_label: Label = get_node_or_null("HUD/Overlay/LeftPanel/LeftMargin/LeftContent/ActionsPanel/ActionsMargin/ActionsLabel")
@onready var general_name_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralHeader/GeneralHeaderText/GeneralName
@onready var general_level_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralHeader/GeneralHeaderText/GeneralLevel
@onready var general_rule_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralRule
@onready var general_ability_button_1: Button = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralSkillsButtons/GeneralAbilityButton1
@onready var general_ability_button_2: Button = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralSkillsButtons/GeneralAbilityButton2
@onready var event_log_scroll: ScrollContainer = $HUD/Overlay/RightPanel/RightMargin/RightContent/EventLogPanel/EventLogScroll
@onready var event_log_label: RichTextLabel = $HUD/Overlay/RightPanel/RightMargin/RightContent/EventLogPanel/EventLogScroll/EventLog
@onready var end_turn_button: Button = $HUD/Overlay/RightPanel/RightMargin/RightContent/EndTurnButton
@onready var move_cost_label: Label = $HUD/Overlay/MoveCostLabel

var units: Array = []
var obstacles: Array[Dictionary] = []
var terrain_types: Dictionary = {}
var selected_unit_id := -1
var active_unit_id := -1
var current_turn := ""
var is_animating := false
var event_log: Array[String] = []
var round_number := 1
var turn_queue: Array[int] = []
var turn_queue_index := -1
var pending_skill_id := ""
var unit_configs: Array[Dictionary] = []
var skill_library: Dictionary = {}
var general_skills: Dictionary = {}
var general_skill_ids: Array[String] = []
var general_skill_used := false
var terrain_effects: Array[Dictionary] = []
var setup_mode := true
var setup_drag_unit_id := -1
var last_battle_config_source := ""
var setup_controls: HBoxContainer
var start_battle_button: Button
var reset_battle_button: Button
var reload_json_button: Button
var current_player_faction := ""
var current_enemy_faction := ""
var help_popup: PanelContainer
var tutorial_acknowledged := false
var displayed_path_cost := -1
var selected_obstacle_cell := Vector2i(-1, -1)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disable_hud_mouse(hud)
	_build_help_popup()
	_load_terrain_types()
	_unit_type_library_warn()
	_show_team_setup()


func _load_terrain_types() -> void:
	var parsed: Variant = JSON.parse_string(_read_json_text(TERRAIN_TYPES_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Nie mozna wczytac terrain_types.json")
		terrain_types = {}
		return
	var data: Dictionary = parsed
	var raw_types: Dictionary = data.get("terrain_types", {})
	terrain_types = {}
	for terrain_id in raw_types.keys():
		var raw: Variant = raw_types[terrain_id]
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var terrain: Dictionary = raw.duplicate(true)
		terrain["id"] = str(terrain_id)
		terrain["movement_cost"] = int(terrain.get("movement_cost", 1))
		terrain["blocks_movement"] = bool(terrain.get("blocks_movement", false))
		terrain["blocks_line_of_sight"] = bool(terrain.get("blocks_line_of_sight", false))
		terrain_types[str(terrain_id)] = terrain


func _read_json_text(path: String) -> String:
	var disk_path: String = ProjectSettings.globalize_path(path)
	var file: FileAccess = FileAccess.open(disk_path, FileAccess.READ)
	if file != null:
		return file.get_as_text()
	file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		return file.get_as_text()
	return ""


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		_toggle_help_popup()
		get_viewport().set_input_as_handled()


func _unit_type_library_warn() -> void:
	if UnitTypeLibraryScript.get_faction_ids().is_empty():
		push_warning("UnitTypeLibrary nie wczytal zadnych frakcji. Sprawdz data/unit_types.json.")


func _show_team_setup() -> void:
	var existing_setup: Control = get_node_or_null("TeamSetup")
	if existing_setup != null:
		existing_setup.free()
	var setup: Control = TEAM_SETUP_SCENE.instantiate()
	setup.name = "TeamSetup"
	setup.setup_finished.connect(_on_team_setup_finished)
	add_child(setup)
	if hud != null:
		hud.visible = false
	if board != null:
		board.visible = false


func _on_team_setup_finished(player_faction: String, enemy_faction: String) -> void:
	current_player_faction = player_faction
	current_enemy_faction = enemy_faction
	skill_library = UnitTypeLibraryScript.get_skill_library()
	_load_general_skills()
	var setup: Control = get_node_or_null("TeamSetup")
	if setup != null:
		setup.queue_free()
	if hud != null:
		hud.visible = true
	if board != null:
		board.visible = true
	_build_battle_config_from_factions(player_faction, enemy_faction)
	_setup_battle_scene()


func _load_general_skills() -> void:
	general_skills = UnitTypeLibraryScript.get_general_skills()
	general_skill_ids = []
	for skill_id in general_skills.keys():
		general_skill_ids.append(str(skill_id))
	general_skill_used = false


func _build_battle_config_from_factions(player_faction: String, enemy_faction: String) -> void:
	var player_units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(player_faction)
	var enemy_units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(enemy_faction)
	var next_id := 1
	var player_positions := _compute_player_positions(player_units.size())
	var enemy_positions := _compute_enemy_positions(enemy_units.size())
	unit_configs.clear()
	for index in player_units.size():
		var type_id: String = str(player_units[index].get("id", ""))
		var pos: Vector2i = player_positions[index]
		unit_configs.append({
			"id": next_id,
			"type_id": type_id,
			"side": "player",
			"grid_x": pos.x,
			"grid_y": pos.y,
		})
		next_id += 1
	for index in enemy_units.size():
		var type_id: String = str(enemy_units[index].get("id", ""))
		var pos: Vector2i = enemy_positions[index]
		unit_configs.append({
			"id": next_id,
			"type_id": type_id,
			"side": "enemy",
			"grid_x": pos.x,
			"grid_y": pos.y,
		})
		next_id += 1


func _build_battle_config_from_selection(player_types: Array[String], enemy_types: Array[String]) -> void:
	var next_id := 1
	var player_positions := _compute_player_positions(player_types.size())
	var enemy_positions := _compute_enemy_positions(enemy_types.size())
	unit_configs.clear()
	for index in player_types.size():
		var type_id: String = player_types[index]
		var pos: Vector2i = player_positions[index]
		unit_configs.append({
			"id": next_id,
			"type_id": type_id,
			"side": "player",
			"grid_x": pos.x,
			"grid_y": pos.y,
		})
		next_id += 1
	for index in enemy_types.size():
		var type_id: String = enemy_types[index]
		var pos: Vector2i = enemy_positions[index]
		unit_configs.append({
			"id": next_id,
			"type_id": type_id,
			"side": "enemy",
			"grid_x": pos.x,
			"grid_y": pos.y,
		})
		next_id += 1


func _compute_player_positions(count: int) -> Array[Vector2i]:
	var center_y := GRID_ROWS / 2
	var result: Array[Vector2i] = []
	match count:
		1:
			result = [Vector2i(1, center_y)]
		2:
			result = [Vector2i(1, center_y - 1), Vector2i(1, center_y + 1)]
		3:
			result = [Vector2i(2, center_y), Vector2i(1, center_y - 1), Vector2i(1, center_y + 1)]
		4:
			result = [Vector2i(2, center_y - 1), Vector2i(2, center_y + 1), Vector2i(1, center_y - 2), Vector2i(1, center_y + 2)]
		_:
			for index in count:
				result.append(Vector2i(1 + (index % 2), center_y + index - count / 2))
	return _clamp_positions(result)


func _compute_enemy_positions(count: int) -> Array[Vector2i]:
	var center_y := GRID_ROWS / 2
	var right_x := GRID_COLUMNS - 2
	var result: Array[Vector2i] = []
	match count:
		1:
			result = [Vector2i(right_x, center_y)]
		2:
			result = [Vector2i(right_x, center_y - 1), Vector2i(right_x, center_y + 1)]
		3:
			result = [Vector2i(right_x - 1, center_y), Vector2i(right_x, center_y - 1), Vector2i(right_x, center_y + 1)]
		4:
			result = [Vector2i(right_x - 1, center_y - 1), Vector2i(right_x - 1, center_y + 1), Vector2i(right_x, center_y - 2), Vector2i(right_x, center_y + 2)]
		_:
			for index in count:
				result.append(Vector2i(right_x - (index % 2), center_y + index - count / 2))
	return _clamp_positions(result)


func _clamp_positions(positions: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for pos in positions:
		result.append(Vector2i(clampi(pos.x, 0, GRID_COLUMNS - 1), clampi(pos.y, 0, GRID_ROWS - 1)))
	return result


func _setup_battle_scene() -> void:
	_build_setup_controls()
	_connect_signal_once(board.cell_clicked, _on_cell_clicked)
	_connect_signal_once(board.cell_left_released, _on_cell_left_released)
	_connect_signal_once(board.cell_right_clicked, _on_cell_right_clicked)
	_connect_signal_once(board.cell_hovered, _on_board_cell_hovered)
	_connect_signal_once(board.animation_finished, _on_board_animation_finished)
	_connect_signal_once(unit_abilities_panel.skill_pressed, _on_skill_button_pressed)
	_connect_signal_once(end_turn_button.pressed, _on_end_turn_button_pressed)
	_connect_signal_once(general_ability_button_1.pressed, _on_general_ability_1_pressed)
	_connect_signal_once(general_ability_button_2.pressed, _on_general_ability_2_pressed)
	general_name_label.text = "KAPITAN ALARIC"
	general_level_label.text = "Poziom 5"
	_refresh_general_ability_buttons()
	_clear_unit_details()
	event_log_label.bbcode_enabled = true
	_load_skill_library()
	_enter_setup_mode()


func _load_skill_library() -> void:
	skill_library = UnitTypeLibraryScript.get_skill_library()


func _build_setup_controls() -> void:
	if is_instance_valid(setup_controls):
		return
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


func _connect_signal_once(source_signal: Signal, callback: Callable) -> void:
	if not source_signal.is_connected(callback):
		source_signal.connect(callback)


func _make_setup_button(text: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 36)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	return button


func _enter_setup_mode() -> void:
	setup_mode = true
	tutorial_acknowledged = false
	_update_setup_hint_visibility()
	units = unit_configs.map(func(unit: Dictionary) -> Dictionary: return _prepare_unit(unit.duplicate(true)))
	obstacles = _generate_obstacles()
	terrain_effects = []
	selected_unit_id = -1
	setup_drag_unit_id = -1
	active_unit_id = -1
	current_turn = ""
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
	board.set_terrain_effects(terrain_effects)
	selected_obstacle_cell = Vector2i(-1, -1)
	_update_end_turn_button_text()
	_log_event(_color_log_text("Tryb przygotowania: ustaw jednostki i kliknij START.", LOG_COLOR_YELLOW))
	_sync_board()
	if help_popup != null and hud.visible:
		help_popup.visible = true


func _on_start_battle_pressed() -> void:
	if not setup_mode:
		return
	setup_mode = false
	_update_setup_hint_visibility()
	selected_unit_id = -1
	selected_obstacle_cell = Vector2i(-1, -1)
	active_unit_id = -1
	current_turn = ""
	pending_skill_id = ""
	round_number = 1
	turn_queue_index = -1
	event_log.clear()
	_update_end_turn_button_text()
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	_log_event(_color_log_text("Bitwa rozpoczeta.", LOG_COLOR_YELLOW))
	_rebuild_turn_queue()
	_start_next_activation()


func _on_reset_battle_pressed() -> void:
	setup_mode = true
	_update_setup_hint_visibility()
	current_player_faction = ""
	current_enemy_faction = ""
	selected_unit_id = -1
	setup_drag_unit_id = -1
	active_unit_id = -1
	current_turn = ""
	pending_skill_id = ""
	selected_obstacle_cell = Vector2i(-1, -1)
	is_animating = false
	turn_queue_index = -1
	event_log.clear()
	unit_configs.clear()
	units.clear()
	obstacles.clear()
	terrain_effects.clear()
	_clear_selected_unit()
	_show_team_setup()


func _on_reload_json_pressed() -> void:
	UnitTypeLibraryScript.reload()
	_reload_selected_factions()
	_validate_setup()
	if setup_mode:
		_enter_setup_mode()
		return
	_apply_live_reload()


func _reload_selected_factions() -> void:
	skill_library = UnitTypeLibraryScript.get_skill_library()
	_load_general_skills()
	last_battle_config_source = ProjectSettings.globalize_path(UnitTypeLibraryScript.UNIT_TYPES_PATH)
	if current_player_faction == "" or current_enemy_faction == "":
		_load_battle_config()
		return
	_build_battle_config_from_factions(current_player_faction, current_enemy_faction)
	_debug_reload_snapshot("JSON", unit_configs)
	_refresh_general_ability_buttons()


func _load_battle_config() -> void:
	var parsed: Variant = JSON.parse_string(_read_battle_config_text())
	assert(typeof(parsed) == TYPE_DICTIONARY, "Plik konfiguracyjny musi zawierac obiekt JSON.")

	var config: Dictionary = parsed
	var raw_units: Array = config.get("units", [])
	unit_configs.clear()
	for raw_unit in raw_units:
		assert(typeof(raw_unit) == TYPE_DICTIONARY, "Kazda jednostka w JSON musi byc obiektem.")
		var unit_data: Dictionary = _normalize_unit_config(raw_unit)
		unit_configs.append(unit_data)

	var raw_skill_library: Dictionary = config.get("skill_library", {})
	skill_library = UnitTypeLibraryScript.get_skill_library()
	for skill_id in raw_skill_library.keys():
		var raw_skill: Variant = raw_skill_library[skill_id]
		assert(typeof(raw_skill) == TYPE_DICTIONARY, "Kazdy skill w JSON musi byc obiektem.")
		var skill_data: Dictionary = _normalize_skill_config(str(skill_id), raw_skill)
		skill_library[str(skill_id)] = skill_data

	_debug_reload_snapshot("JSON", unit_configs)


func _read_battle_config_text() -> String:
	var disk_path: String = ProjectSettings.globalize_path(BATTLE_CONFIG_PATH)
	var file: FileAccess = FileAccess.open(disk_path, FileAccess.READ)
	if file != null:
		last_battle_config_source = disk_path
		return file.get_as_text()

	file = FileAccess.open(BATTLE_CONFIG_PATH, FileAccess.READ)
	assert(file != null, "Nie mozna otworzyc pliku konfiguracyjnego: %s" % BATTLE_CONFIG_PATH)
	last_battle_config_source = BATTLE_CONFIG_PATH
	return file.get_as_text()


func _normalize_unit_config(raw_unit: Dictionary) -> Dictionary:
	var normalized: Dictionary = raw_unit.duplicate(true)
	for key in ["id", "grid_x", "grid_y"]:
		normalized[key] = int(normalized.get(key, 0))
	for key in ["type_id", "side"]:
		normalized[key] = str(normalized.get(key, ""))
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
	var type_id: String = str(unit.get("type_id", ""))
	if type_id != "":
		var type_data: Dictionary = UnitTypeLibraryScript.lookup(type_id)
		if not type_data.is_empty():
			for key in type_data.keys():
				if key == "id":
					continue
				if not unit.has(key):
					unit[key] = type_data[key]
			var type_skill_ids: Array = type_data.get("skill_ids", [])
			if not unit.has("skill_ids"):
				unit["skill_ids"] = type_skill_ids.duplicate()

	for stat_name in ["hp", "dmg", "def", "speed", "move_range", "attack_range", "action_points", "count"]:
		if not unit.has(stat_name):
			unit[stat_name] = 0
		unit["base_%s" % stat_name] = int(unit.get(stat_name, 0))
	unit["max_hp"] = int(unit["base_hp"])
	unit["max_total_hp"] = int(unit["base_hp"]) * max(1, int(unit["count"]))
	unit["current_total_hp"] = int(unit["max_total_hp"])
	unit["current_hp"] = int(unit["base_hp"])
	unit["remaining_move"] = int(unit.get("move_range", 0))
	unit["action_points"] = int(unit.get("base_action_points", unit.get("action_points", 1)))
	unit["active_effects"] = []
	unit["skill_cooldowns"] = {}
	unit["buffs"] = "Brak"
	unit["debuffs"] = "Brak"
	unit["is_hidden"] = false
	unit["is_revealed"] = false
	_recalculate_unit_stats(unit)
	return unit


func _on_unit_selected(unit_data: Dictionary) -> void:
	if is_animating:
		return
	_show_unit_details(unit_data)


func _show_unit_details(unit_data: Dictionary) -> void:
	selected_unit_id = unit_data.id
	board.set_selected_unit(unit_data.id)
	_update_selection_visibility()
	if setup_mode or unit_data.side == "player":
		_update_highlighted_cells(unit_data)
	else:
		board.set_highlighted_cells([], [])
	_render_unit_details(unit_data)
	_update_action_buttons()
	_refresh_turn_queue()


func _render_unit_details(unit_data: Dictionary) -> void:
	unit_portrait.visible = true
	var tex: Texture2D = _load_unit_portrait(unit_data)
	if tex != null:
		unit_portrait.texture = tex
	unit_name_label.text = str(unit_data.get("name", "")).to_upper()
	unit_meta_label.text = "Poziom 1"
	var current_hp: int = int(unit_data.get("current_hp", unit_data.get("hp", 0)))
	var max_hp: int = int(unit_data.get("max_hp", unit_data.get("hp", 0)))
	unit_stats_display.set_values({
		"hp": "%s / %s" % [current_hp, max_hp],
		"dmg": str(unit_data.get("dmg", 0)),
		"def": str(unit_data.get("def", 0)),
		"speed": str(unit_data.get("speed", 0)),
		"count": str(unit_data.get("count", 0)),
		"move": "%s / %s" % [_get_display_move(unit_data), unit_data.get("move_range", 0)],
		"action_points": str(_get_display_action_points(unit_data)),
	})
	unit_status_panel.set_unit(unit_data)
	unit_abilities_panel.set_skills(_build_skill_cards(unit_data))
	if actions_label != null:
		actions_label.text = "Umiejetnosci: %s" % _format_skill_list(unit_data)


func _load_unit_portrait(unit_data: Dictionary) -> Texture2D:
	var portrait_path: String = str(unit_data.get("portrait", ""))
	if portrait_path == "":
		var type_id: String = str(unit_data.get("type_id", ""))
		if type_id != "":
			var type_data: Dictionary = UnitTypeLibraryScript.lookup(type_id)
			portrait_path = str(type_data.get("portrait", ""))
	if portrait_path == "":
		return null
	var res: Resource = load(portrait_path)
	if res is Texture2D:
		return res
	return null


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
	pending_skill_id = ""
	is_animating = false
	_rebuild_turn_queue()
	if not _find_unit_by_id(active_unit_id).is_empty():
		turn_queue_index = maxi(turn_queue.find(active_unit_id) - 1, -1)
	board.set_units(units)
	board.reset_unit_positions(units)
	_sync_board()
	_debug_reload_snapshot("RUNTIME", units)
	_log_event(_color_log_text("Przeladowano JSON w trakcie rozgrywki.", LOG_COLOR_YELLOW))


func _reapply_runtime_state(target_unit: Dictionary, existing_unit: Dictionary) -> void:
	target_unit["grid_x"] = int(existing_unit.get("grid_x", 0))
	target_unit["grid_y"] = int(existing_unit.get("grid_y", 0))
	_recalculate_unit_stats(target_unit)


func _debug_reload_snapshot(stage: String, source_units: Array) -> void:
	var lines: Array[String] = [
		"[RELOAD %s] source=%s units=%s skills=%s" % [
			stage,
			last_battle_config_source,
			source_units.size(),
			skill_library.size()
		]
	]
	for unit_data in source_units:
		if typeof(unit_data) != TYPE_DICTIONARY:
			continue
		var skill_ids: Array = unit_data.get("skill_ids", [])
		lines.append(
			"[RELOAD %s] id=%s name=%s hp=%s dmg=%s def=%s spd=%s move=%s range=%s count=%s skills=%s" % [
				stage,
				str(unit_data.get("id", -1)),
				str(unit_data.get("name", "?")),
				str(unit_data.get("hp", unit_data.get("base_hp", 0))),
				str(unit_data.get("dmg", unit_data.get("base_dmg", 0))),
				str(unit_data.get("def", unit_data.get("base_def", 0))),
				str(unit_data.get("speed", unit_data.get("base_speed", 0))),
				str(unit_data.get("move_range", unit_data.get("base_move_range", 0))),
				str(unit_data.get("attack_range", unit_data.get("base_attack_range", 0))),
				str(unit_data.get("count", 0)),
				",".join(PackedStringArray(skill_ids))
			]
		)
	for line in lines:
		print(line)
	_log_event(_color_log_text("[DIAG] %s %s" % [stage, last_battle_config_source], LOG_COLOR_YELLOW))


func _format_skill_list(unit_data: Dictionary) -> String:
	var skill_ids: Array = unit_data.get("skill_ids", [])
	if skill_ids.is_empty():
		return "Brak"
	var names: Array[String] = []
	for skill_id in skill_ids:
		names.append(_get_skill_name(str(skill_id)))
	return ", ".join(names)


func _build_skill_cards(unit_data: Dictionary) -> Array:
	var cards: Array = []
	var cooldowns: Dictionary = unit_data.get("skill_cooldowns", {})
	var can_act := _can_interact_with_unit_skills(unit_data)
	var skill_ids: Array = unit_data.get("skill_ids", [])
	for index in skill_ids.size():
		var skill_id := str(skill_ids[index])
		var skill: Dictionary = skill_library.get(skill_id, {})
		if skill.is_empty():
			continue
		cards.append({
			"index": index,
			"skill_id": skill_id,
			"name": str(skill.get("name", skill_id)),
			"description": str(skill.get("description", "")),
			"cooldown": int(skill.get("cooldown", 0)),
			"remaining_cooldown": int(cooldowns.get(skill_id, 0)),
			"can_use": can_act and _can_use_skill(unit_data, skill_id),
			"selected": pending_skill_id == skill_id,
			"tooltip": _build_skill_tooltip(unit_data, index),
		})
	return cards


func _can_interact_with_unit_skills(unit_data: Dictionary) -> bool:
	if setup_mode or is_animating or not _is_player_turn():
		return false
	var active_unit := _get_active_unit()
	return not active_unit.is_empty() and active_unit.side == "player" and selected_unit_id == active_unit.id and unit_data.id == active_unit.id


func _clear_unit_details() -> void:
	selected_obstacle_cell = Vector2i(-1, -1)
	_update_selection_visibility()
	unit_portrait.visible = false
	unit_name_label.text = "BRAK JEDNOSTEK"
	unit_meta_label.text = ""
	unit_stats_display.clear_values()
	unit_status_panel.clear()
	unit_abilities_panel.clear()
	if actions_label != null:
		actions_label.text = ""

func _render_obstacle_details(cell: Vector2i) -> void:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return
	var type_id: String = str(terrain.get("id", ""))
	unit_portrait.visible = true
	var tex: Texture2D = OBSTACLE_PORTRAITS.get(type_id, null)
	if tex != null:
		unit_portrait.texture = tex
	unit_name_label.text = str(OBSTACLE_NAMES.get(type_id, type_id)).to_upper()
	unit_meta_label.text = "Przeszkoda terenowa"
	unit_stats_display.set_values({})
	unit_status_panel.clear()
	unit_abilities_panel.clear()
	if actions_label != null:
		actions_label.text = str(OBSTACLE_DESCRIPTIONS.get(type_id, ""))

func _show_obstacle_details(cell: Vector2i) -> void:
	selected_unit_id = -1
	selected_obstacle_cell = cell
	board.set_selected_unit(-1)
	_update_selection_visibility()
	board.set_highlighted_cells([], [])
	board.set_hovered_move_path([])
	_render_obstacle_details(cell)
	_refresh_turn_queue()


func _clear_selected_unit() -> void:
	selected_unit_id = -1
	setup_drag_unit_id = -1
	pending_skill_id = ""
	selected_obstacle_cell = Vector2i(-1, -1)
	board.set_selected_unit(-1)
	_update_selection_visibility()
	board.set_highlighted_cells([], [])
	board.set_hovered_move_path([])
	_clear_unit_details()
	_update_action_buttons()
	_refresh_turn_queue()


func _show_move_cost_label(cost: int, remaining: int) -> void:
	displayed_path_cost = cost
	if move_cost_label == null:
		return
	move_cost_label.text = "Koszt ruchu: %s (pozostanie: %s)" % [cost, remaining]
	move_cost_label.visible = true


func _clear_move_cost_label() -> void:
	displayed_path_cost = -1
	if move_cost_label == null:
		return
	move_cost_label.text = ""
	move_cost_label.visible = false


func _stop_unit_on_terrain(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	if not _terrain_skips_turn(cell):
		return
	unit.remaining_move = 0
	unit.action_points = 0


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
	if not clicked_unit.is_empty():
		if clicked_unit.id == selected_unit_id:
			_clear_selected_unit()
			return
		selected_unit_id = clicked_unit.id
		selected_obstacle_cell = Vector2i(-1, -1)
		_show_unit_details(clicked_unit)
		return

	if selected_unit_id != active_unit.id:
		selected_unit_id = active_unit.id
		_show_unit_details(active_unit)
		# Nie wykonuj ruchu, dopóki użytkownik nie ma zaznaczonej jednostki.
		# Pierwszy klik tylko zaznacza, kolejny dopiero rusza.
		return

	var remaining_move: int = _get_remaining_move(active_unit)
	if remaining_move <= 0:
		return

	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell)
	var path_cost: int = _get_path_cost(path)
	if path.is_empty():
		if _is_cell_obstacle(cell):
			_show_obstacle_details(cell)
		return
	if path_cost > remaining_move:
		return

	var move_path: Array[Vector2i] = _get_executable_move_path(path)
	var move_cost: int = _get_path_cost(move_path)
	is_animating = true
	var destination: Vector2i = move_path[move_path.size() - 1]
	active_unit.grid_x = destination.x
	active_unit.grid_y = destination.y
	active_unit.remaining_move = max(0, remaining_move - move_cost)
	pending_skill_id = ""
	_sync_board()
	_show_move_cost_label(move_cost, active_unit.remaining_move)
	board.animate_unit_path(active_unit.id, move_path)
	await board.animation_finished
	_clear_move_cost_label()
	_log_event("%s przemieszcza sie." % _unit_name_log_text(active_unit))
	_apply_terrain_effects_to_unit(active_unit)
	_stop_unit_on_terrain(active_unit)
	_try_trigger_agility(active_unit)
	_sync_board()


func _on_cell_right_clicked(cell: Vector2i) -> void:
	if setup_mode or is_animating or not _is_player_turn():
		return
	var active_unit := _get_active_unit()
	if active_unit.is_empty() or active_unit.side != "player" or selected_unit_id != active_unit.id:
		return
	var target := _find_unit_at_cell(cell)
	if target.is_empty() or target.side == active_unit.side:
		return
	if not _can_see_target(active_unit, target):
		return
	if _can_unit_attack(active_unit) and _is_in_attack_range(active_unit, cell):
		_perform_basic_attack(active_unit, target, false)


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
	pending_skill_id = ""
	selected_unit_id = -1
	selected_obstacle_cell = Vector2i(-1, -1)
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
	if _try_enemy_use_skill(enemy_unit, target):
		target = _find_nearest_player_unit(enemy_unit)
		if enemy_unit.is_empty() or target.is_empty():
			_end_current_activation()
			return

	var best_path := _find_best_enemy_path(enemy_unit, target)
	if not best_path.is_empty():
		best_path = _get_executable_move_path(best_path)
		var destination: Vector2i = best_path[best_path.size() - 1]
		var path_cost: int = _get_path_cost(best_path)
		is_animating = true
		enemy_unit.grid_x = destination.x
		enemy_unit.grid_y = destination.y
		enemy_unit.remaining_move = max(0, _get_remaining_move(enemy_unit) - path_cost)
		_sync_board()
		_show_move_cost_label(path_cost, enemy_unit.remaining_move)
		board.animate_unit_path(enemy_unit.id, best_path)
		await board.animation_finished
		_clear_move_cost_label()
		_log_event("%s przemieszcza sie." % _unit_name_log_text(enemy_unit))
		_apply_terrain_effects_to_unit(enemy_unit)
		_stop_unit_on_terrain(enemy_unit)
		_try_trigger_agility(enemy_unit)

	target = _find_nearest_player_unit(enemy_unit)
	if not enemy_unit.is_empty() and not target.is_empty() and _try_enemy_use_skill(enemy_unit, target):
		_end_current_activation()
		return
	if not enemy_unit.is_empty() and not target.is_empty() and _can_see_target(enemy_unit, target) and _can_unit_attack(enemy_unit) and _is_in_attack_range(enemy_unit, Vector2i(target.grid_x, target.grid_y)):
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
	if not forced_target.is_empty() and _can_see_target(enemy_unit, forced_target):
		return forced_target

	var nearest: Dictionary = {}
	var nearest_unseen: Dictionary = {}
	var best_distance: float = INF
	var best_unseen_distance: float = INF
	for unit in units:
		if unit.side != "player":
			continue
		var distance: int = _hex_distance(
			Vector2i(enemy_unit.grid_x, enemy_unit.grid_y),
			Vector2i(unit.grid_x, unit.grid_y)
		)
		if not _can_see_target(enemy_unit, unit):
			if distance < best_unseen_distance:
				best_unseen_distance = distance
				nearest_unseen = unit
			continue
		if distance < best_distance:
			best_distance = distance
			nearest = unit
	return nearest if not nearest.is_empty() else nearest_unseen


func _get_forced_target(unit: Dictionary) -> Dictionary:
	for effect in unit.get("active_effects", []):
		if effect.get("forced_target_id", -1) == -1:
			continue
		var target: Dictionary = _find_unit_by_id(int(effect.forced_target_id))
		if not target.is_empty():
			return target
	return {}


func _find_best_enemy_path(enemy_unit: Dictionary, target: Dictionary) -> Array[Vector2i]:
	var origin := Vector2i(enemy_unit.grid_x, enemy_unit.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _can_see_target(enemy_unit, target) and _can_unit_attack(enemy_unit) and _is_in_attack_range(enemy_unit, target_cell):
		return []
	var reachable_cells: Array[Vector2i] = _get_reachable_cells(enemy_unit, _get_remaining_move(enemy_unit))
	var best_path: Array[Vector2i] = []
	var preferred_distance: int = 1 if not _can_see_target(enemy_unit, target) else min(int(enemy_unit.get("attack_range", 1)), _hex_distance(origin, target_cell))
	var best_score: int = abs(_hex_distance(origin, target_cell) - preferred_distance) * 10
	for cell in reachable_cells:
		var candidate_path: Array[Vector2i] = _find_path(enemy_unit, origin, cell)
		if candidate_path.is_empty():
			continue
		var candidate_distance: int = _hex_distance(cell, target_cell)
		var candidate_score: int = abs(candidate_distance - preferred_distance) * 10 + _get_path_hazard_penalty(enemy_unit, candidate_path)
		if _can_unit_attack(enemy_unit) and not _is_attack_blocked({"grid_x": cell.x, "grid_y": cell.y}, target_cell) and candidate_distance <= int(enemy_unit.get("attack_range", 1)):
			candidate_score -= 5
		if candidate_score < best_score:
			best_score = candidate_score
			best_path = candidate_path
	return best_path


func _get_path_hazard_penalty(unit: Dictionary, path: Array[Vector2i]) -> int:
	var penalty := 0
	for cell in path:
		if _is_known_bear_trap_for_unit(unit, cell):
			penalty += 1000
		if _is_hostile_terrain_effect_for_unit(unit, cell):
			penalty += 200
		if _terrain_skips_turn(cell):
			penalty += 100
	return penalty


func _is_hostile_terrain_effect_for_unit(unit: Dictionary, cell: Vector2i) -> bool:
	for effect in terrain_effects:
		if int(effect.get("grid_x", -1)) != cell.x or int(effect.get("grid_y", -1)) != cell.y:
			continue
		if str(effect.get("caster_side", "")) == str(unit.side):
			continue
		if ["fire", "ice", "poison_cloud", "bear_trap"].has(str(effect.get("id", ""))):
			return true
	return false


func _is_known_bear_trap_for_unit(unit: Dictionary, cell: Vector2i) -> bool:
	var trap: Dictionary = _get_terrain_effect_at(cell, "bear_trap")
	if trap.is_empty():
		return false
	var caster_side: String = str(trap.get("caster_side", ""))
	if caster_side == str(unit.side):
		return not _terrain_hides_unit(cell)
	if Time.get_ticks_msec() <= int(trap.get("visible_until_ms", 0)):
		return true
	return unit.side == "enemy" and int(trap.get("enemy_memory_until_round", 0)) >= round_number


func _try_enemy_use_bear_trap(enemy_unit: Dictionary, target: Dictionary) -> bool:
	if not _can_use_skill(enemy_unit, "pulapka_na_niedzwiedzie"):
		return false
	var origin := Vector2i(enemy_unit.grid_x, enemy_unit.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	for cell in _get_neighbors(target_cell):
		if _hex_distance(origin, cell) > 3:
			continue
		if _is_attack_blocked(enemy_unit, cell) or _blocks_cell_skill_target(cell):
			continue
		if not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, "bear_trap").is_empty():
			continue
		_execute_skill(enemy_unit, {}, skill_library.get("pulapka_na_niedzwiedzie", {}), cell)
		return true
	return false


func _try_enemy_use_skill(enemy_unit: Dictionary, target: Dictionary) -> bool:
	if not _can_see_target(enemy_unit, target):
		return false
	if _try_enemy_use_bear_trap(enemy_unit, target):
		return true
	for skill_id in enemy_unit.get("skill_ids", []):
		var skill: Dictionary = skill_library.get(str(skill_id), {})
		if skill.is_empty() or not _can_use_skill(enemy_unit, str(skill_id)):
			continue
		var target_type := str(skill.get("target_type", ""))
		var target_cell := Vector2i(target.grid_x, target.grid_y)
		if target_type == "self" and not _has_effect(enemy_unit, str(skill.get("id", ""))):
			_execute_skill(enemy_unit, enemy_unit, skill, Vector2i(enemy_unit.grid_x, enemy_unit.grid_y))
			return true
		if target_type == "enemy_unit" and _hex_distance(Vector2i(enemy_unit.grid_x, enemy_unit.grid_y), target_cell) <= int(skill.get("range", 0)) and not _is_attack_blocked(enemy_unit, target_cell):
			_execute_skill(enemy_unit, target, skill, target_cell)
			return true
		if target_type == "cell" and str(skill.get("effect_type", "")) != "bear_trap":
			var cell := _find_enemy_area_skill_cell(enemy_unit, skill)
			if cell != Vector2i(-1, -1):
				_execute_skill(enemy_unit, {}, skill, cell)
				return true
	return false


func _find_enemy_area_skill_cell(enemy_unit: Dictionary, skill: Dictionary) -> Vector2i:
	var best_cell := Vector2i(-1, -1)
	var best_score := 0
	for cell in _get_skill_target_cells(enemy_unit, str(skill.get("id", ""))):
		var score := 0
		for area_cell in _get_area_cells(cell):
			var unit := _find_unit_at_cell(area_cell)
			if unit.is_empty():
				continue
			score += 2 if unit.side != enemy_unit.side else -3
		if score > best_score:
			best_score = score
			best_cell = cell
	return best_cell


func _sync_board() -> void:
	for unit in units:
		_recalculate_unit_stats(unit)
	board.set_units(units)
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	if board.has_method("set_viewer_side"):
		board.set_viewer_side("player")
	_update_selection_visibility()
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


func _update_selection_visibility() -> void:
	var has_unit_selection := not _find_unit_by_id(selected_unit_id).is_empty()
	var has_obstacle_selection := selected_obstacle_cell.x != -1
	if board.has_method("set_grid_visible"):
		board.set_grid_visible(true)
	left_panel.visible = setup_mode or has_unit_selection or has_obstacle_selection
	unit_abilities_panel_frame.visible = has_unit_selection


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
	general_rule_label.text = "Aktywna jednostka: %s (%s)\nLPM wybiera i porusza. PPM atakuje. Tab pokazuje pomoc. Tura %s." % [active_name, turn_name, round_number]


func _update_setup_hint_visibility() -> void:
	if setup_hint == null:
		return
	setup_hint.visible = setup_mode and tutorial_acknowledged


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

	var move_budget: int = int(unit.get("move_range", 0)) if unit.id != active_unit_id else _get_remaining_move(unit)
	var move_cells: Array[Vector2i] = _get_reachable_cells(unit, move_budget)
	var attack_cells: Array[Vector2i] = []
	if unit.id == active_unit_id and pending_skill_id != "":
		attack_cells = _get_skill_target_cells(unit, pending_skill_id)
		move_cells = []
	elif unit.id == active_unit_id and pending_skill_id == "" and _can_unit_attack(unit):
		attack_cells = _get_attackable_cells(unit)
	var move_opacity_mult: float = 0.5 if unit.id != active_unit_id else 1.0
	board.set_highlighted_cells(move_cells, attack_cells, move_opacity_mult)
	_on_board_cell_hovered(board.get_hovered_cell())


func _on_board_cell_hovered(cell: Vector2i) -> void:
	if setup_mode:
		board.set_hovered_move_path([])
		_clear_move_cost_label()
		if selected_unit_id == -1 or cell.x == -1:
			return
		var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
		if selected_unit.is_empty() or not _can_place_setup_unit(selected_unit, cell):
			return
		board.set_hovered_move_path([cell])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return

	if is_animating or pending_skill_id != "":
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	var active_unit := _get_active_unit()
	if active_unit.is_empty() or active_unit.side != "player":
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	if selected_unit_id != active_unit.id:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	if cell.x == -1:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	var hovered_unit: Dictionary = _find_unit_at_cell(cell)
	if not hovered_unit.is_empty() and hovered_unit.side != active_unit.side and _can_see_target(active_unit, hovered_unit) and _can_unit_attack(active_unit) and _is_in_attack_range(active_unit, cell):
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(cell)
		_clear_move_cost_label()
		return

	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell)
	var path_cost: int = _get_path_cost(path)
	var remaining: int = _get_remaining_move(active_unit)
	if path.is_empty() or path_cost > remaining:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	board.set_hovered_move_path(path)
	board.set_hovered_attack_cell(Vector2i(-1, -1))
	_show_move_cost_label(path_cost, remaining - path_cost)


func _get_reachable_cells(unit: Dictionary, max_distance: int) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var blocked: Dictionary = _get_blocked_cells(unit.id)
	var costs: Dictionary = {origin: 0}
	var frontier: Array[Vector2i] = [origin]
	var reachable: Array[Vector2i] = []

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_cost: int = costs[current]
		for neighbor in _get_neighbors(current):
			if blocked.has(neighbor):
				continue
			var step_cost: int = _get_movement_cost(neighbor)
			var next_cost: int = current_cost + step_cost
			if next_cost > max_distance:
				continue
			if costs.has(neighbor) and costs[neighbor] <= next_cost:
				continue
			costs[neighbor] = next_cost
			frontier.append(neighbor)
			if not reachable.has(neighbor):
				reachable.append(neighbor)
		reachable.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return costs[a] < costs[b])

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
	if not _is_setup_cell_allowed_for_side(str(unit.side), cell):
		return false
	if _is_cell_obstacle(cell):
		return false
	if cell == Vector2i(unit.grid_x, unit.grid_y):
		return true
	var occupant: Dictionary = _find_unit_at_cell(cell)
	return occupant.is_empty()


func _is_setup_cell_allowed_for_side(side: String, cell: Vector2i) -> bool:
	if side == "player":
		return current_player_faction == "testowa" or cell.x < SETUP_COLUMNS
	if side == "enemy":
		return current_enemy_faction == "testowa" or cell.x >= GRID_COLUMNS - SETUP_COLUMNS
	return false


func _get_attackable_cells(unit: Dictionary) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var attackable: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if cell == origin:
				continue
			var target: Dictionary = _find_unit_at_cell(cell)
			if not target.is_empty() and target.side != unit.side and not _can_see_target(unit, target):
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

	var origin := Vector2i(unit.grid_x, unit.grid_y)
	var skill_range: int = int(skill.get("range", 0))
	var cells: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if cell == origin:
				continue
			if _hex_distance(origin, cell) > skill_range:
				continue
			if _is_attack_blocked(unit, cell):
				continue
			if str(skill.get("target_type", "")) == "cell" and _blocks_cell_skill_target(cell):
				continue
			cells.append(cell)
	return cells


func _is_in_attack_range(unit: Dictionary, cell: Vector2i) -> bool:
	if _hex_distance(Vector2i(int(unit.get("grid_x", 0)), int(unit.get("grid_y", 0))), cell) > int(unit.get("attack_range", 1)):
		return false
	return not _is_attack_blocked(unit, cell)


func _perform_basic_attack(attacker: Dictionary, target: Dictionary, end_turn_after := true) -> void:
	attacker.action_points = max(0, int(attacker.get("action_points", 0)) - 1)
	pending_skill_id = ""
	_reveal_if_in_bush(attacker)
	var total_damage: int = _calculate_damage(attacker, target)
	var result: Dictionary = _apply_attack_damage(attacker, target, total_damage, _hex_distance(Vector2i(attacker.grid_x, attacker.grid_y), Vector2i(target.grid_x, target.grid_y)) == 1)
	var hit_target: Dictionary = result.get("target", target)
	var casualties: int = int(result.get("casualties", 0))
	_log_event(
		"%s uderza %s za %s obrazen i zadaje %s strat." % [
			_unit_name_log_text(attacker),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_try_apply_poison_master(attacker, hit_target)
	_cleanup_destroyed_unit(hit_target)
	_sync_board()
	if end_turn_after:
		_end_current_activation()


func _calculate_damage(attacker: Dictionary, target: Dictionary, damage_multiplier := 1.0) -> int:
	var scaled_damage: int = max(1, int(ceil(float(attacker.get("dmg", 1)) * damage_multiplier)))
	var damage_per_unit: int = max(1, scaled_damage - int(target.get("def", 0)))
	return max(1, damage_per_unit * int(attacker.get("count", 1)))


func _apply_damage_to_unit(target: Dictionary, total_damage: int) -> int:
	var previous_count: int = int(target.get("count", 0))
	var base_hp: int = int(target.get("base_hp", target.get("hp", 1)))
	var current_total_hp: int = int(target.get("current_total_hp", base_hp * previous_count))
	if total_damage > 0:
		board.play_damage_animation(int(target.get("id", -1)))
		_reveal_if_in_bush(target)
	target["current_total_hp"] = max(0, current_total_hp - max(1, total_damage))
	_refresh_unit_health_state(target)
	return max(0, previous_count - int(target.get("count", 0)))


func _apply_attack_damage(attacker: Dictionary, target: Dictionary, total_damage: int, melee := false) -> Dictionary:
	var hit_target: Dictionary = target
	var damage := total_damage
	if melee:
		var guardian := _get_guardian_for(target)
		if not guardian.is_empty():
			hit_target = guardian
			damage = max(1, int(ceil(float(damage) * 0.8)))
			_log_event("%s zaslania %s Zelazna Kurtyna." % [_unit_name_log_text(guardian), _unit_name_log_text(target)])
	board.play_attack_animation(int(attacker.id), int(hit_target.id), _get_attack_projectile_kind(attacker))
	if _consume_energy_barrier(hit_target):
		_log_event("Bariera Energetyczna blokuje atak na %s." % _unit_name_log_text(hit_target))
		return {"target": hit_target, "damage": 0, "casualties": 0}
	var casualties: int = _apply_damage_to_unit(hit_target, damage)
	return {"target": hit_target, "damage": damage, "casualties": casualties}


func _get_attack_projectile_kind(attacker: Dictionary) -> String:
	if int(attacker.get("attack_range", 1)) <= 1:
		return ""
	var descriptor: String = "%s %s %s" % [
		str(attacker.get("type_id", "")),
		str(attacker.get("name", "")),
		str(attacker.get("role", ""))
	]
	var descriptor_lower: String = descriptor.to_lower()
	if descriptor_lower.contains("digger") or descriptor_lower.contains("kopacz") or descriptor_lower.contains("dynamit"):
		return "dynamite"
	if descriptor_lower.contains("mag") or descriptor_lower.contains("mage") or descriptor_lower.contains("shaman") or descriptor_lower.contains("arkan") or descriptor_lower.contains("arcano"):
		return "spell"
	return "arrows"


func _get_guardian_for(target: Dictionary) -> Dictionary:
	for effect in target.get("active_effects", []):
		var guardian_id := int(effect.get("guarded_by_id", -1))
		if guardian_id == -1:
			continue
		var guardian := _find_unit_by_id(guardian_id)
		if not guardian.is_empty() and _hex_distance(Vector2i(guardian.grid_x, guardian.grid_y), Vector2i(target.grid_x, target.grid_y)) <= 3:
			return guardian
	return {}


func _consume_energy_barrier(unit: Dictionary) -> bool:
	var effects: Array = unit.get("active_effects", [])
	for effect in effects:
		if not bool(effect.get("block_next_attack", false)):
			continue
		effects.erase(effect)
		unit["active_effects"] = effects
		if not unit.has("skill_cooldowns"):
			unit["skill_cooldowns"] = {}
		unit["skill_cooldowns"]["bariera_energetyczna"] = 5
		_recalculate_unit_stats(unit)
		return true
	return false


func _calculate_tick_damage(unit: Dictionary, effect_damage: int) -> int:
	return max(1, effect_damage * int(unit.get("count", 1)))


func _cleanup_destroyed_unit(target: Dictionary) -> void:
	if int(target.get("count", 0)) > 0:
		return
	_log_event("%s zostaje rozbite." % _unit_name_log_text(target))
	units.erase(target)
	turn_queue.erase(target.get("id", -1))
	if turn_queue_index >= turn_queue.size():
		turn_queue_index = turn_queue.size() - 1
	if target.get("id", -1) == selected_unit_id:
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
		_execute_skill(unit, unit, skill, cell)
		return

	if str(skill.get("target_type", "")) == "cell":
		if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(skill.get("range", 0)):
			return
		if _is_attack_blocked(unit, cell) or _blocks_cell_skill_target(cell):
			return
		if str(skill.get("effect_type", "")) == "bear_trap" and (not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, "bear_trap").is_empty()):
			return
		_execute_skill(unit, {}, skill, cell)
		return

	var target := _find_unit_at_cell(cell)
	if target.is_empty():
		return
	var target_type := str(skill.get("target_type", ""))
	if target_type == "enemy_unit" and target.side == unit.side:
		return
	if target_type == "enemy_unit" and not _can_see_target(unit, target):
		return
	if target_type == "ally_unit" and (target.side != unit.side or target.id == unit.id):
		return
	if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(skill.get("range", 0)):
		return
	if _is_attack_blocked(unit, cell):
		return
	_execute_skill(unit, target, skill, cell)


func _execute_skill(caster: Dictionary, target: Dictionary, skill: Dictionary, target_cell: Vector2i) -> void:
	caster.action_points = max(0, int(caster.action_points) - int(skill.get("ap_cost", 0)))
	caster.skill_cooldowns[skill.get("id", "")] = int(skill.get("cooldown", 0))
	pending_skill_id = ""
	if str(skill.get("target_type", "")) != "self":
		_reveal_if_in_bush(caster)

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
		"fireball":
			_execute_fireball(caster, target_cell)
		"ice_ground":
			_execute_ice_ground(caster, target_cell)
		"poison_cloud":
			_execute_poison_cloud(caster, target_cell)
		"bear_trap":
			_execute_bear_trap(caster, target_cell)
		"energy_barrier":
			_execute_energy_barrier(caster)
		"iron_curtain":
			_execute_iron_curtain(caster, target)
		"self_buff":
			_execute_self_buff(caster, skill)
		"focused_strike":
			_execute_focused_strike(caster, target)

	_sync_board()


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
	var result := _apply_attack_damage(caster, target, total_damage)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	if int(result.get("damage", 0)) > 0:
		_apply_or_refresh_effect(hit_target, {
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
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_poison_dagger(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.7)
	var result := _apply_attack_damage(caster, target, total_damage, true)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	if int(result.get("damage", 0)) > 0:
		_apply_poison_effect(hit_target, "toksyna", "Toksyna", 3, max(1, int(ceil(float(caster.dmg) * 0.5))), true)
	_log_event(
		"%s zatruwa %s Sztyletem za %s obrazen i %s strat." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)


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
	var result := _apply_attack_damage(caster, target, total_damage, true)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	var pushed := false
	if int(result.get("damage", 0)) > 0 and int(hit_target.id) == int(target.id):
		pushed = _try_push_unit_away(caster, target)
	if int(result.get("damage", 0)) > 0 and not pushed and int(hit_target.get("count", 0)) > 0:
		_apply_or_refresh_effect(hit_target, {
			"id": "ogluszenie",
			"name": "Ogluszenie",
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [],
			"skip_turn": true
		})
	var suffix := " Atak zostaje zablokowany."
	if int(result.get("damage", 0)) > 0:
		suffix = " Cel zostaje odepchniety." if pushed else " Cel wpada w blokade i zostaje ogluszony."
	_log_event(
		"%s uderza %s poteznie za %s obrazen i %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			suffix
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_fireball(caster: Dictionary, center: Vector2i) -> void:
	var hit_names: Array[String] = []
	for cell in _get_area_cells(center):
		var target := _find_unit_at_cell(cell)
		if target.is_empty() or target.side == caster.side:
			continue
		var multiplier := 1.0 if cell == center else 0.5
		var total_damage := _calculate_damage(caster, target, multiplier)
		var result := _apply_attack_damage(caster, target, total_damage)
		var hit_target: Dictionary = result.get("target", target)
		hit_names.append("%s (%s/%s)" % [_unit_name_log_text(hit_target), result.get("damage", total_damage), result.get("casualties", 0)])
		_cleanup_destroyed_unit(hit_target)
	_add_terrain_effect(center, "fire", 1)
	_log_event("%s rzuca Kule Ognia na hex %s: %s." % [_unit_name_log_text(caster), str(center), "brak trafien" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_ice_ground(caster: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = []
	for cell in _get_neighbors(center).slice(0, 3):
		cells.append(cell)
	if cells.is_empty():
		cells.append(center)
	for cell in cells:
		_add_terrain_effect(cell, "ice", 2)
	_apply_terrain_effects_in_cells(cells)
	_log_event("%s zamraza podloze przy hexie %s." % [_unit_name_log_text(caster), str(center)])


func _execute_poison_cloud(caster: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = _get_area_cells(center)
	for cell in cells:
		_add_terrain_effect(cell, "poison_cloud", 2, int(caster.id), max(1, int(ceil(float(caster.dmg) * 0.25))))
	_apply_terrain_effects_in_cells(cells)
	_log_event("%s tworzy Chmure Toksyczna przy hexie %s." % [_unit_name_log_text(caster), str(center)])


func _execute_bear_trap(caster: Dictionary, cell: Vector2i) -> void:
	_add_terrain_effect(cell, "bear_trap", 99, int(caster.id), max(1, int(ceil(float(caster.dmg) * 0.25))))
	var trap: Dictionary = _get_terrain_effect_at(cell, "bear_trap")
	trap["caster_side"] = str(caster.side)
	trap["visible_until_ms"] = Time.get_ticks_msec() + 5000
	trap["enemy_memory_until_round"] = round_number + 1 if caster.side == "player" else round_number
	_log_event("%s zaklada Pulapke na Niedzwiedzie na hexie %s." % [_unit_name_log_text(caster), str(cell)])


func _execute_energy_barrier(caster: Dictionary) -> void:
	_apply_energy_barrier(caster)
	_log_event("%s otacza sie Bariera Energetyczna." % _unit_name_log_text(caster))


func _execute_iron_curtain(caster: Dictionary, target: Dictionary) -> void:
	_apply_or_refresh_effect(target, {
		"id": "zelazna_kurtyna",
		"name": "Zelazna Kurtyna",
		"category": "buff",
		"remaining_turns": 2,
		"stat_changes": [],
		"guarded_by_id": int(caster.id)
	})
	_log_event("%s chroni %s Zelazna Kurtyna." % [_unit_name_log_text(caster), _unit_name_log_text(target)])


func _execute_self_buff(caster: Dictionary, skill: Dictionary) -> void:
	var effect: Dictionary = skill.get("effect", {}).duplicate(true)
	if effect.is_empty():
		return
	if str(effect.get("id", "")) == "":
		effect["id"] = str(skill.get("id", ""))
	if str(effect.get("name", "")) == "":
		effect["name"] = str(skill.get("name", skill.get("id", "")))
	_apply_or_refresh_effect(caster, effect)
	_log_event("%s uzywa %s." % [_unit_name_log_text(caster), str(skill.get("name", skill.get("id", "")))])


func _execute_focused_strike(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target)
	var result := _apply_attack_damage(caster, target, total_damage)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	_log_event(
		"%s trafia %s za %s obrazen i %s strat." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _get_area_cells(center: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	cells.append(center)
	cells.append_array(_get_neighbors(center))
	return cells


func _add_terrain_effect(cell: Vector2i, effect_id: String, turns: int, caster_id := -1, tick_damage := 0) -> void:
	for effect in terrain_effects:
		if int(effect.get("grid_x", -1)) == cell.x and int(effect.get("grid_y", -1)) == cell.y and str(effect.get("id", "")) == effect_id:
			effect["remaining_turns"] = turns
			effect["caster_id"] = caster_id
			effect["tick_damage"] = tick_damage
			return
	terrain_effects.append({
		"id": effect_id,
		"grid_x": cell.x,
		"grid_y": cell.y,
		"remaining_turns": turns,
		"caster_id": caster_id,
		"tick_damage": tick_damage
	})


func _get_terrain_effect_at(cell: Vector2i, effect_id: String) -> Dictionary:
	for effect in terrain_effects:
		if int(effect.get("grid_x", -1)) == cell.x and int(effect.get("grid_y", -1)) == cell.y and str(effect.get("id", "")) == effect_id:
			return effect
	return {}


func _apply_terrain_effects_to_unit(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	for effect in terrain_effects:
		if int(effect.get("grid_x", -1)) != int(unit.grid_x) or int(effect.get("grid_y", -1)) != int(unit.grid_y):
			continue
		match str(effect.get("id", "")):
			"ice":
				_apply_or_refresh_effect(unit, {
					"id": "lodowe_podloze",
					"name": "Lodowe Podloze",
					"category": "debuff",
					"remaining_turns": 1,
					"stat_changes": [
						{"stat": "speed", "mode": "flat", "value": -2},
						{"stat": "move_range", "mode": "flat", "value": -2}
					]
				})
				_log_event("%s slizga sie na lodzie." % _unit_name_log_text(unit))
			"poison_cloud":
				if _apply_poison_effect(unit, "zatrucie", "Zatrucie", 2, int(effect.get("tick_damage", 1))):
					_log_event("%s wdycha toksyczna chmure." % _unit_name_log_text(unit))
			"bear_trap":
				_trigger_bear_trap(unit, effect)
	_apply_terrain_entry_effect(unit)


func _trigger_bear_trap(unit: Dictionary, trap: Dictionary) -> void:
	var damage: int = _calculate_tick_damage(unit, int(trap.get("tick_damage", 1)))
	var casualties := _apply_damage_to_unit(unit, damage)
	_apply_or_refresh_effect(unit, {
		"id": "immobilize",
		"name": "Unieruchomienie",
		"category": "debuff",
		"remaining_turns": 1,
		"stat_changes": [
			{"stat": "move_range", "mode": "set", "value": 0}
		]
	})
	_apply_or_refresh_effect(unit, {
		"id": "krwawienie",
		"name": "Krwawienie",
		"category": "debuff",
		"remaining_turns": 2,
		"stat_changes": [],
		"tick_damage": max(1, int(trap.get("tick_damage", 1)))
	})
	terrain_effects.erase(trap)
	_log_event("%s wpada w Pulapke na Niedzwiedzie za %s obrazen i %s strat." % [_unit_name_log_text(unit), _color_log_text(str(damage), LOG_COLOR_DAMAGE), _color_log_text(str(casualties), LOG_COLOR_DAMAGE)])
	_cleanup_destroyed_unit(unit)


func _apply_terrain_entry_effect(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	if effect.is_empty():
		_remove_hiding_effects(unit)
		return
	_apply_or_refresh_effect(unit, effect)
	var terrain_name: String = str(effect.get("name", "teren"))
	if _terrain_hides_unit(cell):
		unit["is_hidden"] = true
		_log_event("%s wchodzi w %s i znika z pola widzenia." % [_unit_name_log_text(unit), terrain_name])
	else:
		unit["is_hidden"] = false
		_log_event("%s wchodzi w %s i traci reszte ruchu." % [_unit_name_log_text(unit), terrain_name])


func _remove_hiding_effects(unit: Dictionary) -> void:
	var effects: Array = unit.get("active_effects", [])
	var kept_effects: Array = []
	var removed := false
	for existing in effects:
		if bool(existing.get("hides_unit", false)):
			removed = true
			continue
		kept_effects.append(existing)
	if removed:
		unit["active_effects"] = kept_effects
		unit["is_hidden"] = false
		_recalculate_unit_stats(unit)


func _reveal_if_in_bush(unit: Dictionary) -> void:
	if not _terrain_hides_unit(Vector2i(int(unit.grid_x), int(unit.grid_y))):
		return
	if _has_effect(unit, "wykrycie"):
		return
	_apply_or_refresh_effect(unit, {
		"id": "wykrycie",
		"name": "Wykrycie",
		"category": "debuff",
		"remaining_turns": 2,
		"stat_changes": []
	})
	unit["is_revealed"] = true


func _apply_poison_effect(unit: Dictionary, id: String, name: String, turns: int, tick_damage: int, reduce_def := false) -> bool:
	if _is_poison_immune(unit):
		_log_event("%s ignoruje trucizne." % _unit_name_log_text(unit))
		return false
	var stat_changes: Array[Dictionary] = []
	if reduce_def:
		stat_changes.append({"stat": "def", "mode": "percent", "value": -15})
	_apply_or_refresh_effect(unit, {
		"id": id,
		"name": name,
		"category": "debuff",
		"remaining_turns": turns,
		"stat_changes": stat_changes,
		"tick_damage": tick_damage
	})
	return true


func _is_poison_immune(unit: Dictionary) -> bool:
	return _has_skill_id(unit, "mistrz_trucizn") or str(unit.get("resistance", "")).to_lower().contains("truciz")


func _try_apply_poison_master(attacker: Dictionary, target: Dictionary) -> void:
	if target.is_empty() or int(target.get("count", 0)) <= 0:
		return
	if not _has_skill_id(attacker, "mistrz_trucizn") or not _are_active_skills_on_cooldown(attacker):
		return
	if randi() % 2 != 0:
		return
	_apply_poison_effect(target, "zatrucie", "Zatrucie", 1, max(1, int(ceil(float(attacker.dmg) * 0.25))))


func _apply_terrain_effects_in_cells(cells: Array[Vector2i]) -> void:
	for unit in units:
		if cells.has(Vector2i(int(unit.grid_x), int(unit.grid_y))):
			_apply_terrain_effects_to_unit(unit)


func _advance_terrain_effects() -> void:
	var kept_effects: Array[Dictionary] = []
	for effect in terrain_effects:
		effect["remaining_turns"] = int(effect.get("remaining_turns", 0)) - 1
		if int(effect["remaining_turns"]) > 0:
			kept_effects.append(effect)
	terrain_effects = kept_effects


func _can_use_skill(unit: Dictionary, skill_id: String) -> bool:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return false
	if str(skill.get("target_type", "")) == "passive":
		return false
	if int(unit.get("action_points", 0)) < int(skill.get("ap_cost", 0)):
		return false
	return int(unit.get("skill_cooldowns", {}).get(skill_id, 0)) == 0


func _apply_or_refresh_effect(unit: Dictionary, effect_data: Dictionary) -> void:
	var metadata: Dictionary = UnitTypeLibrary.get_status_effect(str(effect_data.get("id", "")))
	if not metadata.is_empty():
		effect_data["name"] = str(metadata.get("name", effect_data.get("name", "")))
		var category: String = str(metadata.get("category", ""))
		if category != "":
			effect_data["category"] = category
	var effects: Array = unit.get("active_effects", [])
	var previous_move_range: int = int(unit.get("move_range", 0))
	for existing in effects:
		if str(existing.get("id", "")) != str(effect_data.get("id", "")):
			continue
		existing["remaining_turns"] = int(effect_data.get("remaining_turns", 0))
		existing["stat_changes"] = effect_data.get("stat_changes", [])
		if effect_data.has("tick_damage"):
			existing["tick_damage"] = int(effect_data.get("tick_damage", 0))
		if effect_data.has("forced_target_id"):
			existing["forced_target_id"] = int(effect_data.get("forced_target_id", -1))
		if effect_data.has("guarded_by_id"):
			existing["guarded_by_id"] = int(effect_data.get("guarded_by_id", -1))
		if effect_data.has("block_next_attack"):
			existing["block_next_attack"] = bool(effect_data.get("block_next_attack", false))
		_recalculate_unit_stats(unit)
		_add_current_move_gain(unit, previous_move_range)
		return
	effects.append(effect_data.duplicate(true))
	unit["active_effects"] = effects
	_recalculate_unit_stats(unit)
	_add_current_move_gain(unit, previous_move_range)


func _add_current_move_gain(unit: Dictionary, previous_move_range: int) -> void:
	var gained_move: int = int(unit.get("move_range", 0)) - previous_move_range
	if gained_move <= 0:
		return
	unit["remaining_move"] = int(unit.get("remaining_move", 0)) + gained_move


func _process_turn_start(unit: Dictionary) -> void:
	_advance_skill_cooldowns(unit)
	_ensure_energy_barrier(unit)
	var effects: Array = unit.get("active_effects", [])
	var skipped_turn := false
	for effect in effects:
		var tick_damage: int = int(effect.get("tick_damage", 0))
		if bool(effect.get("skip_turn", false)):
			skipped_turn = true
			unit["remaining_move"] = 0
			unit["action_points"] = 0
		if bool(effect.get("hides_unit", false)):
			if _terrain_hides_unit(Vector2i(int(unit.get("grid_x", 0)), int(unit.get("grid_y", 0)))):
				unit["is_hidden"] = true
			else:
				unit["is_hidden"] = false
		if tick_damage <= 0:
			continue
		var total_damage := _calculate_tick_damage(unit, tick_damage)
		if _consume_energy_barrier(unit):
			_log_event("Bariera Energetyczna blokuje obrazenia od %s na %s." % [str(effect.get("name", "efekt")), _unit_name_log_text(unit)])
			continue
		var casualties := _apply_damage_to_unit(unit, total_damage)
		_log_event(
			"%s cierpi przez %s, traci %s HP i %s jednostek." % [
				_unit_name_log_text(unit),
				str(effect.get("name", "efekt")),
				_color_log_text(str(total_damage), LOG_COLOR_DAMAGE),
				_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
			]
		)
		if int(unit.get("count", 0)) <= 0:
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
	var was_hidden := bool(unit.get("is_hidden", false))
	for effect in unit.get("active_effects", []):
		effect["remaining_turns"] = int(effect.get("remaining_turns", 0)) - 1
		if int(effect["remaining_turns"]) > 0:
			kept_effects.append(effect)
		elif bool(effect.get("hides_unit", false)):
			unit["is_hidden"] = false
		elif str(effect.get("id", "")) == "wykrycie":
			unit["is_revealed"] = false
	unit["active_effects"] = kept_effects
	if was_hidden and not bool(unit.get("is_hidden", false)):
		_log_event("%s wychodzi z ukrycia." % _unit_name_log_text(unit))
	_recalculate_unit_stats(unit)


func _recalculate_unit_stats(unit: Dictionary) -> void:
	unit["hp"] = int(unit.get("base_hp", unit.get("hp", 0)))
	unit["dmg"] = int(unit.get("base_dmg", unit.get("dmg", 0)))
	unit["def"] = int(unit.get("base_def", unit.get("def", 0)))
	unit["speed"] = int(unit.get("base_speed", unit.get("speed", 0)))
	unit["move_range"] = int(unit.get("base_move_range", unit.get("move_range", 0)))
	unit["attack_range"] = int(unit.get("base_attack_range", unit.get("attack_range", 1)))


	var buff_names: Array[String] = []
	var debuff_names: Array[String] = []
	for effect in unit.get("active_effects", []):
		for change in effect.get("stat_changes", []):
			_apply_stat_change(unit, change)
		if str(effect.get("category", "")) == "buff":
			buff_names.append(str(effect.get("name", "")))
		elif str(effect.get("category", "")) == "debuff":
			debuff_names.append(str(effect.get("name", "")))


	unit["dmg"] = max(1, int(unit.get("dmg", 1)))
	unit["def"] = max(0, int(unit.get("def", 0)))
	unit["speed"] = max(0, int(unit.get("speed", 0)))
	unit["move_range"] = max(0, int(unit.get("move_range", 0)))
	unit["attack_range"] = max(1, int(unit.get("attack_range", 1)))
	unit["buffs"] = "Brak" if buff_names.is_empty() else ", ".join(buff_names)
	unit["debuffs"] = "Brak" if debuff_names.is_empty() else ", ".join(debuff_names)
	_refresh_unit_health_state(unit)


func _refresh_unit_health_state(unit: Dictionary) -> void:
	var unit_hp: int = max(1, int(unit.get("base_hp", unit.get("max_hp", 1))))
	var total_hp: int = max(0, int(unit.get("current_total_hp", unit_hp * max(1, int(unit.get("count", 1))))))
	unit["max_hp"] = unit_hp
	unit["max_total_hp"] = max(unit_hp, int(unit.get("max_total_hp", unit_hp * max(1, int(unit.get("count", 1))))))
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
	var costs: Dictionary = {start: 0}
	var frontier: Array[Vector2i] = [start]

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_cost: int = costs[current]
		if current == goal:
			break

		for neighbor in _get_neighbors(current):
			if blocked.has(neighbor):
				continue
			var step_cost: int = _get_movement_cost(neighbor)
			var next_cost: int = current_cost + step_cost
			if costs.has(neighbor) and costs[neighbor] <= next_cost:
				continue
			costs[neighbor] = next_cost
			came_from[neighbor] = current
			frontier.append(neighbor)
		frontier.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return costs[a] < costs[b])

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


func _try_trigger_agility(moved_unit: Dictionary) -> void:
	for unit in units:
		if unit.side == moved_unit.side or not _has_skill_id(unit, "zwinnosc"):
			continue
		if not _can_see_target(unit, moved_unit):
			continue
		if int(unit.get("skill_cooldowns", {}).get("zwinnosc", 0)) > 0:
			continue
		if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), Vector2i(moved_unit.grid_x, moved_unit.grid_y)) != 1:
			continue
		var destination := _get_push_destination(moved_unit, unit)
		if destination == Vector2i(-1, -1):
			continue
		unit.grid_x = destination.x
		unit.grid_y = destination.y
		unit.skill_cooldowns["zwinnosc"] = 4
		board.snap_unit_to_cell(int(unit.id), destination)
		_log_event("%s odskakuje dzieki Zwinnosci." % _unit_name_log_text(unit))


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


func _ensure_energy_barrier(unit: Dictionary) -> void:
	if not _has_skill_id(unit, "bariera_energetyczna"):
		return
	if int(unit.get("skill_cooldowns", {}).get("bariera_energetyczna", 0)) > 0 or _has_effect(unit, "bariera_energetyczna"):
		return
	_apply_energy_barrier(unit)


func _apply_energy_barrier(unit: Dictionary) -> void:
	_apply_or_refresh_effect(unit, {
		"id": "bariera_energetyczna",
		"name": "Bariera Energetyczna",
		"category": "buff",
		"remaining_turns": 99,
		"stat_changes": [],
		"block_next_attack": true
	})


func _has_effect(unit: Dictionary, effect_id: String) -> bool:
	for effect in unit.get("active_effects", []):
		if str(effect.get("id", "")) == effect_id:
			return true
	return false


func _has_skill_id(unit: Dictionary, skill_id: String) -> bool:
	for id in unit.get("skill_ids", []):
		if str(id) == skill_id:
			return true
	return false


func _are_active_skills_on_cooldown(unit: Dictionary) -> bool:
	for skill_id in unit.get("skill_ids", []):
		var skill: Dictionary = skill_library.get(str(skill_id), {})
		if str(skill.get("target_type", "")) == "passive":
			continue
		if int(unit.get("skill_cooldowns", {}).get(str(skill_id), 0)) == 0:
			return false
	return true


func _generate_obstacles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var occupied: Dictionary = {}
	var obstacle_types_by_cell: Dictionary = {}
	for unit in units:
		occupied[Vector2i(unit.grid_x, unit.grid_y)] = true

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var cluster_count: int = rng.randi_range(4, 7)
	for cluster_index in range(cluster_count):
		var type: String = OBSTACLE_TYPES[rng.randi_range(0, OBSTACLE_TYPES.size() - 1)]
		var cluster_size: int = rng.randi_range(1, 3)
		if cluster_index < 2:
			cluster_size += 1
		var cluster: Array[Vector2i] = _generate_cluster(cluster_size, occupied, obstacle_types_by_cell, type, rng)
		for cell in cluster:
			occupied[cell] = true
			obstacle_types_by_cell[cell] = type
			result.append({
				"grid_x": cell.x,
				"grid_y": cell.y,
				"type": type,
				"variant": _pick_obstacle_variant(type, rng)
			})
	return result


func _pick_obstacle_variant(obstacle_type: String, rng: RandomNumberGenerator) -> String:
	if obstacle_type == "kamienie":
		if rng.randi_range(1, 100) == 1:
			return "rock2k"
		var rock_variants: Array[String] = ["rock1", "rock2", "rock3"]
		return rock_variants[rng.randi_range(0, rock_variants.size() - 1)]
	if obstacle_type == "krzok":
		return "krzok"
	if obstacle_type == "woda":
		return "water"
	return ""


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
	var x_min: int = SETUP_COLUMNS
	var x_max: int = GRID_COLUMNS - SETUP_COLUMNS - 1
	var attempts: int = 0
	while attempts < 100:
		attempts += 1
		var cell := Vector2i(rng.randi_range(x_min, x_max), rng.randi_range(0, GRID_ROWS - 1))
		if _can_place_obstacle_cell(cell, occupied, obstacle_types_by_cell, obstacle_type):
			return cell
	return Vector2i(-1, -1)


func _is_obstacle_column_allowed(column: int) -> bool:
	return column >= SETUP_COLUMNS and column < GRID_COLUMNS - SETUP_COLUMNS


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


func _get_terrain_at(cell: Vector2i) -> Dictionary:
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y:
			var type_id: String = str(obstacle.get("type", ""))
			if terrain_types.has(type_id):
				return terrain_types[type_id]
	return {}


func _is_cell_passable(cell: Vector2i) -> bool:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return true
	return not bool(terrain.get("blocks_movement", false))


func _get_movement_cost(cell: Vector2i) -> int:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return 1
	return int(terrain.get("movement_cost", 1))


func _get_path_cost(path: Array[Vector2i]) -> int:
	var cost: int = 0
	for cell in path:
		cost += _get_movement_cost(cell)
	return cost


func _get_executable_move_path(path: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in path:
		result.append(cell)
		if _terrain_skips_turn(cell) or not _get_terrain_effect_at(cell, "bear_trap").is_empty():
			break
	return result


func _get_terrain_entry_effect(cell: Vector2i) -> Dictionary:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return {}
	var effect: Variant = terrain.get("entry_effect", null)
	if effect == null or typeof(effect) != TYPE_DICTIONARY:
		return {}
	return effect.duplicate(true)


func _terrain_hides_unit(cell: Vector2i) -> bool:
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	return bool(effect.get("hides_unit", false))


func _terrain_skips_turn(cell: Vector2i) -> bool:
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	return bool(effect.get("skip_turn", false))


func _can_see_target(observer: Dictionary, target: Dictionary) -> bool:
	if bool(target.get("is_revealed", false)) or _has_effect(target, "wykrycie"):
		return true
	if not bool(target.get("is_hidden", false)):
		return true
	var observer_cell := Vector2i(observer.grid_x, observer.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	return _terrain_hides_unit(observer_cell) and _terrain_hides_unit(target_cell) and _hex_distance(observer_cell, target_cell) == 1


func _get_blocked_cells(excluded_unit_id: int) -> Dictionary:
	var blocked: Dictionary = {}
	for unit in units:
		if unit.id == excluded_unit_id:
			continue
		blocked[Vector2i(unit.grid_x, unit.grid_y)] = true
	for obstacle in obstacles:
		var cell := Vector2i(int(obstacle.grid_x), int(obstacle.grid_y))
		if not _is_cell_passable(cell):
			blocked[cell] = true
	return blocked


func _is_cell_obstacle(cell: Vector2i) -> bool:
	return not _get_terrain_at(cell).is_empty()


func _blocks_cell_skill_target(cell: Vector2i) -> bool:
	return _is_cell_obstacle(cell) and str(_get_terrain_at(cell).get("id", "")) != "krzok"


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


func _build_help_popup() -> void:
	help_popup = PanelContainer.new()
	help_popup.visible = false
	help_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	help_popup.custom_minimum_size = Vector2(420, 0)
	help_popup.set_anchors_preset(Control.PRESET_CENTER)
	help_popup.offset_left = -210
	help_popup.offset_top = -150
	help_popup.offset_right = 210
	help_popup.offset_bottom = 150
	hud.add_child(help_popup)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	help_popup.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var title := Label.new()
	title.text = "STEROWANIE"
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)

	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text = "\n".join([
		"LPM: wybierz jednostke, wskaz pole ruchu albo cel umiejetnosci.",
		"PPM: podstawowy atak wybrana aktywna jednostka.",
		"Tab: pokaz lub ukryj ta pomoc.",
		"START: rozpocznij bitwe po rozstawieniu.",
		"RESET: wroc do wyboru frakcji.",
		"Jednostki rozstawiasz w trzech skrajnych kolumnach swojej strony.",
		"Przeszkody blokuja ruch i linie strzalu."
	])
	column.add_child(body)

	var close_button := Button.new()
	close_button.text = "OK"
	close_button.pressed.connect(_on_tutorial_ok_pressed)
	column.add_child(close_button)


func _on_tutorial_ok_pressed() -> void:
	tutorial_acknowledged = true
	if help_popup != null:
		help_popup.visible = false
	_update_setup_hint_visibility()


func _toggle_help_popup() -> void:
	if help_popup == null or hud == null or not hud.visible:
		return
	help_popup.visible = not help_popup.visible


func _disable_hud_mouse(node: Node) -> void:
	if node is Control:
		if node is BaseButton or node is ScrollContainer:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in node.get_children():
		_disable_hud_mouse(child)


func _validate_setup() -> void:
	for unit in unit_configs:
		assert(unit.grid_x >= 0 and unit.grid_x < GRID_COLUMNS)
		assert(unit.grid_y >= 0 and unit.grid_y < GRID_ROWS)
		var type_data: Dictionary = UnitTypeLibraryScript.lookup(str(unit.get("type_id", "")))
		if not type_data.is_empty():
			assert(int(type_data.dmg) >= 1)
			assert(int(type_data.speed) >= 1)
			assert(int(type_data.action_points) >= 1)
			for skill_id in type_data.get("skill_ids", []):
				assert(skill_library.has(skill_id), "Brak skilla w bibliotece: %s" % skill_id)

	assert(_hex_distance(Vector2i(0, 3), Vector2i(0, 7)) == _hex_distance(Vector2i(0, 7), Vector2i(0, 3)))
	if current_player_faction != "testowa":
		assert(_is_setup_cell_allowed_for_side("player", Vector2i(SETUP_COLUMNS - 1, 0)))
		assert(not _is_setup_cell_allowed_for_side("player", Vector2i(SETUP_COLUMNS, 0)))
	if current_enemy_faction != "testowa":
		assert(_is_setup_cell_allowed_for_side("enemy", Vector2i(GRID_COLUMNS - SETUP_COLUMNS, 0)))
		assert(not _is_setup_cell_allowed_for_side("enemy", Vector2i(GRID_COLUMNS - SETUP_COLUMNS - 1, 0)))

	for unit in unit_configs:
		var cards: Array = _build_skill_cards(unit)
		var expected_skills: Array = unit.get("skill_ids", [])
		assert(cards.size() == expected_skills.size(), "Karty umiejetnosci nie pokrywaja sie ze skill_ids jednostki.")
		for card in cards:
			assert(str(card.get("name", "")) != "", "Karta umiejetnosci bez nazwy z biblioteki.")
			assert(int(card.get("remaining_cooldown", -1)) == 0, "Swiezo wczytana jednostka nie powinna miec aktywnego cooldownu.")
		var prepared: Dictionary = _prepare_unit(unit.duplicate(true))
		assert(int(prepared.get("base_action_points", 0)) == int(prepared.get("action_points", 0)), "AP z JSON musi byc startowym AP jednostki.")

	assert(_calculate_tick_damage({"count": 4}, 2) == 8, "Obrazenia z debuffa co ture musza skalowac sie liczba jednostek.")
	assert(not _can_use_skill({"action_points": 1, "skill_cooldowns": {}}, "bariera_energetyczna"), "Umiejetnosci bierne nie moga byc uzywane recznie.")
	var previous_units: Array = units.duplicate(true)
	var previous_obstacles: Array[Dictionary] = obstacles.duplicate(true)
	var previous_terrain_effects: Array[Dictionary] = terrain_effects.duplicate(true)
	obstacles = [
		{"grid_x": 4, "grid_y": 4, "type": "kamienie"},
		{"grid_x": 5, "grid_y": 3, "type": "krzok"},
		{"grid_x": 5, "grid_y": 4, "type": "krzok"},
		{"grid_x": 5, "grid_y": 5, "type": "krzok"}
	]
	assert(not _blocks_cell_skill_target(Vector2i(5, 4)), "Skill obszarowy musi moc celowac w krzak.")
	assert(_blocks_cell_skill_target(Vector2i(4, 4)), "Skill obszarowy nie powinien celowac w blokujace przeszkody.")
	var bush_unit := {
		"id": 999,
		"name": "Test",
		"side": "player",
		"grid_x": 5,
		"grid_y": 4,
		"hp": 10,
		"base_hp": 10,
		"dmg": 1,
		"base_dmg": 1,
		"def": 0,
		"base_def": 0,
		"speed": 1,
		"base_speed": 1,
		"move_range": 1,
		"base_move_range": 1,
		"attack_range": 1,
		"base_attack_range": 1,
		"count": 1,
		"current_total_hp": 10,
		"max_total_hp": 10,
		"active_effects": [],
		"skill_ids": []
	}
	terrain_effects = [{"id": "poison_cloud", "grid_x": 5, "grid_y": 4, "remaining_turns": 2, "tick_damage": 1}]
	_apply_terrain_effects_to_unit(bush_unit)
	assert(_has_effect(bush_unit, "zatrucie"), "Toksyczna chmura musi dzialac na jednostke stojaca w krzaku.")
	assert(not _can_see_target({"grid_x": 0, "grid_y": 0}, {"grid_x": 5, "grid_y": 5, "is_hidden": true}), "Ukryty cel w krzaku nie moze byc widoczny z normalnego pola.")
	assert(_can_see_target({"grid_x": 5, "grid_y": 4}, {"grid_x": 5, "grid_y": 5, "is_hidden": true}), "Jednostki w sasiadujacych krzakach musza sie widziec.")
	assert(not _can_see_target({"grid_x": 5, "grid_y": 3}, {"grid_x": 5, "grid_y": 5, "is_hidden": true}), "Krzak widzi ukryty cel tylko z sasiedniego krzaka.")
	assert(_can_see_target({"grid_x": 0, "grid_y": 0}, {"grid_x": 5, "grid_y": 5, "is_hidden": true, "is_revealed": true}), "Wykrycie musi pokazywac jednostke ukryta w krzaku.")
	bush_unit["active_effects"] = [{"id": "wykrycie", "name": "Wykrycie", "category": "debuff", "remaining_turns": 1, "stat_changes": []}]
	_reveal_if_in_bush(bush_unit)
	assert(int(bush_unit.active_effects[0].remaining_turns) == 1, "Wykrycie nie moze odnawiac czasu, dopoki trwa.")
	var ai_archer := {
		"id": 1001,
		"name": "AI Archer",
		"side": "enemy",
		"grid_x": 7,
		"grid_y": 5,
		"attack_range": 4,
		"action_points": 1,
		"remaining_move": 3
	}
	var ai_target := {
		"id": 1002,
		"name": "AI Target",
		"side": "player",
		"grid_x": 3,
		"grid_y": 5,
		"attack_range": 1,
		"action_points": 1,
		"remaining_move": 0
	}
	units = [ai_archer, ai_target]
	obstacles = []
	terrain_effects = []
	assert(_find_best_enemy_path(ai_archer, ai_target).is_empty(), "Dystansowy wróg nie powinien podchodzic, gdy ma czysty strzal.")
	ai_target["is_hidden"] = true
	assert(int(_find_nearest_player_unit(ai_archer).id) == int(ai_target.id), "AI musi miec cel do ruchu, nawet gdy wszyscy gracze sa ukryci.")
	assert(not _find_best_enemy_path(ai_archer, ai_target).is_empty(), "AI powinno isc w strone ukrytego gracza zamiast konczyc ture.")
	ai_target["is_hidden"] = false
	assert(_get_path_hazard_penalty(ai_archer, [Vector2i(6, 5)]) == 0, "Pusta sciezka AI nie powinna miec kary.")
	terrain_effects = [{"id": "fire", "grid_x": 6, "grid_y": 5, "remaining_turns": 1, "caster_side": "player"}]
	assert(_get_path_hazard_penalty(ai_archer, [Vector2i(6, 5)]) >= 200, "AI musi traktowac wrogie efekty terenu jako zagrozenie.")
	var water_start := Vector2i(4, 4)
	var first_water := Vector2i(5, 4)
	var second_water := Vector2i(6, 4)
	obstacles = [
		{"grid_x": first_water.x, "grid_y": first_water.y, "type": "woda"},
		{"grid_x": second_water.x, "grid_y": second_water.y, "type": "woda"}
	]
	units = [bush_unit]
	for neighbor in _get_neighbors(second_water):
		if neighbor != first_water and neighbor != water_start:
			obstacles.append({"grid_x": neighbor.x, "grid_y": neighbor.y, "type": "kamienie"})
	bush_unit.grid_x = water_start.x
	bush_unit.grid_y = water_start.y
	var water_path: Array[Vector2i] = _find_path(bush_unit, water_start, second_water)
	assert(water_path.size() == 2 and water_path[0] == first_water and water_path[1] == second_water, "Pathfinding moze prowadzic przez kolejne pola wody.")
	var executable_water_path: Array[Vector2i] = _get_executable_move_path(water_path)
	assert(executable_water_path.size() == 1 and executable_water_path[0] == first_water, "Ruch musi zatrzymac sie na pierwszym polu wody.")
	bush_unit.remaining_move = 1
	_apply_or_refresh_effect(bush_unit, {
		"id": "test_ruchu",
		"name": "Test Ruchu",
		"category": "buff",
		"remaining_turns": 1,
		"stat_changes": [
			{"stat": "move_range", "mode": "flat", "value": 2}
		]
	})
	assert(int(bush_unit.move_range) == 3 and _get_remaining_move(bush_unit) == 3, "Buff ruchu musi od razu dodac ruch do tej tury.")
	units = previous_units
	obstacles = previous_obstacles
	terrain_effects = previous_terrain_effects


func _on_board_animation_finished(_unit_id: int) -> void:
	is_animating = false
	_refresh_turn_queue()


func _update_action_buttons() -> void:
	var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
	if not selected_unit.is_empty():
		unit_abilities_panel.set_skills(_build_skill_cards(selected_unit))
	var active_unit: Dictionary = _get_active_unit()
	end_turn_button.disabled = setup_mode or is_animating or not _is_player_turn() or active_unit.is_empty() or active_unit.side != "player"
	_update_end_turn_button_text()
	_refresh_general_ability_buttons()


func _update_end_turn_button_text() -> void:
	end_turn_button.text = "ZAKOŃCZ TURĘ  (TURA %d)" % round_number


func _on_end_turn_button_pressed() -> void:
	if setup_mode or is_animating or not _is_player_turn():
		return
	var active_unit: Dictionary = _get_active_unit()
	if active_unit.is_empty() or active_unit.side != "player":
		return
	_end_current_activation()


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
	if event_log_scroll == null:
		return
	await get_tree().process_frame
	var scrollbar: VScrollBar = event_log_scroll.get_v_scroll_bar()
	if scrollbar == null:
		return
	event_log_scroll.scroll_vertical = int(scrollbar.max_value)


func _refresh_turn_queue() -> void:
	for child in turn_queue_list.get_children():
		child.queue_free()

	var visible_queue: Array[int] = _get_visible_turn_queue()
	for unit_id in visible_queue:
		var unit := _find_unit_by_id(unit_id)
		if unit.is_empty():
			continue
		turn_queue_list.add_child(_create_turn_queue_card(unit))

	_update_top_bar_width(visible_queue.size())


func _create_turn_queue_card(unit: Dictionary) -> Button:
	var is_selected: bool = int(unit.id) == selected_unit_id
	var is_active: bool = int(unit.id) == active_unit_id

	var button := Button.new()
	button.text = ""
	button.custom_minimum_size = TURN_QUEUE_CARD_SIZE
	button.clip_contents = true
	button.disabled = is_animating
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _make_turn_queue_card_style(unit, is_selected, false, is_active))
	button.add_theme_stylebox_override("hover", _make_turn_queue_card_style(unit, is_selected, true, is_active))
	button.add_theme_stylebox_override("pressed", _make_turn_queue_card_style(unit, true, true, is_active))
	button.add_theme_stylebox_override("disabled", _make_turn_queue_card_style(unit, is_selected, false, is_active))
	button.pressed.connect(_on_turn_queue_pressed.bind(unit.id))
	button.gui_input.connect(_on_turn_queue_gui_input.bind(unit.id))

	var border_color: Color = _get_turn_queue_border_color(unit, is_selected, is_active)
	var border_width: int = _get_turn_queue_border_width(is_selected, is_active)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 0)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)

	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size = TURN_QUEUE_PORTRAIT_SIZE
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_theme_stylebox_override("panel", _make_turn_queue_portrait_frame_style(unit))
	row.add_child(portrait_frame)

	var portrait := TextureRect.new()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var portrait_tex: Texture2D = _load_unit_portrait(unit)
	portrait.texture = portrait_tex if portrait_tex != null else TURN_QUEUE_PLACEHOLDER_PORTRAIT
	portrait_frame.add_child(portrait)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(border_width, 0)
	divider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	divider.color = border_color
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(divider)

	var text_wrap := MarginContainer.new()
	text_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_wrap.add_theme_constant_override("margin_left", 6)
	text_wrap.add_theme_constant_override("margin_right", 2)
	text_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_wrap)

	var name_label := Label.new()
	name_label.text = str(unit.name)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.max_lines_visible = 2
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", CARD_SELECTED_FONT_COLOR if is_selected else Color(0.95, 0.93, 0.88, 1.0))
	text_wrap.add_child(name_label)

	return button


func _update_top_bar_width(card_count: int) -> void:
	if top_bar == null or turn_queue_list == null:
		return
	if card_count <= 0:
		return
	var card_width := int(TURN_QUEUE_CARD_SIZE.x)
	var card_height := int(TURN_QUEUE_CARD_SIZE.y)
	var card_spacing := turn_queue_list.get_theme_constant("separation")
	var margin_left := 28
	var margin_right := 28
	var margin_vertical := 16
	var target_width: float = float(card_count * card_width + maxi(0, card_count - 1) * card_spacing + margin_left + margin_right)
	# ponytail: ograniczenie szerokosci bazuje na obecnym ukladzie paneli bocznych; przy redesignie HUD mozna policzyc je z rzeczywistych offsetow paneli.
	var max_width: float = maxf(280.0, get_viewport_rect().size.x - 2.0 * 364.0)
	var final_width: float = minf(target_width, max_width)
	top_bar.offset_left = -final_width * 0.5
	top_bar.offset_right = final_width * 0.5
	top_bar.offset_bottom = top_bar.offset_top + float(card_height + margin_vertical * 2)


func _on_turn_queue_pressed(unit_id: int) -> void:
	if is_animating:
		return

	var unit := _find_unit_by_id(unit_id)
	if unit.is_empty():
		return

	if unit.id == selected_unit_id:
		_clear_selected_unit()
		return

	pending_skill_id = ""
	_on_unit_selected(unit)


func _on_turn_queue_gui_input(_event: InputEvent, _unit_id: int) -> void:
	return


func _get_turn_queue_border_color(unit: Dictionary, selected: bool, active: bool) -> Color:
	var player_border := Color(0.35, 0.65, 0.95, 0.95)
	var enemy_border := Color(0.92, 0.35, 0.30, 0.95)
	var selected_border := Color(0.90, 0.77, 0.34, 1.0)
	if selected:
		return selected_border
	return player_border if unit.side == "player" else enemy_border


func _get_turn_queue_border_width(selected: bool, active: bool) -> int:
	return 1


func _make_turn_queue_card_style(unit: Dictionary, selected: bool, hovered := false, active := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var player_bg := Color(0.09, 0.16, 0.26, 0.96)
	var enemy_bg := Color(0.24, 0.10, 0.10, 0.96)
	var selected_bg := Color(0.23, 0.19, 0.08, 0.98)
	var active_player_bg := Color(0.12, 0.20, 0.32, 0.98)
	var active_enemy_bg := Color(0.30, 0.12, 0.12, 0.98)

	if selected:
		style.bg_color = selected_bg
	elif active:
		style.bg_color = active_player_bg if unit.side == "player" else active_enemy_bg
	else:
		style.bg_color = player_bg if unit.side == "player" else enemy_bg

	style.border_color = _get_turn_queue_border_color(unit, selected, active)
	if hovered and not selected:
		style.bg_color = style.bg_color.lightened(0.08)
		style.border_color = style.border_color.lightened(0.08)

	var border_width: int = _get_turn_queue_border_width(selected, active)
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_size = 0
	style.shadow_offset = Vector2.ZERO
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	style.content_margin_left = 8.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	return style


func _make_turn_queue_portrait_frame_style(unit: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var player_tint := Color(0.06, 0.10, 0.16, 0.92)
	var enemy_tint := Color(0.16, 0.06, 0.06, 0.92)
	style.bg_color = player_tint if unit.side == "player" else enemy_tint
	style.border_color = Color(0.0, 0.0, 0.0, 0.35)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = 2.0
	style.content_margin_top = 2.0
	style.content_margin_right = 2.0
	style.content_margin_bottom = 2.0
	return style


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
		"cell":
			return "Hex"
		"passive":
			return "Pasywna"
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
		_update_selection_visibility()
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
			_update_end_turn_button_text()
			_advance_terrain_effects()
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
	unit.action_points = int(unit.get("base_action_points", unit.get("action_points", 1)))
	pending_skill_id = ""
	_process_turn_start(unit)
	if unit.side == "player":
		_refresh_general_ability_buttons()
	_apply_terrain_effects_to_unit(unit)
	if _find_unit_by_id(unit.id).is_empty():
		_sync_board()
		_start_next_activation()
		return
	if unit.side != "player" and not _can_unit_continue_turn(unit):
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
	var move_range: int = int(unit.get("move_range", 0))
	if move_range <= 0:
		return 0
	return min(int(unit.get("remaining_move", move_range)), move_range)


func _get_display_move(unit: Dictionary) -> int:
	var move_range: int = int(unit.get("move_range", 0))
	return _get_remaining_move(unit) if unit.id == active_unit_id else move_range


func _get_display_action_points(unit: Dictionary) -> int:
	return int(unit.get("action_points", 0)) if unit.id == active_unit_id else int(unit.get("base_action_points", unit.get("action_points", 1)))


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


func _on_skill_button_pressed(index: int) -> void:
	if not _is_player_turn() or is_animating:
		return

	var unit := _get_active_unit()
	var skill := _get_skill_at(unit, index)
	if skill.is_empty():
		return

	var skill_id := str(skill.get("id", ""))
	if pending_skill_id == skill_id:
		pending_skill_id = ""
	elif not _can_use_skill(unit, skill_id):
		return
	else:
		pending_skill_id = skill_id

	selected_unit_id = unit.id
	_update_highlighted_cells(unit)
	_update_action_buttons()
	unit_abilities_panel.set_skills(_build_skill_cards(unit))
	_refresh_turn_queue()


func _on_general_ability_1_pressed() -> void:
	_use_general_skill_by_index(0)


func _on_general_ability_2_pressed() -> void:
	_use_general_skill_by_index(1)


func _use_general_skill_by_index(index: int) -> void:
	if setup_mode or is_animating or not _is_player_turn():
		return
	if index < 0 or index >= general_skill_ids.size():
		return
	var skill_id: String = general_skill_ids[index]
	var skill: Dictionary = general_skills.get(skill_id, {})
	if skill.is_empty():
		return
	if general_skill_used:
		return
	var effect: Dictionary = skill.get("effect", {})
	if effect.is_empty():
		return
	for unit in units:
		if unit.side != "player":
			continue
		_apply_or_refresh_effect(unit, effect.duplicate(true))
	general_skill_used = true
	_log_event("%s uzywa %s." % [general_name_label.text, str(skill.get("name", skill_id))])
	_refresh_general_ability_buttons()
	_sync_board()


func _refresh_general_ability_buttons() -> void:
	var buttons: Array[Button] = [general_ability_button_1, general_ability_button_2]
	for index in buttons.size():
		var button: Button = buttons[index]
		var name_label: Label = button.get_node("AbilityContent/AbilityText/AbilityName")
		var desc_label: Label = button.get_node("AbilityContent/AbilityText/AbilityDesc")
		var cd_label: Label = button.get_node("AbilityContent/AbilityText/AbilityCooldown")
		if index >= general_skill_ids.size():
			button.disabled = true
			name_label.text = "-"
			desc_label.text = "Brak umiejetnosci"
			cd_label.text = ""
			continue
		var skill_id: String = general_skill_ids[index]
		var skill: Dictionary = general_skills.get(skill_id, {})
		var can_use := not setup_mode and not is_animating and _is_player_turn() and not general_skill_used
		button.disabled = not can_use
		button.modulate = Color(0.45, 0.45, 0.45, 0.75) if general_skill_used else Color.WHITE
		name_label.text = str(skill.get("name", skill_id)).to_upper()
		desc_label.text = str(skill.get("description", ""))
		cd_label.text = ""
