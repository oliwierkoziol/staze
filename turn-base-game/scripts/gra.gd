extends Control

const BATTLE_CONFIG_PATH := "res://data/battle_config.json"
const TERRAIN_TYPES_PATH := "res://data/terrain_types.json"
const DEFAULT_BATTLE_BACKGROUND_PATH := "res://assets/backgrounds/back.png"
const GRID_COLUMNS := 15
const GRID_ROWS := 10
const SETUP_COLUMNS := 3
const OBSTACLE_TYPES: Array[String] = ["woda", "kamienie", "krzok"]
const FOREST_OBSTACLE_TYPES: Array[String] = ["holy_tree", "elf_statue"]
const MINE_OBSTACLE_TYPES: Array[String] = ["cart", "detonator", "hole"]
const WINTER_OBSTACLE_TYPES: Array[String] = ["woda", "kamienie", "zimowy_krzak"]
const DESERT_OBSTACLE_TYPES: Array[String] = ["ruchome_piaski", "kamienie"]
const MAX_EVENT_LOG_ENTRIES := 60
const KRWAWIENIE_TICK_DAMAGE := 2
const PLONIECIE_TICK_DAMAGE := 2
const PLONIECIE_TURNS := 3
const MAX_VISIBLE_QUEUE_CARDS := 8
const SINGLE_CLICK_DELAY := 0.3
const MAX_EVENT_OBSTACLES: Dictionary = {"woda": 6, "kamienie": 4, "krzok": 6, "ruchome_piaski": 6, "holy_tree": 5, "cart": 3, "elf_statue": 6, "hole": 4, "detonator": 2}
const TURN_QUEUE_PLACEHOLDER_PORTRAIT: Texture2D = preload("res://assets/ui/unit1.png")
const MAP_EVENT_POOLS: Dictionary = {
	"orcs_vs_elves_forest": ["gniew_korzeni", "przebudzenie_gaju", "lesne_opary", "magiczny_rozkwit"],
	"dwarves_vs_goblins_mine": ["spadajacy_rumosz", "wybuch_gazu", "pekniecie_chodnika", "zawal_kopalni"],
	"humans_vs_orcs_village": ["rozprzestrzeniajacy_sie_pozar", "gesty_dym", "przerwanie_grobli", "plonace_zabudowania"],
	"elves_vs_dwarves_pass": ["wichura_lodowa", "sniezna_zamiec", "oblodzenie", "lawina"],
	"humans_vs_goblins_desert": ["burza_piaskowa", "zapadlisko", "palacy_skwar", "pustynny_podmuch"],
}
const MAP_EVENT_DATA: Dictionary = {
	"gniew_korzeni": {"name": "Gniew Korzeni", "icon": preload("res://assets/ui/root.png"), "description": "Oznacza 3 pola. Jednostki stojace na nich otrzymuja zasieg ruchu 0 przez 1 ture."},
	"przebudzenie_gaju": {"name": "Przebudzenie Gaju", "icon": preload("res://assets/mapTiles/bush.png"), "description": "Tworzy 3 nowe krzaki na oznaczonych polach."},
	"lesne_opary": {"name": "Lesne Opary", "icon": preload("res://assets/ui/reveal.png"), "description": "Zmniejsza zasieg ataku wszystkich jednostek o 1 przez 1 ture."},
	"magiczny_rozkwit": {"name": "Magiczny Rozkwit", "icon": preload("res://assets/ui/aura.png"), "description": "Oznacza 3 pola. Kazdy stojacy na nich oddzial odzyskuje HP rowne bazowemu HP jednej jednostki, nie przekraczajac maksimum."},
	"spadajacy_rumosz": {"name": "Spadajacy Rumosz", "icon": preload("res://assets/mapTiles/rock1.png"), "description": "Oznacza 3 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"wybuch_gazu": {"name": "Wybuch Gazu", "icon": preload("res://assets/ui/poison_cloud.png"), "description": "Tworzy toksyczna chmure na 5-8 polach na 2 rundy. Zatrucie zadaje 1 obrazenie za kazda zywa jednostke w oddziale przez 2 tury."},
	"pekniecie_chodnika": {"name": "Pekniecie Chodnika", "icon": preload("res://assets/ui/water.png"), "description": "Tworzy 3 pola wody. Wejscie zuzywa caly pozostaly ruch jednostki."},
	"zawal_kopalni": {"name": "Zawal Kopalni", "icon": preload("res://assets/mapTiles/rock2.png"), "description": "Tworzy kamienie na 2 polach. Jednostka na oznaczonym polu otrzymuje 1 obrazenie za kazdego zywego czlonka oddzialu; kamienie powstaja, jesli pole zostanie zwolnione."},
	"rozprzestrzeniajacy_sie_pozar": {"name": "Rozprzestrzeniajacy sie Pozar", "icon": preload("res://assets/ui/fire.png"), "description": "Tworzy ogien na 5-8 polach na 2 rundy. Ploniecie zadaje 2 obrazenia za kazda zywa jednostke w oddziale przez 3 tury."},
	"gesty_dym": {"name": "Gesty Dym", "icon": preload("res://assets/ui/reveal.png"), "description": "Zmniejsza zasieg ataku wszystkich jednostek o 1 przez 1 ture."},
	"przerwanie_grobli": {"name": "Przerwanie Grobli", "icon": preload("res://assets/ui/water.png"), "description": "Tworzy 3 pola wody. Wejscie zuzywa caly pozostaly ruch jednostki."},
	"plonace_zabudowania": {"name": "Plonace Zabudowania", "icon": preload("res://assets/ui/fire.png"), "description": "Oznacza 3 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"wichura_lodowa": {"name": "Wichura Lodowa", "icon": preload("res://assets/ui/frost.png"), "description": "Zmniejsza Szybkosc i zasieg ruchu wszystkich jednostek o 2 przez 1 ture."},
	"sniezna_zamiec": {"name": "Sniezna Zamiec", "icon": preload("res://assets/ui/frost.png"), "description": "Zmniejsza zasieg ataku wszystkich jednostek o 1 przez 1 ture."},
	"oblodzenie": {"name": "Oblodzenie", "icon": preload("res://assets/ui/frost.png"), "description": "Tworzy lod na 5-8 polach na 2 rundy. Lodowe Podloze zmniejsza Szybkosc i zasieg ruchu o 2 przez 1 ture."},
	"lawina": {"name": "Lawina", "icon": preload("res://assets/mapTiles/rock3.png"), "description": "Oznacza 4 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"burza_piaskowa": {"name": "Burza Piaskowa", "icon": preload("res://assets/ui/reveal.png"), "description": "Zmniejsza zasieg ataku wszystkich jednostek o 1 przez 1 ture."},
	"zapadlisko": {"name": "Zapadlisko", "icon": preload("res://assets/ui/exhaust.png"), "description": "Tworzy 3 pola ruchomych piaskow. Wejscie zuzywa caly pozostaly ruch jednostki."},
	"palacy_skwar": {"name": "Palacy Skwar", "icon": preload("res://assets/ui/fire.png"), "description": "Oznacza 3 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"pustynny_podmuch": {"name": "Pustynny Podmuch", "icon": preload("res://assets/ui/speed.png"), "description": "Zmniejsza Szybkosc i zasieg ruchu wszystkich jednostek o 2 przez 1 ture."},
}
const DEFAULT_GENERAL_PORTRAIT: Texture2D = preload("res://assets/ui/general1.png")
const GENERAL_PORTRAITS: Dictionary = {
	"elves": preload("res://assets/ui/general_elf_1.png"),
	"orcs": preload("res://assets/ui/general_orc_1.png"),
	"dwarves": preload("res://assets/ui/general_dwarf_1.png"),
	"goblins": preload("res://assets/ui/general_goblin_1.png"),
	"humans": preload("res://assets/ui/general_human_1.png"),
}
const GENERAL_NAMES: Dictionary = {
	"elves": "Władca Sylvar",
	"orcs": "Wódz Grak'thar",
	"dwarves": "Wojewoda Bronwyn",
	"goblins": "Król Skrawek",
	"humans": "Kapitan Alaric",
}
const ORC_GENERAL_KISHAK_NAME := "Wódz Kish'ak"
const ORC_GENERAL_KISHAK_PORTRAIT: Texture2D = preload("res://assets/ui/general_kishak.png")
const LOG_COLOR_YELLOW := Color(0.95, 0.82, 0.25, 1.0)
const LOG_COLOR_PLAYER := Color(0.35, 0.65, 0.95, 1.0)
const LOG_COLOR_ENEMY := Color(0.92, 0.35, 0.30, 1.0)
const LOG_COLOR_DAMAGE := Color(0.92, 0.35, 0.30, 1.0)
const TEAM_SETUP_SCENE: PackedScene = preload("res://scenes/team_setup.tscn")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const BattleSetupPositionsScript = preload("res://scripts/battle_setup_positions.gd")
const TurnQueueCardScript = preload("res://scripts/turn_queue_card.gd")
const HexUtilsScript = preload("res://scripts/hex_utils.gd")
const ObstacleGeneratorScript = preload("res://scripts/obstacle_generator.gd")
const UnitDetailsPopupScript = preload("res://scripts/unit_details_popup.gd")

var OBSTACLE_PORTRAITS: Dictionary = {
	"woda": preload("res://assets/mapTiles/water.png"),
	"kamienie": preload("res://assets/mapTiles/rock1.png"),
	"krzok": load("res://assets/mapTiles/bush.png"),
	"zimowy_krzak": load("res://assets/mapTiles/zimowykszok.png"),
	"ruchome_piaski": load("res://assets/mapTiles/quicksand.png"),
	"wydmy": load("res://assets/mapTiles/dune.png"),
	"holy_tree": load("res://assets/holy_tree.png"),
	"cart": load("res://assets/cart.png"),
	"elf_statue": load("res://assets/elfStatue.png"),
	"hole": load("res://assets/hole.png"),
	"detonator": load("res://assets/detonator.png"),
}
const OBSTACLE_NAMES: Dictionary = {
	"woda": "Woda",
	"kamienie": "Kamienie",
	"krzok": "Krzak",
	"zimowy_krzak": "Zimowy Krzak",
	"ruchome_piaski": "Ruchome Piaski",
	"wydmy": "Wydmy",
	"holy_tree": "Swiete Drzewo",
	"cart": "Woz",
	"elf_statue": "Posag Elfow",
	"hole": "Dziura",
	"detonator": "Detonator",
}
const OBSTACLE_DESCRIPTIONS: Dictionary = {
	"woda": "Wejscie do wody zuzywa caly pozostaly ruch w tej turze.",
	"kamienie": "Przez kamienie nie da sie przejsc. Blokuja linie strzalu.",
	"krzok": "Jednostka w krzaku jest ukryta. Wróg może ją zobaczyć z sąsiedniego pola zapewniającego ukrycie. Atak lub otrzymanie obrażeń nakłada Wykrycie na 2 tury.",
	"zimowy_krzak": "Jednostka w zimowym krzaku jest ukryta. Wróg może ją zobaczyć z sąsiedniego pola zapewniającego ukrycie. Atak lub otrzymanie obrażeń nakłada Wykrycie na 2 tury.",
	"ruchome_piaski": "Wejscie w ruchome piaski zuzywa caly pozostaly ruch w tej turze.",
	"wydmy": "Strome wydmy blokuja ruch i linie strzalu.",
	"holy_tree": "Jednostka w Świętym Drzewie jest ukryta. Wróg może ją zobaczyć z sąsiedniego pola zapewniającego ukrycie. Atak lub otrzymanie obrażeń nakłada Wykrycie na 2 tury.",
	"cart": "Jednostka na polu wozu jest ukryta. Wróg może ją zobaczyć z sąsiedniego pola zapewniającego ukrycie. Atak lub otrzymanie obrażeń nakłada Wykrycie na 2 tury.",
	"elf_statue": "Posag blokuje ruch i linie strzalu. Sasiadujaca jednostka otrzymuje +2 do obrazen.",
	"hole": "Jednostka ktora wpadnie do dziury ginie natychmiast.",
	"detonator": "Jednorazowy detonator. Aktywowany z sasiedniego hexa. Przywoluje spadajace kamienie na cztery losowe hexy.",
}
const OBSTACLE_WINTER_DESCRIPTIONS: Dictionary = {
	"woda": "Lod jest kruchy. Wejscie zuzywa caly ruch i ma 10%% szans na zapadniecie sie zabijajace jednostke.",
	"kamienie": "Oblodzone skaly blokuja ruch i linie strzalu.",
	"zimowy_krzak": "Jednostka w zimowym krzaku jest ukryta. Wróg może ją zobaczyć z sąsiedniego pola zapewniającego ukrycie. Atak lub otrzymanie obrażeń nakłada Wykrycie na 2 tury.",
}

@onready var board: Node2D = $BattleLayer/PlanszaWalki
@onready var battle_background: TextureRect = $Background
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
@onready var general_portrait: TextureRect = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralHeader/GeneralPortrait
@onready var general_name_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralHeader/GeneralHeaderText/GeneralName
@onready var general_level_label: Label = $HUD/Overlay/RightPanel/RightMargin/RightContent/GeneralPanel/GeneralPanelMargin/GeneralPanelContent/GeneralHeader/GeneralHeaderText/GeneralLevel
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
var active_turn_has_log := false
var event_log: Array[String] = []
var round_number := 1
var next_map_event_round := 0
var next_map_event_id := ""
var map_event_cells: Array[Vector2i] = []
var turn_queue: Array[int] = []
var turn_queue_index := -1
var pending_skill_id := ""
var unit_configs: Array[Dictionary] = []
var skill_library: Dictionary = {}
var general_skills: Dictionary = {}
var general_skill_ids: Array[String] = []
var general_skill_used := false
var orc_general_is_kishak := false
var terrain_effects: Array[Dictionary] = []
var setup_mode := true
var setup_drag_unit_id := -1
var last_battle_config_source := ""
var setup_controls: HBoxContainer
var save_setup_button: Button
var reset_battle_button: Button
var reload_json_button: Button
var save_setup_dialog: FileDialog
var current_player_faction := ""
var current_enemy_faction := ""
var current_battle_background_path: String = DEFAULT_BATTLE_BACKGROUND_PATH
var free_setup_mode := false
var help_popup: PanelContainer
var help_popup_content: VBoxContainer
var help_popup_scroll: ScrollContainer
var help_popup_page_label: Label
var help_popup_prev_button: Button
var help_popup_next_button: Button
var help_popup_action_button: Button
var help_mode_tutorial := true
var tutorial_page := 0
var victory_overlay: Control
var victory_title_label: Label
var tutorial_acknowledged := false
var displayed_path_cost := -1
var selected_obstacle_cell := Vector2i(-1, -1)
var screen_message_label: Label
var screen_message_tween: Tween
var detonator_activated := false
var unit_details_popup: PopupPanel
var cell_click_revision := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disable_hud_mouse(hud)
	_build_help_popup()
	_build_victory_overlay()
	_build_screen_message_label()
	unit_details_popup = UnitDetailsPopupScript.new()
	add_child(unit_details_popup)
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
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.keycode == KEY_TAB:
		_toggle_help_popup()
		get_viewport().set_input_as_handled()
		return

	if hud == null or not hud.visible:
		return

	if save_setup_dialog != null and save_setup_dialog.visible:
		return

	if event.keycode == KEY_ESCAPE:
		_on_reset_battle_pressed()
		get_viewport().set_input_as_handled()
		return

	if event.keycode == KEY_SPACE:
		if help_popup != null and help_popup.visible:
			if help_mode_tutorial:
				_on_tutorial_ok_pressed()
			get_viewport().set_input_as_handled()
			return
		if setup_mode:
			if not tutorial_acknowledged or is_animating:
				return
			_on_start_battle_pressed()
		else:
			_on_end_turn_button_pressed()
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
	setup.setup_loaded.connect(_on_team_setup_loaded)
	setup.custom_setup_finished.connect(_on_custom_setup_finished)
	add_child(setup)
	if hud != null:
		hud.visible = false
	if board != null:
		board.visible = false


func _on_team_setup_finished(player_faction: String, enemy_faction: String) -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	current_player_faction = player_faction
	current_enemy_faction = enemy_faction
	free_setup_mode = false
	_set_battle_background(DEFAULT_BATTLE_BACKGROUND_PATH)
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
	_roll_orc_general_variant()
	_setup_battle_scene()


func _on_team_setup_loaded(save_data: Dictionary) -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	current_player_faction = str(save_data.get("player_faction", ""))
	current_enemy_faction = str(save_data.get("enemy_faction", ""))
	orc_general_is_kishak = bool(save_data.get("orc_general_is_kishak", false))
	free_setup_mode = bool(save_data.get("free_setup_mode", false))
	_set_battle_background(str(save_data.get("background_path", DEFAULT_BATTLE_BACKGROUND_PATH)))
	skill_library = UnitTypeLibraryScript.get_skill_library()
	_load_general_skills()
	var setup: Control = get_node_or_null("TeamSetup")
	if setup != null:
		setup.queue_free()
	if hud != null:
		hud.visible = true
	if board != null:
		board.visible = true
	_setup_battle_scene()
	_apply_save_data(save_data)


func _on_custom_setup_finished(custom_units: Array[Dictionary], player_faction: String, enemy_faction: String, background_path: String) -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	current_player_faction = player_faction
	current_enemy_faction = enemy_faction
	free_setup_mode = player_faction == "testowa" and enemy_faction == "testowa"
	_set_battle_background(background_path if background_path != "" else DEFAULT_BATTLE_BACKGROUND_PATH)
	skill_library = UnitTypeLibraryScript.get_skill_library()
	_load_general_skills()
	var setup: Control = get_node_or_null("TeamSetup")
	if setup != null:
		setup.queue_free()
	if hud != null:
		hud.visible = true
	if board != null:
		board.visible = true
	_build_test_battle_config(custom_units)
	_roll_orc_general_variant()
	_setup_battle_scene()


func _roll_orc_general_variant() -> void:
	orc_general_is_kishak = current_player_faction == "orcs" and randi_range(1, 10) == 1


func _load_general_skills() -> void:
	general_skills = UnitTypeLibraryScript.get_general_skills()
	general_skill_ids = []
	for skill_id in general_skills.keys():
		general_skill_ids.append(str(skill_id))
	general_skill_used = false


func _set_battle_background(path: String) -> void:
	current_battle_background_path = path if path != "" else DEFAULT_BATTLE_BACKGROUND_PATH
	var texture: Resource = load(current_battle_background_path)
	if texture is Texture2D:
		battle_background.texture = texture


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


func _build_test_battle_config(custom_units: Array[Dictionary]) -> void:
	var player_count := 0
	var enemy_count := 0
	for unit in custom_units:
		if str(unit.get("side", "")) == "player":
			player_count += 1
		elif str(unit.get("side", "")) == "enemy":
			enemy_count += 1
	var player_positions := _compute_player_positions(player_count)
	var enemy_positions := _compute_enemy_positions(enemy_count)
	var player_index := 0
	var enemy_index := 0
	unit_configs.clear()
	for unit in custom_units:
		var side := str(unit.get("side", ""))
		var pos := Vector2i.ZERO
		if side == "player":
			pos = player_positions[player_index]
			player_index += 1
		elif side == "enemy":
			pos = enemy_positions[enemy_index]
			enemy_index += 1
		else:
			continue
		unit_configs.append({
			"id": int(unit.get("id", unit_configs.size() + 1)),
			"type_id": str(unit.get("type_id", "")),
			"side": side,
			"count": int(unit.get("count", 1)),
			"grid_x": pos.x,
			"grid_y": pos.y,
		})


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
	return BattleSetupPositionsScript.player(count, GRID_COLUMNS, GRID_ROWS)


func _compute_enemy_positions(count: int) -> Array[Vector2i]:
	return BattleSetupPositionsScript.enemy(count, GRID_COLUMNS, GRID_ROWS)


func _setup_battle_scene() -> void:
	_build_setup_controls()
	_connect_signal_once(board.cell_clicked, _on_cell_clicked)
	_connect_signal_once(board.cell_double_clicked, _on_cell_double_clicked)
	_connect_signal_once(board.cell_left_released, _on_cell_left_released)
	_connect_signal_once(board.cell_right_clicked, _on_cell_right_clicked)
	_connect_signal_once(board.cell_hovered, _on_board_cell_hovered)
	_connect_signal_once(board.animation_finished, _on_board_animation_finished)
	_connect_signal_once(unit_abilities_panel.skill_pressed, _on_skill_button_pressed)
	_connect_signal_once(end_turn_button.pressed, _on_end_turn_button_pressed)
	_connect_signal_once(general_ability_button_1.pressed, _on_general_ability_1_pressed)
	_connect_signal_once(general_ability_button_2.pressed, _on_general_ability_2_pressed)
	_refresh_general_display()
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

	save_setup_button = _make_setup_button("ZAPISZ")
	save_setup_button.pressed.connect(_on_save_setup_pressed)
	setup_controls.add_child(save_setup_button)

	reset_battle_button = _make_setup_button("RESET")
	reset_battle_button.pressed.connect(_on_reset_battle_pressed)
	setup_controls.add_child(reset_battle_button)

	reload_json_button = _make_setup_button("RELOAD JSON")
	reload_json_button.pressed.connect(_on_reload_json_pressed)
	setup_controls.add_child(reload_json_button)

	save_setup_dialog = FileDialog.new()
	save_setup_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_setup_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_setup_dialog.filters = PackedStringArray(["*.json ; Zapis armii"])
	save_setup_dialog.file_selected.connect(_on_save_setup_file_selected)
	add_child(save_setup_dialog)


func _connect_signal_once(source_signal: Signal, callback: Callable) -> void:
	if not source_signal.is_connected(callback):
		source_signal.connect(callback)


func _make_setup_button(text: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 36)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	return button


func _should_skip_tutorial() -> bool:
	return free_setup_mode


func _enter_setup_mode() -> void:
	setup_mode = true
	help_mode_tutorial = true
	tutorial_page = 0
	tutorial_acknowledged = _should_skip_tutorial()
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
	next_map_event_id = ""
	map_event_cells.clear()
	detonator_activated = false
	board.set_detonator_warning_cells([])
	board.clear_falling_rock_cells()
	_schedule_next_map_event(0)
	turn_queue_index = -1
	event_log.clear()
	board.set_selected_unit(-1)
	board.set_hovered_move_path([])
	board.set_units(units)
	board.reset_unit_positions(units)
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	selected_obstacle_cell = Vector2i(-1, -1)
	_log_event(_color_log_text("Tryb przygotowania: ustaw jednostki i kliknij START po prawej.", LOG_COLOR_YELLOW))
	_update_action_buttons()
	_sync_board()
	if help_popup != null and hud.visible and not _should_skip_tutorial():
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
	detonator_activated = false
	board.set_detonator_warning_cells([])
	board.clear_falling_rock_cells()
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	_log_event(_color_log_text("Bitwa rozpoczeta.", LOG_COLOR_YELLOW))
	_rebuild_turn_queue()
	_start_next_activation()


func _on_save_setup_pressed() -> void:
	save_setup_dialog.current_file = "zapis_armii.json"
	save_setup_dialog.popup_centered(Vector2i(900, 600))


func _on_save_setup_file_selected(path: String) -> void:
	var save_path := path if path.get_extension().to_lower() == "json" else "%s.json" % path
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		_log_event(_color_log_text("Nie udalo sie zapisac ustawienia armii.", LOG_COLOR_DAMAGE), false)
		return
	file.store_string(JSON.stringify(_make_save_data(), "\t"))
	_log_event(_color_log_text("Zapisano stan gry.", LOG_COLOR_YELLOW), false)


func _make_save_data() -> Dictionary:
	return {
		"player_faction": current_player_faction,
		"enemy_faction": current_enemy_faction,
		"background_path": current_battle_background_path,
		"free_setup_mode": free_setup_mode,
		"setup_mode": setup_mode,
		"units": units.duplicate(true),
		"obstacles": obstacles.duplicate(true),
		"terrain_effects": terrain_effects.duplicate(true),
		"selected_unit_id": selected_unit_id,
		"active_unit_id": active_unit_id,
		"current_turn": current_turn,
		"active_turn_has_log": active_turn_has_log,
		"event_log": event_log.duplicate(),
		"round_number": round_number,
		"next_map_event_round": next_map_event_round,
		"next_map_event_id": next_map_event_id,
		"map_event_cells": map_event_cells.map(func(cell: Vector2i) -> Dictionary: return {"grid_x": cell.x, "grid_y": cell.y}),
		"turn_queue": turn_queue.duplicate(),
		"turn_queue_index": turn_queue_index,
		"pending_skill_id": pending_skill_id,
		"general_skill_used": general_skill_used,
		"orc_general_is_kishak": orc_general_is_kishak,
		"detonator_activated": detonator_activated,
	}


func _apply_save_data(save_data: Dictionary) -> void:
	setup_mode = bool(save_data.get("setup_mode", true))
	_update_setup_hint_visibility()
	units = []
	var saved_units: Variant = save_data.get("units", [])
	if typeof(saved_units) != TYPE_ARRAY:
		saved_units = []
	for raw_unit in saved_units:
		if typeof(raw_unit) == TYPE_DICTIONARY:
			var unit: Dictionary = raw_unit.duplicate(true)
			unit["id"] = int(unit.get("id", 0))
			unit["grid_x"] = int(unit.get("grid_x", 0))
			unit["grid_y"] = int(unit.get("grid_y", 0))
			units.append(unit if unit.has("max_hp") else _prepare_unit(unit))
	unit_configs = []
	for unit in units:
		unit_configs.append({
			"id": int(unit.get("id", 0)),
			"type_id": str(unit.get("type_id", "")),
			"side": str(unit.get("side", "")),
			"grid_x": int(unit.get("grid_x", 0)),
			"grid_y": int(unit.get("grid_y", 0)),
		})
	obstacles = _typed_dictionary_array(save_data.get("obstacles", []))
	terrain_effects = _typed_dictionary_array(save_data.get("terrain_effects", []))
	selected_unit_id = int(save_data.get("selected_unit_id", -1))
	active_unit_id = int(save_data.get("active_unit_id", -1))
	current_turn = str(save_data.get("current_turn", ""))
	active_turn_has_log = bool(save_data.get("active_turn_has_log", false))
	event_log = _typed_string_array(save_data.get("event_log", []))
	round_number = int(save_data.get("round_number", 1))
	next_map_event_round = int(save_data.get("next_map_event_round", 0))
	next_map_event_id = str(save_data.get("next_map_event_id", ""))
	map_event_cells.clear()
	for cell_data in _typed_dictionary_array(save_data.get("map_event_cells", [])):
		map_event_cells.append(Vector2i(int(cell_data.get("grid_x", -1)), int(cell_data.get("grid_y", -1))))
	if next_map_event_round == 0 or next_map_event_id == "":
		_schedule_next_map_event(round_number)
	turn_queue = _typed_int_array(save_data.get("turn_queue", []))
	turn_queue_index = int(save_data.get("turn_queue_index", -1))
	pending_skill_id = str(save_data.get("pending_skill_id", ""))
	general_skill_used = bool(save_data.get("general_skill_used", false))
	orc_general_is_kishak = bool(save_data.get("orc_general_is_kishak", false))
	is_animating = false
	selected_obstacle_cell = Vector2i(-1, -1)
	detonator_activated = bool(save_data.get("detonator_activated", false))
	board.set_detonator_warning_cells([])
	board.clear_falling_rock_cells()
	board.set_selected_unit(selected_unit_id)
	board.reset_unit_positions(units)
	_sync_board()
	event_log_label.text = "\n".join(event_log)


func _typed_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(item.duplicate(true))
	return result


func _typed_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		result.append(str(item))
	return result


func _typed_int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		result.append(int(item))
	return result


func _on_reset_battle_pressed() -> void:
	setup_mode = true
	help_mode_tutorial = true
	tutorial_page = 0
	tutorial_acknowledged = false
	_update_setup_hint_visibility()
	current_player_faction = ""
	current_enemy_faction = ""
	free_setup_mode = false
	_set_battle_background(DEFAULT_BATTLE_BACKGROUND_PATH)
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
	_refresh_general_display()
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
	if setup_mode or is_animating or not _is_manual_turn():
		return false
	var active_unit := _get_active_unit()
	return not active_unit.is_empty() and _is_manual_side(str(active_unit.side)) and selected_unit_id == active_unit.id and unit_data.id == active_unit.id


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
	var display_type: String = _get_obstacle_display_type(terrain)
	unit_portrait.visible = true
	var tex: Texture2D = OBSTACLE_PORTRAITS.get(display_type, null)
	if tex != null:
		unit_portrait.texture = tex
	unit_name_label.text = str(OBSTACLE_NAMES.get(display_type, display_type)).to_upper()
	unit_meta_label.text = "Przeszkoda terenowa"
	unit_stats_display.set_values({})
	unit_status_panel.clear()
	unit_abilities_panel.clear()
	if actions_label != null:
		actions_label.text = _get_obstacle_description(display_type)


func _get_obstacle_display_type(terrain: Dictionary) -> String:
	var type_id: String = str(terrain.get("id", ""))
	return "wydmy" if _is_desert_scenario() and type_id == "kamienie" else type_id


func _get_obstacle_description(display_type: String) -> String:
	var descriptions: Dictionary = OBSTACLE_WINTER_DESCRIPTIONS if _is_winter_scenario() else OBSTACLE_DESCRIPTIONS
	return str(descriptions.get(display_type, OBSTACLE_DESCRIPTIONS.get(display_type, "")))

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


func _on_cell_clicked(cell: Vector2i) -> void:
	if setup_mode:
		_handle_setup_cell_pressed(cell)
		return

	cell_click_revision += 1
	var click_revision: int = cell_click_revision
	await get_tree().create_timer(SINGLE_CLICK_DELAY).timeout
	if click_revision != cell_click_revision:
		return

	if is_animating or not _is_manual_turn():
		return

	var active_unit := _get_active_unit()
	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)):
		return

	if _try_activate_detonator(active_unit, cell):
		return

	if pending_skill_id != "":
		var pending_skill: Dictionary = skill_library.get(pending_skill_id, {})
		if str(pending_skill.get("effect_type", "")) == "charge":
			_try_execute_charge_move(active_unit, cell)
			return
		await _try_use_skill(active_unit, pending_skill_id, cell)
		_update_highlighted_cells(active_unit)
		_update_action_buttons()
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
	_log_event("%s porusza sie." % _unit_name_log_text(active_unit))
	_apply_terrain_effects_to_unit(active_unit)
	if _find_unit_by_id(int(active_unit.id)).is_empty():
		_end_current_activation()
		return
	_stop_unit_on_terrain(active_unit)
	_try_trigger_agility(active_unit)
	_sync_board()


func _on_cell_double_clicked(cell: Vector2i) -> void:
	cell_click_revision += 1
	var unit: Dictionary = _find_unit_at_cell(cell)
	if not unit.is_empty():
		unit_details_popup.show_unit(unit, skill_library, _load_unit_portrait(unit))
		return
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return
	var display_type: String = _get_obstacle_display_type(terrain)
	unit_details_popup.show_map_object(
		str(OBSTACLE_NAMES.get(display_type, display_type)),
		_get_obstacle_description(display_type),
		OBSTACLE_PORTRAITS.get(display_type, null)
	)


func _on_cell_right_clicked(cell: Vector2i) -> void:
	if setup_mode or is_animating or not _is_manual_turn():
		return
	var active_unit := _get_active_unit()
	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)) or selected_unit_id != active_unit.id:
		return
	var target := _find_unit_at_cell(cell)
	if target.is_empty() or target.side == active_unit.side:
		return
	if not _can_see_target(active_unit, target):
		return
	var charge_skill: Dictionary = _get_active_charge_skill(active_unit)
	if not charge_skill.is_empty():
		if _can_unit_attack(active_unit) and _can_charge_attack_target(active_unit, target, charge_skill):
			await _perform_charge_attack(active_unit, target, charge_skill, false)
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
		if not active_turn_has_log:
			_log_event("%s pasuje w tej turze." % _unit_name_log_text(unit))
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
	await get_tree().create_timer(1.5).timeout

	var target := _find_nearest_player_unit(enemy_unit)
	if target.is_empty():
		_end_current_activation()
		return
	if await _try_enemy_use_skill(enemy_unit, target):
		target = _find_nearest_player_unit(enemy_unit)
		if enemy_unit.is_empty() or target.is_empty():
			_end_current_activation()
			return

	var best_path := _find_best_enemy_path(enemy_unit, target)
	if _is_immobilized(enemy_unit):
		_log_event("%s nie rusza sie, bo jest unieruchomiony." % _unit_name_log_text(enemy_unit))
	elif not best_path.is_empty():
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
		_log_event("%s porusza sie." % _unit_name_log_text(enemy_unit))
		_apply_terrain_effects_to_unit(enemy_unit)
		_stop_unit_on_terrain(enemy_unit)
		_try_trigger_agility(enemy_unit)

	target = _find_nearest_player_unit(enemy_unit)
	if not enemy_unit.is_empty() and not target.is_empty() and await _try_enemy_use_skill(enemy_unit, target):
		_end_current_activation()
		return
	if not enemy_unit.is_empty() and not target.is_empty() and _can_see_target(enemy_unit, target) and _can_unit_attack(enemy_unit) and _is_in_attack_range(enemy_unit, Vector2i(target.grid_x, target.grid_y)):
		_perform_basic_attack(enemy_unit, target, false)
		_end_current_activation()
		return

	_end_current_activation()


func _find_unit_by_id(unit_id: int) -> Dictionary:
	for unit in units:
		if int(unit.id) == unit_id:
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

	var best_visible: Dictionary = {}
	var best_unseen: Dictionary = {}
	var best_visible_score: int = 1000000
	var best_unseen_score: int = 1000000
	for unit in units:
		if unit.side != "player":
			continue
		var score: int = _score_enemy_target(enemy_unit, unit)
		if not _can_see_target(enemy_unit, unit):
			if score < best_unseen_score:
				best_unseen_score = score
				best_unseen = unit
			continue
		if score < best_visible_score:
			best_visible_score = score
			best_visible = unit
	return best_visible if not best_visible.is_empty() else best_unseen


func _score_enemy_target(enemy_unit: Dictionary, target: Dictionary) -> int:
	var origin := Vector2i(enemy_unit.grid_x, enemy_unit.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	var score: int = _hex_distance(origin, target_cell) * 10
	if int(enemy_unit.get("attack_range", 1)) <= 1:
		score += _count_adjacent_units_for_side(target_cell, str(enemy_unit.side), int(enemy_unit.id)) * 12
		score -= _count_free_neighbors_for_unit(enemy_unit, target_cell) * 2
	return score


func _count_adjacent_units_for_side(cell: Vector2i, side: String, excluded_unit_id := -1) -> int:
	var count := 0
	for neighbor in _get_neighbors(cell):
		var unit := _find_unit_at_cell(neighbor)
		if not unit.is_empty() and int(unit.id) != excluded_unit_id and str(unit.side) == side:
			count += 1
	return count


func _count_free_neighbors_for_unit(unit: Dictionary, cell: Vector2i) -> int:
	var blocked: Dictionary = _get_blocked_cells(int(unit.id))
	var count := 0
	for neighbor in _get_neighbors(cell):
		if not blocked.has(neighbor) and _is_cell_passable(neighbor):
			count += 1
	return count


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
		if int(enemy_unit.get("attack_range", 1)) <= 1:
			candidate_score += _count_adjacent_units_for_side(cell, str(enemy_unit.side), int(enemy_unit.id)) * 4
		if _can_unit_attack(enemy_unit) and not _is_attack_blocked({"grid_x": cell.x, "grid_y": cell.y}, target_cell) and candidate_distance <= int(enemy_unit.get("attack_range", 1)):
			candidate_score -= 5
		if candidate_score < best_score:
			best_score = candidate_score
			best_path = candidate_path
	return best_path


func _get_path_hazard_penalty(unit: Dictionary, path: Array[Vector2i]) -> int:
	var penalty := 0
	for cell in path:
		if _is_known_trap_for_unit(unit, cell):
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
		if ["fire", "ice", "poison_cloud", "bear_trap", "goblin_trap"].has(str(effect.get("id", ""))):
			return true
	return false


func _is_known_trap_for_unit(unit: Dictionary, cell: Vector2i) -> bool:
	for trap_id in ["bear_trap", "goblin_trap"]:
		var trap: Dictionary = _get_terrain_effect_at(cell, trap_id)
		if trap.is_empty():
			continue
		var caster_side: String = str(trap.get("caster_side", ""))
		if caster_side == str(unit.side):
			return not _terrain_hides_unit(cell)
		if Time.get_ticks_msec() <= int(trap.get("visible_until_ms", 0)):
			return true
		return unit.side == "enemy" and int(trap.get("enemy_memory_until_round", 0)) >= round_number
	return false


func _try_enemy_use_trap(enemy_unit: Dictionary, target: Dictionary, skill_id: String) -> bool:
	if not _can_use_skill(enemy_unit, skill_id):
		return false
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return false
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _can_see_target(enemy_unit, target) and _can_unit_attack(enemy_unit) and _is_in_attack_range(enemy_unit, target_cell):
		return false
	if _has_trap_near_cell_for_side(target_cell, str(enemy_unit.side)):
		return false
	var origin := Vector2i(enemy_unit.grid_x, enemy_unit.grid_y)
	var trap_effect_id: String = str(skill.get("effect_type", ""))
	for cell in _get_neighbors(target_cell):
		if _hex_distance(origin, cell) > int(skill.get("range", 0)):
			continue
		if _is_attack_blocked(enemy_unit, cell) or _blocks_cell_skill_target(cell):
			continue
		if not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, trap_effect_id).is_empty():
			continue
		_execute_skill(enemy_unit, {}, skill, cell)
		return true
	return false


func _has_trap_near_cell_for_side(center: Vector2i, side: String) -> bool:
	for cell in _get_area_cells(center):
		for trap_id in ["bear_trap", "goblin_trap"]:
			var trap: Dictionary = _get_terrain_effect_at(cell, trap_id)
			if not trap.is_empty() and str(trap.get("caster_side", "")) == side:
				return true
	return false


func _try_enemy_use_skill(enemy_unit: Dictionary, target: Dictionary) -> bool:
	if not _can_see_target(enemy_unit, target):
		return false
	for trap_skill_id in ["pulapka_na_niedzwiedzie", "pulapka_goblina"]:
		if _try_enemy_use_trap(enemy_unit, target, trap_skill_id):
			return true
	for skill_id in enemy_unit.get("skill_ids", []):
		var skill: Dictionary = skill_library.get(str(skill_id), {})
		if skill.is_empty() or not _can_use_skill(enemy_unit, str(skill_id)):
			continue
		var target_type := str(skill.get("target_type", ""))
		var target_cell := Vector2i(target.grid_x, target.grid_y)
		if target_type == "self" and str(skill.get("effect_type", "")) == "self_buff" and not _has_effect(enemy_unit, str(skill.get("id", ""))):
			_execute_skill(enemy_unit, enemy_unit, skill, Vector2i(enemy_unit.grid_x, enemy_unit.grid_y))
			return true
		if target_type == "self" and str(skill.get("effect_type", "")) == "zadza_krwi":
			_execute_skill(enemy_unit, enemy_unit, skill, Vector2i(enemy_unit.grid_x, enemy_unit.grid_y))
			return true
		if str(skill.get("effect_type", "")) == "charge" and _try_enemy_charge(enemy_unit, target, skill):
			return true
		if target_type == "enemy_unit" and _hex_distance(Vector2i(enemy_unit.grid_x, enemy_unit.grid_y), target_cell) <= int(skill.get("range", 0)) and not _is_attack_blocked(enemy_unit, target_cell):
			if str(skill.get("effect_type", "")) == "hook_throw" and not _can_hook_throw_target(enemy_unit, target, skill):
				continue
			await _execute_skill(enemy_unit, target, skill, target_cell)
			return true
		if target_type == "cell" and str(skill.get("effect_type", "")) not in ["bear_trap", "goblin_trap"]:
			var cell := _find_enemy_area_skill_cell(enemy_unit, skill)
			if cell != Vector2i(-1, -1):
				await _execute_skill(enemy_unit, {}, skill, cell)
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
	board.set_map_event_warning_cells(map_event_cells if _is_map_event_warning_round(round_number, next_map_event_round) else [])
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
	_update_action_buttons()
	_refresh_turn_queue()


func _update_selection_visibility() -> void:
	var has_unit_selection := not _find_unit_by_id(selected_unit_id).is_empty()
	var has_obstacle_selection := selected_obstacle_cell.x != -1
	if board.has_method("set_grid_visible"):
		board.set_grid_visible(true)
	left_panel.visible = setup_mode or has_unit_selection or has_obstacle_selection
	unit_abilities_panel_frame.visible = has_unit_selection


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

	if not _is_manual_side(str(unit.side)):
		board.set_highlighted_cells([], [])
		board.set_hovered_move_path([])
		return

	var move_budget: int = int(unit.get("move_range", 0)) if unit.id != active_unit_id else _get_remaining_move(unit)
	var charge_skill: Dictionary = _get_active_charge_skill(unit)
	var move_cells: Array[Vector2i] = []
	var attack_cells: Array[Vector2i] = []
	if not charge_skill.is_empty():
		move_budget += _get_charge_stat_bonus(charge_skill, "move_range")
		move_cells = _get_reachable_cells(unit, move_budget, charge_skill)
		if _can_unit_attack(unit):
			attack_cells = _get_attackable_cells(unit, charge_skill)
	elif unit.id == active_unit_id and pending_skill_id != "":
		attack_cells = _get_skill_target_cells(unit, pending_skill_id)
	else:
		move_cells = _get_reachable_cells(unit, move_budget)
		if unit.id == active_unit_id and pending_skill_id == "" and _can_unit_attack(unit):
			attack_cells = _get_attackable_cells(unit)
	var move_opacity_mult: float = 0.5 if unit.id != active_unit_id else 1.0
	board.set_highlighted_cells(move_cells, attack_cells, move_opacity_mult)
	_on_board_cell_hovered(board.get_hovered_cell())


func _on_board_cell_hovered(cell: Vector2i) -> void:
	if not setup_mode and cell.x != -1 and _get_terrain_type_at(cell) == "detonator":
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		var detonator_index := _find_detonator_index(cell)
		var preview_cells: Array = []
		if detonator_index >= 0:
			var stored: Variant = obstacles[detonator_index].get("target_cells", [])
			if stored is Array:
				preview_cells = stored
		board.set_hovered_detonator_preview(preview_cells)
		return
	board.set_hovered_detonator_preview([])

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

	if is_animating:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	var active_unit := _get_active_unit()
	var charge_skill: Dictionary = _get_active_charge_skill(active_unit)
	if pending_skill_id != "" and charge_skill.is_empty():
		var pending_skill: Dictionary = skill_library.get(pending_skill_id, {})
		if str(pending_skill.get("effect_type", "")) == "hook_throw":
			_handle_hook_throw_hover(active_unit, pending_skill, cell)
			return
		if _is_area_damage_skill(pending_skill):
			_handle_area_skill_hover(active_unit, pending_skill, cell)
			return
		if str(pending_skill.get("target_type", "")) == "enemy_unit":
			_handle_enemy_unit_skill_hover(active_unit, pending_skill, cell)
			return
		if str(pending_skill.get("target_type", "")) == "ally_unit":
			_handle_ally_unit_skill_hover(active_unit, pending_skill, cell)
			return
		if str(pending_skill.get("target_type", "")) == "self":
			_handle_self_skill_hover(active_unit, cell)
			return
		if str(pending_skill.get("target_type", "")) == "cell":
			_handle_cell_skill_hover(active_unit, pending_skill, cell)
			return
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)):
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
	if not hovered_unit.is_empty() and hovered_unit.side != active_unit.side and _can_see_target(active_unit, hovered_unit) and _can_unit_attack(active_unit):
		if not charge_skill.is_empty() and _can_charge_attack_target(active_unit, hovered_unit, charge_skill):
			board.set_hovered_move_path([])
			board.set_hovered_attack_cell(cell)
			_clear_move_cost_label()
			return
		if charge_skill.is_empty() and _is_in_attack_range(active_unit, cell):
			board.set_hovered_move_path([])
			board.set_hovered_attack_cell(cell)
			_clear_move_cost_label()
			return

	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell, charge_skill)
	var path_cost: int = _get_path_cost(path)
	var remaining: int = _get_remaining_move(active_unit)
	if not charge_skill.is_empty():
		remaining += _get_charge_stat_bonus(charge_skill, "move_range")
	if path.is_empty() or path_cost > remaining:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		return

	board.set_hovered_move_path(path)
	board.set_hovered_attack_cell(Vector2i(-1, -1))
	_show_move_cost_label(path_cost, remaining - path_cost)


func _handle_enemy_unit_skill_hover(active_unit: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	var hovered_unit: Dictionary = _find_unit_at_cell(cell)
	if hovered_unit.is_empty() or not _can_target_enemy_with_skill(active_unit, hovered_unit, skill):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	board.set_hovered_attack_cell(cell)


func _handle_ally_unit_skill_hover(active_unit: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	var hovered_unit: Dictionary = _find_unit_at_cell(cell)
	if hovered_unit.is_empty() or not _can_target_ally_with_skill(active_unit, hovered_unit, skill):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	board.set_hovered_attack_cell(cell)


func _handle_self_skill_hover(active_unit: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	if cell != Vector2i(active_unit.grid_x, active_unit.grid_y):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	board.set_hovered_attack_cell(cell)


func _handle_hook_throw_hover(active_unit: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
		return
	var hovered_unit: Dictionary = _find_unit_at_cell(cell)
	if hovered_unit.is_empty() or not _can_hook_throw_target(active_unit, hovered_unit, skill):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
		return
	board.set_hovered_attack_cell(cell)
	board.set_hovered_pull_destination_cell(_get_pull_destination(active_unit, hovered_unit))


func _is_area_damage_skill(skill: Dictionary) -> bool:
	return str(skill.get("effect_type", "")) in ["arrow_rain", "fireball", "dynamite_throw"]


func _handle_area_skill_hover(active_unit: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	var valid_cells: Array[Vector2i] = _get_skill_target_cells(active_unit, str(skill.get("id", "")))
	if not valid_cells.has(cell):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	board.set_hovered_area_skill(cell, _get_area_cells(cell))


func _handle_cell_skill_hover(active_unit: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	if not _can_target_cell_with_skill(active_unit, cell, skill):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	board.set_hovered_area_skill(cell, _get_cell_skill_preview_cells(skill, cell))


func _get_cell_skill_preview_cells(skill: Dictionary, center: Vector2i) -> Array[Vector2i]:
	if str(skill.get("effect_type", "")) == "ice_ground":
		var cells: Array[Vector2i] = []
		for neighbor in _get_neighbors(center).slice(0, 3):
			cells.append(neighbor)
		if cells.is_empty():
			cells.append(center)
		return cells
	if str(skill.get("effect_type", "")) == "poison_cloud":
		return _get_area_cells(center)
	return [center]


func _can_target_cell_with_skill(caster: Dictionary, cell: Vector2i, skill: Dictionary) -> bool:
	if not _get_skill_target_cells(caster, str(skill.get("id", ""))).has(cell):
		return false
	var effect_type := str(skill.get("effect_type", ""))
	if effect_type == "bear_trap":
		return _find_unit_at_cell(cell).is_empty() and _get_terrain_effect_at(cell, "bear_trap").is_empty()
	if effect_type == "goblin_trap":
		return _find_unit_at_cell(cell).is_empty() and _get_terrain_effect_at(cell, "goblin_trap").is_empty()
	return true


func _can_target_enemy_with_skill(caster: Dictionary, target: Dictionary, skill: Dictionary) -> bool:
	if target.is_empty() or target.side == caster.side:
		return false
	if not _can_see_target(caster, target):
		return false
	var origin := Vector2i(caster.grid_x, caster.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _hex_distance(origin, target_cell) > int(skill.get("range", 0)):
		return false
	if _is_attack_blocked(caster, target_cell):
		return false
	if str(skill.get("effect_type", "")) == "hook_throw":
		return _get_pull_destination(caster, target) != Vector2i(-1, -1)
	return true


func _can_target_ally_with_skill(caster: Dictionary, target: Dictionary, skill: Dictionary) -> bool:
	if target.is_empty() or target.side != caster.side or target.id == caster.id:
		return false
	var origin := Vector2i(caster.grid_x, caster.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _hex_distance(origin, target_cell) > int(skill.get("range", 0)):
		return false
	return not _is_attack_blocked(caster, target_cell)


func _can_hook_throw_target(caster: Dictionary, target: Dictionary, skill: Dictionary) -> bool:
	return _can_target_enemy_with_skill(caster, target, skill)


func _get_active_charge_skill(unit: Dictionary) -> Dictionary:
	if unit.is_empty() or unit.id != active_unit_id or pending_skill_id == "":
		return {}
	var skill: Dictionary = skill_library.get(pending_skill_id, {})
	if str(skill.get("effect_type", "")) != "charge":
		return {}
	return skill


func _get_charge_stat_bonus(skill: Dictionary, stat_name: String) -> int:
	for change in skill.get("effect", {}).get("stat_changes", []):
		if str(change.get("stat", "")) == stat_name and str(change.get("mode", "")) == "flat":
			return int(change.get("value", 0))
	return 0


func _get_charge_damage_multiplier(skill: Dictionary) -> float:
	for change in skill.get("effect", {}).get("stat_changes", []):
		if str(change.get("stat", "")) == "dmg" and str(change.get("mode", "")) == "percent":
			return 1.0 + float(change.get("value", 0)) / 100.0
	return 1.0


func _requires_forward_only(unit: Dictionary, charge_skill: Dictionary = {}) -> bool:
	if not charge_skill.is_empty():
		return true
	for effect in unit.get("active_effects", []):
		if bool(effect.get("forward_only", false)):
			return true
	return false


func _get_forward_axis_delta(unit: Dictionary) -> int:
	return 1 if str(unit.get("side", "")) == "player" else -1


func _get_direct_forward_cell(from_cell: Vector2i, unit: Dictionary) -> Vector2i:
	return from_cell + Vector2i(_get_forward_axis_delta(unit), 0)


func _is_direct_forward_step(from_cell: Vector2i, to_cell: Vector2i, unit: Dictionary) -> bool:
	return to_cell == _get_direct_forward_cell(from_cell, unit)


func _is_forward_step(unit: Dictionary, from_cell: Vector2i, to_cell: Vector2i, charge_skill: Dictionary = {}) -> bool:
	if not _requires_forward_only(unit, charge_skill):
		return true
	if not charge_skill.is_empty():
		return _is_direct_forward_step(from_cell, to_cell, unit)
	return (to_cell.x - from_cell.x) * _get_forward_axis_delta(unit) > 0


func _is_forward_cell_from(attacker_cell: Vector2i, target_cell: Vector2i, unit: Dictionary) -> bool:
	if attacker_cell == target_cell:
		return false
	if target_cell.y != attacker_cell.y:
		return false
	return (target_cell.x - attacker_cell.x) * _get_forward_axis_delta(unit) > 0


func _is_forward_cell_for_unit(unit: Dictionary, cell: Vector2i, charge_skill: Dictionary = {}) -> bool:
	if not _requires_forward_only(unit, charge_skill):
		return true
	var origin := Vector2i(int(unit.get("grid_x", 0)), int(unit.get("grid_y", 0)))
	if cell == origin:
		return true
	return _is_forward_cell_from(origin, cell, unit)


func _get_reachable_cells(unit: Dictionary, max_distance: int, charge_skill: Dictionary = {}) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var blocked: Dictionary = _get_blocked_cells(unit.id)
	var costs: Dictionary = {origin: 0}
	var frontier: Array[Vector2i] = [origin]
	var reachable: Array[Vector2i] = []

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var current_cost: int = costs[current]
		for neighbor in _get_neighbors(current):
			if not _is_forward_step(unit, current, neighbor, charge_skill):
				continue
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
	if not _is_cell_passable(cell):
		return false
	if cell == Vector2i(unit.grid_x, unit.grid_y):
		return true
	var occupant: Dictionary = _find_unit_at_cell(cell)
	return occupant.is_empty()


func _is_setup_cell_allowed_for_side(side: String, cell: Vector2i) -> bool:
	if free_setup_mode:
		return true
	if side == "player":
		return current_player_faction == "testowa" or cell.x < SETUP_COLUMNS
	if side == "enemy":
		return current_enemy_faction == "testowa" or cell.x >= GRID_COLUMNS - SETUP_COLUMNS
	return false


func _get_attackable_cells(unit: Dictionary, charge_skill: Dictionary = {}) -> Array[Vector2i]:
	var origin: Vector2i = Vector2i(unit.grid_x, unit.grid_y)
	var attackable: Array[Vector2i] = []
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var cell := Vector2i(column, row)
			if cell == origin:
				continue
			var target: Dictionary = _find_unit_at_cell(cell)
			if target.is_empty() or target.side == unit.side or not _can_see_target(unit, target):
				continue
			if not charge_skill.is_empty():
				if _can_charge_attack_target(unit, target, charge_skill):
					attackable.append(cell)
			elif _is_in_attack_range(unit, cell):
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


func _is_in_attack_range(unit: Dictionary, cell: Vector2i, charge_skill: Dictionary = {}) -> bool:
	if not _is_forward_cell_for_unit(unit, cell, charge_skill):
		return false
	var attack_range: int = int(unit.get("attack_range", 1)) + _get_charge_stat_bonus(charge_skill, "attack_range")
	if _hex_distance(Vector2i(int(unit.get("grid_x", 0)), int(unit.get("grid_y", 0))), cell) > attack_range:
		return false
	return not _is_attack_blocked(unit, cell)


func _is_attack_blocked_from(from_cell: Vector2i, target_cell: Vector2i) -> bool:
	if from_cell == target_cell:
		return false
	for cell in _get_hex_line(from_cell, target_cell):
		if cell == from_cell or cell == target_cell:
			continue
		if _is_cell_obstacle(cell):
			return true
	return false


func _can_attack_from_cell_for_charge(unit: Dictionary, from_cell: Vector2i, target_cell: Vector2i, skill: Dictionary) -> bool:
	if not _is_forward_cell_from(from_cell, target_cell, unit):
		return false
	var attack_range: int = int(unit.get("attack_range", 1)) + _get_charge_stat_bonus(skill, "attack_range")
	if _hex_distance(from_cell, target_cell) > attack_range:
		return false
	return not _is_attack_blocked_from(from_cell, target_cell)


func _find_charge_approach_destination(unit: Dictionary, target: Dictionary, skill: Dictionary) -> Vector2i:
	var origin := Vector2i(unit.grid_x, unit.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	var move_budget: int = _get_remaining_move(unit) + _get_charge_stat_bonus(skill, "move_range")
	var best_cell := Vector2i(-1, -1)
	var best_score: int = 1000000
	var candidates: Array[Vector2i] = [origin]
	candidates.append_array(_get_reachable_cells(unit, move_budget, skill))
	for cell in candidates:
		if not _can_attack_from_cell_for_charge(unit, cell, target_cell, skill):
			continue
		var distance: int = _hex_distance(cell, target_cell)
		var score: int = distance * 10
		if distance == 1:
			score = 0
		if score < best_score:
			best_score = score
			best_cell = cell
	return best_cell


func _find_charge_approach_path(unit: Dictionary, target: Dictionary, skill: Dictionary) -> Array[Vector2i]:
	var destination: Vector2i = _find_charge_approach_destination(unit, target, skill)
	if destination == Vector2i(-1, -1):
		return []
	var origin := Vector2i(unit.grid_x, unit.grid_y)
	if destination == origin:
		return []
	return _get_executable_move_path(_find_path(unit, origin, destination, skill))


func _can_charge_attack_target(unit: Dictionary, target: Dictionary, skill: Dictionary) -> bool:
	if target.is_empty() or target.side == unit.side:
		return false
	if not _can_see_target(unit, target):
		return false
	return _find_charge_approach_destination(unit, target, skill) != Vector2i(-1, -1)


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


func _commit_charge_skill(caster: Dictionary, skill: Dictionary) -> void:
	caster.action_points = max(0, int(caster.get("action_points", 0)) - int(skill.get("ap_cost", 0)))
	if not caster.has("skill_cooldowns"):
		caster["skill_cooldowns"] = {}
	caster.skill_cooldowns[str(skill.get("id", ""))] = int(skill.get("cooldown", 0))
	if int(caster.get("id", -1)) == active_unit_id:
		pending_skill_id = ""
	_log_event("%s uzywa %s." % [_unit_name_log_text(caster), str(skill.get("name", skill.get("id", "")))])


func _perform_charge_attack(attacker: Dictionary, target: Dictionary, skill: Dictionary, end_turn_after := true, animate_move := true) -> void:
	if not _can_charge_attack_target(attacker, target, skill):
		return

	var move_path: Array[Vector2i] = _find_charge_approach_path(attacker, target, skill)
	if not move_path.is_empty():
		var destination: Vector2i = move_path[move_path.size() - 1]
		attacker.grid_x = destination.x
		attacker.grid_y = destination.y
		attacker.remaining_move = 0
		if animate_move:
			is_animating = true
			_sync_board()
			board.animate_unit_path(attacker.id, move_path)
			await board.animation_finished
			is_animating = false
			_apply_terrain_effects_to_unit(attacker)
			if _find_unit_by_id(int(attacker.id)).is_empty():
				_end_current_activation()
				return
			_stop_unit_on_terrain(attacker)
			_try_trigger_agility(attacker)
		else:
			_sync_board()
	else:
		attacker.remaining_move = 0

	var attacker_cell := Vector2i(attacker.grid_x, attacker.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if not _is_forward_cell_from(attacker_cell, target_cell, attacker):
		return

	_commit_charge_skill(attacker, skill)
	_reveal_if_in_bush(attacker)
	var total_damage: int = _calculate_damage(attacker, target, _get_charge_damage_multiplier(skill))
	var result: Dictionary = _apply_attack_damage(attacker, target, total_damage, _hex_distance(Vector2i(attacker.grid_x, attacker.grid_y), Vector2i(target.grid_x, target.grid_y)) == 1)
	var hit_target: Dictionary = result.get("target", target)
	var casualties: int = int(result.get("casualties", 0))
	_log_event(
		"%s szarzuje na %s za %s obrazen i zadaje %s strat." % [
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


func _try_execute_charge_move(unit: Dictionary, cell: Vector2i) -> void:
	var skill: Dictionary = _get_active_charge_skill(unit)
	if skill.is_empty():
		return
	if selected_unit_id != unit.id:
		return

	var clicked_unit: Dictionary = _find_unit_at_cell(cell)
	if not clicked_unit.is_empty() and clicked_unit.side != unit.side and _can_unit_attack(unit) and _can_charge_attack_target(unit, clicked_unit, skill):
		await _perform_charge_attack(unit, clicked_unit, skill, false)
		return

	var max_distance: int = _get_remaining_move(unit) + _get_charge_stat_bonus(skill, "move_range")
	if max_distance <= 0:
		return

	var path := _find_path(unit, Vector2i(unit.grid_x, unit.grid_y), cell, skill)
	var path_cost: int = _get_path_cost(path)
	if path.is_empty():
		if _is_cell_obstacle(cell):
			_show_obstacle_details(cell)
		return
	if path_cost > max_distance:
		return

	var move_path: Array[Vector2i] = _get_executable_move_path(path)
	is_animating = true
	var destination: Vector2i = move_path[move_path.size() - 1]
	unit.grid_x = destination.x
	unit.grid_y = destination.y
	unit.remaining_move = 0
	_sync_board()
	_show_move_cost_label(path_cost, 0)
	board.animate_unit_path(unit.id, move_path)
	await board.animation_finished
	is_animating = false
	_clear_move_cost_label()
	_commit_charge_skill(unit, skill)
	_log_event("%s szarzuje do przodu." % _unit_name_log_text(unit))
	_apply_terrain_effects_to_unit(unit)
	if _find_unit_by_id(int(unit.id)).is_empty():
		_end_current_activation()
		return
	_stop_unit_on_terrain(unit)
	_try_trigger_agility(unit)
	_sync_board()


func _try_enemy_charge(enemy_unit: Dictionary, target: Dictionary, skill: Dictionary) -> bool:
	if not _can_use_skill(enemy_unit, str(skill.get("id", ""))):
		return false
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _can_unit_attack(enemy_unit) and _can_charge_attack_target(enemy_unit, target, skill):
		_perform_charge_attack(enemy_unit, target, skill, false, false)
		return true

	var move_budget: int = _get_remaining_move(enemy_unit) + _get_charge_stat_bonus(skill, "move_range")
	if move_budget <= 0:
		return false

	var origin := Vector2i(enemy_unit.grid_x, enemy_unit.grid_y)
	var best_path: Array[Vector2i] = []
	var best_score: int = 1000000
	for cell in _get_reachable_cells(enemy_unit, move_budget, skill):
		var candidate_path: Array[Vector2i] = _get_executable_move_path(_find_path(enemy_unit, origin, cell, skill))
		if candidate_path.is_empty():
			continue
		var score: int = _hex_distance(cell, target_cell)
		if score < best_score:
			best_score = score
			best_path = candidate_path
	if best_path.is_empty():
		return false

	var destination: Vector2i = best_path[best_path.size() - 1]
	enemy_unit.grid_x = destination.x
	enemy_unit.grid_y = destination.y
	enemy_unit.remaining_move = 0
	_commit_charge_skill(enemy_unit, skill)
	_log_event("%s szarzuje do przodu." % _unit_name_log_text(enemy_unit))
	_apply_terrain_effects_to_unit(enemy_unit)
	_stop_unit_on_terrain(enemy_unit)
	_sync_board()
	return true


func _calculate_damage(attacker: Dictionary, target: Dictionary, damage_multiplier := 1.0) -> int:
	var scaled_damage: float = max(1.0, float(attacker.get("dmg", 1)) * damage_multiplier)
	var raw_total: float = scaled_damage * float(attacker.get("count", 1))
	var defense_reduction: float = float(target.get("def", 0)) * float(target.get("count", 1))
	return max(1, int(raw_total - defense_reduction))


func _get_incoming_damage_multiplier(unit: Dictionary) -> float:
	var multiplier: float = 1.0
	for effect in unit.get("active_effects", []):
		var bonus: int = int(effect.get("incoming_damage_percent", 0))
		if bonus > 0:
			multiplier += float(bonus) / 100.0
	return multiplier


func _adjust_incoming_damage(target: Dictionary, total_damage: int) -> int:
	if total_damage <= 0:
		return total_damage
	return max(1, int(ceil(float(total_damage) * _get_incoming_damage_multiplier(target))))


func _apply_damage_to_unit(target: Dictionary, total_damage: int) -> int:
	var damage: int = _adjust_incoming_damage(target, total_damage)
	var previous_count: int = int(target.get("count", 0))
	var base_hp: int = int(target.get("base_hp", target.get("hp", 1)))
	var current_total_hp: int = int(target.get("current_total_hp", base_hp * previous_count))
	if damage > 0:
		board.play_damage_animation(int(target.get("id", -1)))
		_reveal_if_in_bush(target)
	target["current_total_hp"] = max(0, current_total_hp - max(1, damage))
	_refresh_unit_health_state(target)
	return max(0, previous_count - int(target.get("count", 0)))


func _apply_attack_damage(attacker: Dictionary, target: Dictionary, total_damage: int, melee := false, play_animation := true, projectile_kind_override := "") -> Dictionary:
	var hit_target: Dictionary = target
	var damage := total_damage
	if melee:
		var guardian := _get_guardian_for(target)
		if not guardian.is_empty():
			hit_target = guardian
			damage = max(1, int(ceil(float(damage) * 0.8)))
			_log_event("%s zaslania %s Zelazna Kurtyna." % [_unit_name_log_text(guardian), _unit_name_log_text(target)])
	if play_animation:
		var projectile_kind: String = projectile_kind_override if projectile_kind_override != "" else _get_attack_projectile_kind(attacker)
		board.play_attack_animation(int(attacker.id), int(hit_target.id), projectile_kind)
	if _consume_energy_barrier(hit_target):
		_log_event("Bariera Energetyczna blokuje atak na %s." % _unit_name_log_text(hit_target))
		return {"target": hit_target, "damage": 0, "casualties": 0}
	var casualties: int = _apply_damage_to_unit(hit_target, damage)
	return {"target": hit_target, "damage": _adjust_incoming_damage(hit_target, damage), "casualties": casualties}


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
	var removed_queue_index: int = turn_queue.find(int(target.get("id", -1)))
	turn_queue.erase(int(target.get("id", -1)))
	if removed_queue_index >= 0 and removed_queue_index <= turn_queue_index:
		turn_queue_index -= 1
	if target.get("id", -1) == selected_unit_id:
		selected_unit_id = -1
	_check_victory()


func _try_use_skill(unit: Dictionary, skill_id: String, cell: Vector2i) -> void:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return
	if not _can_use_skill(unit, skill_id):
		return

	if str(skill.get("target_type", "")) == "self":
		if cell != Vector2i(unit.grid_x, unit.grid_y):
			return
		await _execute_skill(unit, unit, skill, cell)
		return

	if str(skill.get("target_type", "")) == "cell":
		if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(skill.get("range", 0)):
			return
		if _is_attack_blocked(unit, cell) or _blocks_cell_skill_target(cell):
			return
		if str(skill.get("effect_type", "")) == "bear_trap" and (not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, "bear_trap").is_empty()):
			return
		if str(skill.get("effect_type", "")) == "goblin_trap" and (not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, "goblin_trap").is_empty()):
			return
		await _execute_skill(unit, {}, skill, cell)
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
	if str(skill.get("effect_type", "")) == "hook_throw" and not _can_hook_throw_target(unit, target, skill):
		return
	await _execute_skill(unit, target, skill, cell)


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
		"pnacza":
			_execute_pnacza(caster, target)
		"curse_throw":
			_execute_curse_throw(caster, target)
		"shield_push":
			await _execute_shield_push(caster, target)
		"hook_throw":
			await _execute_hook_throw(caster, target)
		"fireball":
			await _execute_fireball(caster, target_cell)
		"dynamite_throw":
			_execute_dynamite_throw(caster, target_cell)
		"arrow_rain":
			await _execute_arrow_rain(caster, target_cell)
		"ice_ground":
			await _execute_ice_ground(caster, target_cell)
		"poison_cloud":
			_execute_poison_cloud(caster, target_cell)
		"bear_trap":
			_execute_bear_trap(caster, target_cell)
		"goblin_trap":
			_execute_goblin_trap(caster, target_cell)
		"energy_barrier":
			_execute_energy_barrier(caster)
		"iron_curtain":
			_execute_iron_curtain(caster, target)
		"self_buff":
			_execute_self_buff(caster, skill)
		"zadza_krwi":
			_execute_zadza_krwi(caster, skill)
		"focused_strike":
			_execute_focused_strike(caster, target, skill)
		"rozszarpanie":
			_execute_rozszarpanie(caster, target)

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


func _execute_pnacza(caster: Dictionary, target: Dictionary) -> void:
	_apply_or_refresh_effect(target, {
		"id": "immobilize",
		"name": "Unieruchomienie",
		"category": "debuff",
		"remaining_turns": 2,
		"stat_changes": [
			{"stat": "move_range", "mode": "set", "value": 0}
		]
	})
	_log_event("%s oplata %s Pnaczami na 2 tury." % [_unit_name_log_text(caster), _unit_name_log_text(target)])


func _execute_curse_throw(caster: Dictionary, target: Dictionary) -> void:
	_apply_or_refresh_effect(target, {
		"id": "klatwa",
		"remaining_turns": 2,
	})
	_log_event("%s rzuca Klątwą w %s na 2 tury." % [_unit_name_log_text(caster), _unit_name_log_text(target)])


func _execute_hook_throw(caster: Dictionary, target: Dictionary) -> void:
	var destination: Vector2i = _get_pull_destination(caster, target)
	if destination == Vector2i(-1, -1):
		_log_event("%s rzuca hakiem w %s, ale nie moze przyciagnac celu." % [_unit_name_log_text(caster), _unit_name_log_text(target)])
		return
	var start_cell := Vector2i(target.grid_x, target.grid_y)
	var pull_path: Array[Vector2i] = _get_pull_path(start_cell, destination)
	is_animating = true
	board.play_hook_throw_animation(int(caster.id), int(target.id))
	await get_tree().create_timer(0.15).timeout
	target["grid_x"] = destination.x
	target["grid_y"] = destination.y
	_sync_board()
	if pull_path.is_empty():
		board.snap_unit_to_cell(int(target.id), destination)
	else:
		board.animate_unit_pull_path(int(target.id), pull_path)
		await board.animation_finished
	is_animating = false
	_sync_board()
	_log_event("%s przyciaga %s Rzutem Hakiem." % [_unit_name_log_text(caster), _unit_name_log_text(target)])


func _get_pull_path(start_cell: Vector2i, destination_cell: Vector2i) -> Array[Vector2i]:
	var line_cells: Array[Vector2i] = _get_hex_line(start_cell, destination_cell)
	if line_cells.size() <= 1:
		return []
	return line_cells.slice(1)


func _execute_shield_push(caster: Dictionary, target: Dictionary) -> void:
	is_animating = true
	board.play_shield_push_animation(int(caster.id), int(target.id))
	await get_tree().create_timer(0.12).timeout
	var total_damage := _calculate_damage(caster, target)
	var result := _apply_attack_damage(caster, target, total_damage, true, false)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	var pushed := false
	if int(result.get("damage", 0)) > 0 and int(hit_target.id) == int(target.id):
		var destination: Vector2i = _get_push_destination(caster, target)
		if destination != Vector2i(-1, -1):
			pushed = true
			var push_path: Array[Vector2i] = [destination]
			target["grid_x"] = destination.x
			target["grid_y"] = destination.y
			_sync_board()
			board.animate_unit_knockback_path(int(target.id), push_path)
			await board.animation_finished
	if int(result.get("damage", 0)) > 0 and not pushed and int(hit_target.get("count", 0)) > 0:
		_apply_or_refresh_effect(hit_target, {
			"id": "ogluszenie",
			"name": "Ogluszenie",
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [],
			"skip_turn": true
		})
	is_animating = false
	var suffix := " Atak zostaje zablokowany."
	if int(result.get("damage", 0)) > 0:
		suffix = " Cel zostaje odepchniety." if pushed else " Cel wpada w blokade i zostaje ogluszony."
	_log_event(
		"%s odepycha %s Odepchnieciem Tarcza za %s obrazen i %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			suffix
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_fireball(caster: Dictionary, center: Vector2i) -> void:
	var area_cells: Array[Vector2i] = _get_area_cells(center)
	is_animating = true
	board.play_fireball_animation(int(caster.id), center, area_cells)
	await get_tree().create_timer(0.40).timeout
	var hit_names: Array[String] = []
	for cell in area_cells:
		var target := _find_unit_at_cell(cell)
		if target.is_empty() or target.side == caster.side:
			continue
		var multiplier := 1.0 if cell == center else 0.5
		var total_damage := _calculate_damage(caster, target, multiplier)
		var result := _apply_attack_damage(caster, target, total_damage, false, false)
		var hit_target: Dictionary = result.get("target", target)
		var casualties: int = int(result.get("casualties", 0))
		hit_names.append(
			"trafia %s za %s obrazen i %s strat" % [
				_unit_name_log_text(hit_target),
				_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
				_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
			]
		)
		_cleanup_destroyed_unit(hit_target)
	_add_terrain_effect(center, "fire", 1)
	is_animating = false
	_log_event("%s rzuca Kule Ognia: %s." % [_unit_name_log_text(caster), "brak trafien" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_dynamite_throw(caster: Dictionary, center: Vector2i) -> void:
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
	_log_event("%s rzuca dynamitem: %s." % [_unit_name_log_text(caster), "brak trafien" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_arrow_rain(caster: Dictionary, center: Vector2i) -> void:
	var area_cells: Array[Vector2i] = _get_area_cells(center)
	is_animating = true
	board.play_arrow_rain_animation(int(caster.id), area_cells)
	await get_tree().create_timer(0.42).timeout
	var hit_names: Array[String] = []
	for cell in area_cells:
		var target := _find_unit_at_cell(cell)
		if target.is_empty() or target.side == caster.side:
			continue
		var multiplier := 0.5 if cell == center else 0.35
		var total_damage := _calculate_damage(caster, target, multiplier)
		var result := _apply_attack_damage(caster, target, total_damage, false, false)
		var hit_target: Dictionary = result.get("target", target)
		hit_names.append("%s (%s/%s)" % [_unit_name_log_text(hit_target), result.get("damage", total_damage), result.get("casualties", 0)])
		_cleanup_destroyed_unit(hit_target)
	is_animating = false
	_log_event("%s uzywa Deszczu Strzal: %s." % [_unit_name_log_text(caster), "brak trafien" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_ice_ground(caster: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = []
	for cell in _get_neighbors(center).slice(0, 3):
		cells.append(cell)
	if cells.is_empty():
		cells.append(center)
	is_animating = true
	board.play_ice_ground_animation(int(caster.id), cells)
	await get_tree().create_timer(0.36).timeout
	for cell in cells:
		_add_terrain_effect(cell, "ice", 2)
	_apply_terrain_effects_in_cells(cells)
	is_animating = false
	_log_event("%s zamraza podloze." % _unit_name_log_text(caster))


func _execute_poison_cloud(caster: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = _get_area_cells(center)
	for cell in cells:
		_add_terrain_effect(cell, "poison_cloud", 2, int(caster.id), max(1, int(ceil(float(caster.dmg) * 0.25))))
	_apply_terrain_effects_in_cells(cells)
	_log_event("%s tworzy Chmure Toksyczna." % _unit_name_log_text(caster))


func _execute_bear_trap(caster: Dictionary, cell: Vector2i) -> void:
	_add_terrain_effect(cell, "bear_trap", 99, int(caster.id), max(1, int(ceil(float(caster.dmg) * 0.25))))
	var trap: Dictionary = _get_terrain_effect_at(cell, "bear_trap")
	trap["caster_side"] = str(caster.side)
	trap["visible_until_ms"] = Time.get_ticks_msec() + 5000
	trap["enemy_memory_until_round"] = round_number + 1 if caster.side == "player" else round_number
	_log_event("%s zaklada Pulapke na Niedzwiedzie." % _unit_name_log_text(caster))


func _execute_goblin_trap(caster: Dictionary, cell: Vector2i) -> void:
	_add_terrain_effect(cell, "goblin_trap", 99, int(caster.id), max(1, int(ceil(float(caster.dmg) * 0.25))))
	var trap: Dictionary = _get_terrain_effect_at(cell, "goblin_trap")
	trap["caster_side"] = str(caster.side)
	trap["visible_until_ms"] = Time.get_ticks_msec() + 5000
	trap["enemy_memory_until_round"] = round_number + 1 if caster.side == "player" else round_number
	_log_event("%s zaklada Pulapke Goblina." % _unit_name_log_text(caster))


func _trigger_goblin_trap(unit: Dictionary, trap: Dictionary) -> void:
	var damage: int = _calculate_tick_damage(unit, int(trap.get("tick_damage", 1)))
	var casualties := _apply_damage_to_unit(unit, damage)
	_apply_or_refresh_effect(unit, {
		"id": "immobilize",
		"name": "Unieruchomienie",
		"category": "debuff",
		"remaining_turns": 2,
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
		"tick_damage": KRWAWIENIE_TICK_DAMAGE
	})
	terrain_effects.erase(trap)
	_log_event("%s wpada w Pulapke Goblina za %s obrazen i %s strat." % [_unit_name_log_text(unit), _color_log_text(str(damage), LOG_COLOR_DAMAGE), _color_log_text(str(casualties), LOG_COLOR_DAMAGE)])
	_cleanup_destroyed_unit(unit)


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


func _execute_zadza_krwi(caster: Dictionary, skill: Dictionary) -> void:
	caster["base_dmg"] = int(caster.get("base_dmg", caster.get("dmg", 0))) + 2
	caster["base_def"] = int(caster.get("base_def", caster.get("def", 0))) - 2
	var stack_amount: int = 1
	for effect in caster.get("active_effects", []):
		if str(effect.get("id", "")) == "zadza_krwi":
			stack_amount = int(effect.get("stack_amount", 1)) + 1
			break
	_apply_or_refresh_effect(caster, {
		"id": "zadza_krwi",
		"name": "Żądza krwi",
		"category": "buff",
		"permanent": true,
		"stack_amount": stack_amount,
		"stat_changes": []
	})
	_recalculate_unit_stats(caster)
	_log_event(
		"%s uzywa %s i zyskuje stale +2 DMG oraz -2 DEF (lacznie +%d DMG, -%d DEF do konca bitwy)." % [
			_unit_name_log_text(caster),
			str(skill.get("name", "Żądza krwi")),
			stack_amount * 2,
			stack_amount * 2
		]
	)


func _execute_focused_strike(caster: Dictionary, target: Dictionary, skill: Dictionary = {}) -> void:
	var total_damage := _calculate_damage(caster, target)
	var projectile_kind: String = str(skill.get("projectile_kind", ""))
	var result := _apply_attack_damage(caster, target, total_damage, false, true, projectile_kind)
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


func _execute_rozszarpanie(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.5)
	var result := _apply_attack_damage(caster, target, total_damage, false, true)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	var bleed_suffix := ""
	if int(result.get("damage", 0)) > 0:
		_apply_or_refresh_effect(hit_target, {
			"id": "krwawienie",
			"name": "Krwawienie",
			"category": "debuff",
			"remaining_turns": 2,
			"stat_changes": [],
			"tick_damage": KRWAWIENIE_TICK_DAMAGE
		})
		bleed_suffix = " Cel krwawi."
	_log_event(
		"%s rozszarpa %s za %s obrazen i %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			bleed_suffix
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


func _apply_terrain_effects_to_unit(unit: Dictionary, apply_entry_effect := true) -> void:
	for effect in terrain_effects:
		if int(effect.get("grid_x", -1)) != int(unit.grid_x) or int(effect.get("grid_y", -1)) != int(unit.grid_y):
			continue
		match str(effect.get("id", "")):
			"fire":
				_apply_or_refresh_effect(unit, {
					"id": "ploniecie",
					"remaining_turns": PLONIECIE_TURNS,
					"tick_damage": PLONIECIE_TICK_DAMAGE
				})
				_log_event("%s staje w ogniu." % _unit_name_log_text(unit))
			"ice":
				_apply_or_refresh_effect(unit, {"id": "lodowe_podloze"})
				_log_event("%s slizga sie na lodzie." % _unit_name_log_text(unit))
			"poison_cloud":
				if _apply_poison_effect(unit, "zatrucie", "Zatrucie", 2, int(effect.get("tick_damage", 1))):
					_log_event("%s wdycha toksyczna chmure." % _unit_name_log_text(unit))
			"bear_trap":
				_trigger_bear_trap(unit, effect)
			"goblin_trap":
				_trigger_goblin_trap(unit, effect)
	if apply_entry_effect:
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
		"tick_damage": KRWAWIENIE_TICK_DAMAGE
	})
	terrain_effects.erase(trap)
	_log_event("%s wpada w Pulapke na Niedzwiedzie za %s obrazen i %s strat." % [_unit_name_log_text(unit), _color_log_text(str(damage), LOG_COLOR_DAMAGE), _color_log_text(str(casualties), LOG_COLOR_DAMAGE)])
	_cleanup_destroyed_unit(unit)


func _apply_terrain_entry_effect(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	_apply_elf_statue_buff(unit)
	if effect.is_empty():
		_remove_hiding_effects(unit)
		return
	var terrain_name: String = str(effect.get("name", "teren"))
	if bool(effect.get("instant_death", false)):
		_trigger_hole_death(unit, terrain_name)
		return
	if _terrain_hides_unit(cell):
		_apply_or_refresh_effect(unit, effect)
		unit["is_hidden"] = true
		_log_event("%s wchodzi w %s i znika z pola widzenia." % [_unit_name_log_text(unit), terrain_name])
	else:
		unit["is_hidden"] = false
		_log_event("%s wchodzi w %s i traci reszte ruchu." % [_unit_name_log_text(unit), terrain_name])
		if _is_winter_scenario() and _is_water_cell(cell):
			_try_ice_break_death(unit, cell)


func _trigger_hole_death(unit: Dictionary, terrain_name: String) -> void:
	_log_event(_color_log_text("%s wpada do %s i ginie!" % [_unit_name_log_text(unit), terrain_name], LOG_COLOR_DAMAGE))
	_show_screen_message("%s wpada do %s i ginie!" % [str(unit.get("name", "Jednostka")), terrain_name], 3.0)
	unit["count"] = 0
	unit["current_total_hp"] = 0
	unit["current_hp"] = 0
	unit["is_hidden"] = false
	_cleanup_destroyed_unit(unit)


func _apply_elf_statue_buff(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	var has_statue_neighbor := false
	for neighbor in _get_neighbors(cell):
		if _get_terrain_type_at(neighbor) == "elf_statue":
			has_statue_neighbor = true
			break
	if has_statue_neighbor:
		_apply_or_refresh_effect(unit, {"id": "blogoslawienstwo_elfow"})
	else:
		_remove_effect(unit, "blogoslawienstwo_elfow")


func _refresh_terrain_bound_effects(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	if _terrain_hides_unit(cell):
		var terrain_effect: Dictionary = _get_terrain_entry_effect(cell)
		if not terrain_effect.is_empty():
			_apply_or_refresh_effect(unit, terrain_effect)
			unit["is_hidden"] = true
		return
	for effect in unit.get("active_effects", []):
		if bool(effect.get("terrain_bound", false)) and bool(effect.get("hides_unit", false)):
			_remove_hiding_effects(unit)
			return


func _get_terrain_type_at(cell: Vector2i) -> String:
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y:
			return str(obstacle.get("type", ""))
	return ""


func _try_activate_detonator(active_unit: Dictionary, cell: Vector2i) -> bool:
	if _get_terrain_type_at(cell) != "detonator":
		return false
	var unit_cell := Vector2i(int(active_unit.grid_x), int(active_unit.grid_y))
	if _hex_distance(unit_cell, cell) != 1:
		return false
	var detonator_index := _find_detonator_index(cell)
	if detonator_index < 0:
		return false
	if detonator_activated:
		return false
	_trigger_detonator(active_unit, cell, detonator_index)
	return true


func _find_detonator_index(cell: Vector2i) -> int:
	for index in obstacles.size():
		var obstacle: Dictionary = obstacles[index]
		if int(obstacle.get("grid_x", -1)) == cell.x and int(obstacle.get("grid_y", -1)) == cell.y and str(obstacle.get("type", "")) == "detonator":
			return index
	return -1


func _trigger_detonator(active_unit: Dictionary, cell: Vector2i, detonator_index: int) -> void:
	is_animating = true
	active_unit.action_points = max(0, int(active_unit.action_points) - 1)
	pending_skill_id = ""
	selected_obstacle_cell = Vector2i(-1, -1)
	_log_event("%s aktywuje detonator." % _unit_name_log_text(active_unit))
	_show_screen_message("Detonator aktywowany!", 2.0)

	var target_cells: Array[Vector2i] = []
	var stored_targets: Variant = obstacles[detonator_index].get("target_cells", [])
	if stored_targets is Array:
		for stored in stored_targets:
			if stored is Vector2i:
				target_cells.append(stored)
	else:
		target_cells = _random_detonator_target_cells(cell)
	board.set_detonator_warning_cells(target_cells)
	_sync_board()
	await get_tree().create_timer(0.8).timeout

	board.play_falling_rocks_animation(target_cells)
	await get_tree().create_timer(0.55).timeout

	var hit_names: Array[String] = []
	for target_cell in target_cells:
		var target := _find_unit_at_cell(target_cell)
		if target.is_empty():
			continue
		var total_damage: int = _calculate_damage(active_unit, target, 1.5)
		var result := _apply_attack_damage(active_unit, target, total_damage, false, false)
		var hit_target: Dictionary = result.get("target", target)
		hit_names.append("%s (%s/%s)" % [_unit_name_log_text(hit_target), result.get("damage", total_damage), result.get("casualties", 0)])
		if int(hit_target.get("count", 0)) <= 0:
			_show_screen_message("%s zostaje zmiazdzony przez kamienie!" % str(hit_target.get("name", "Jednostka")), 2.5)
		_cleanup_destroyed_unit(hit_target)

	obstacles.remove_at(detonator_index)
	detonator_activated = true
	board.set_detonator_warning_cells([])
	board.clear_falling_rock_cells()
	_log_event(
		"%s wybucha: %s." % [
			_unit_name_log_text(active_unit),
			"brak trafien" if hit_names.is_empty() else ", ".join(hit_names)
		]
	)
	_show_screen_message("Detonator wybucha!", 2.0)
	_sync_board()
	is_animating = false


func _random_detonator_target_cells(excluded_cell: Vector2i) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	for column in GRID_COLUMNS:
		for row in GRID_ROWS:
			var cell := Vector2i(column, row)
			if cell == excluded_cell:
				continue
			candidates.append(cell)
	candidates.shuffle()
	var count: int = mini(4, candidates.size())
	var result: Array[Vector2i] = []
	for index in count:
		result.append(candidates[index])
	return result


func _try_ice_break_death(unit: Dictionary, cell: Vector2i) -> void:
	if randi() % 100 >= 10:
		return
	_log_event(_color_log_text("%s zapada sie pod lod i ginie!" % _unit_name_log_text(unit), LOG_COLOR_DAMAGE))
	unit["count"] = 0
	unit["current_total_hp"] = 0
	unit["current_hp"] = 0
	_cleanup_destroyed_unit(unit)


func _is_water_cell(cell: Vector2i) -> bool:
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y:
			return str(obstacle.get("type", "")) == "woda"
	return false


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


func _try_trigger_map_event() -> void:
	if next_map_event_round == 0 or round_number < next_map_event_round:
		return
	if next_map_event_id == "brak_eventu":
		_log_event(_color_log_text("Runda mija bez eventu mapy.", LOG_COLOR_YELLOW), false)
		_schedule_next_map_event(round_number)
		_sync_board()
		return
	match next_map_event_id:
		"gniew_korzeni":
			_event_forest_roots()
		"przebudzenie_gaju":
			_event_forest_awakening()
		"lesne_opary":
			_event_global_range("Lesne Opary")
		"magiczny_rozkwit":
			_event_magic_bloom()
		"spadajacy_rumosz":
			_event_falling_rubble()
		"wybuch_gazu":
			_event_random_terrain("poison_cloud", 3, 2)
		"pekniecie_chodnika":
			_event_random_obstacles("woda", "water", 3, "Pekniecie Chodnika zalewa trzy pola.")
		"zawal_kopalni":
			_event_random_obstacles("kamienie", "rock1", 2, "Zawal Kopalni blokuje dwa pola.")
		"rozprzestrzeniajacy_sie_pozar":
			_event_spreading_fire()
		"gesty_dym":
			_event_global_range("Gesty Dym")
		"przerwanie_grobli":
			_event_random_obstacles("woda", "water", 3, "Przerwanie Grobli zalewa trzy pola.")
		"plonace_zabudowania":
			_event_damage_on_marked_cells("Plonace Zabudowania")
		"wichura_lodowa":
			_event_global_slow("wichura_lodowa", "Wichura Lodowa")
		"sniezna_zamiec":
			_event_global_range("Sniezna Zamiec")
		"oblodzenie":
			_event_random_terrain("ice", 3, 2)
		"lawina":
			_event_damage_on_marked_cells("Lawina")
		"burza_piaskowa":
			_event_global_range("Burza Piaskowa")
		"zapadlisko":
			_event_random_obstacles("ruchome_piaski", "quicksand", 3, "Zapadlisko tworzy trzy pola ruchomych piaskow.")
		"palacy_skwar":
			_event_damage_on_marked_cells("Palacy Skwar")
		"pustynny_podmuch":
			_event_global_slow("pustynny_podmuch", "Pustynny Podmuch")
		_:
			return
	map_event_cells.clear()
	_schedule_next_map_event(round_number)
	_sync_board()


func _schedule_next_map_event(after_round: int) -> void:
	var scenario_id: String = current_battle_background_path.get_file().get_basename()
	var raw_pool: Array = MAP_EVENT_POOLS.get(scenario_id, [])
	var pool: Array = raw_pool.filter(func(event_id: String) -> bool: return _event_can_be_scheduled(event_id))
	if pool.is_empty():
		next_map_event_round = 0
		next_map_event_id = ""
	else:
		if randi_range(1, 100) <= 25:
			next_map_event_id = "brak_eventu"
		else:
			var previous_event_id: String = next_map_event_id
			var choices: Array = pool.filter(func(event_id: String) -> bool: return event_id != previous_event_id)
			next_map_event_id = str(choices.pick_random() if not choices.is_empty() else pool.pick_random())
		next_map_event_round = after_round + randi_range(2, 4)
	map_event_cells.clear()
	_prepare_map_event_warning()


func _map_event_name() -> String:
	return str(MAP_EVENT_DATA.get(next_map_event_id, {}).get("name", ""))


func _event_can_be_scheduled(event_id: String) -> bool:
	var obstacle_type: String = _event_obstacle_type(event_id)
	return obstacle_type == "" or _available_event_obstacle_slots(obstacle_type) > 0


func _event_obstacle_type(event_id: String) -> String:
	return str({
		"przebudzenie_gaju": "krzok",
		"pekniecie_chodnika": "woda",
		"zawal_kopalni": "kamienie",
		"przerwanie_grobli": "woda",
		"zapadlisko": "ruchome_piaski",
	}.get(event_id, ""))


func _available_event_obstacle_slots(type_id: String) -> int:
	var used: int = 0
	for obstacle in obstacles:
		if str(obstacle.get("type", "")) == type_id and str(obstacle.get("source", "")) == "map_event":
			used += 1
	return maxi(0, int(MAX_EVENT_OBSTACLES.get(type_id, 0)) - used)


func _event_forest_roots() -> void:
	for unit in units:
		if not map_event_cells.has(Vector2i(int(unit.grid_x), int(unit.grid_y))):
			continue
		_apply_or_refresh_effect(unit, {
			"id": "gniew_korzeni",
			"name": "Gniew Korzeni",
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [{"stat": "move_range", "mode": "set", "value": 0}]
		})
	_log_event(_color_log_text("EVENT MAPY: Gniew Korzeni unieruchamia jednostki na oznaczonych polach.", LOG_COLOR_YELLOW))


func _event_falling_rubble() -> void:
	_damage_units_on_event_cells("Spadajacy Rumosz")
	_log_event(_color_log_text("EVENT MAPY: Wstrzas narusza strop kopalni.", LOG_COLOR_YELLOW))


func _event_spreading_fire() -> void:
	for cell in map_event_cells:
		_add_terrain_effect(cell, "fire", 2)
	_apply_terrain_effects_in_cells(map_event_cells)
	_log_event(_color_log_text("EVENT MAPY: Pozar rozprzestrzenia sie na trzy pola.", LOG_COLOR_YELLOW))


func _event_global_slow(event_id: String, event_name: String) -> void:
	for unit in units:
		_apply_or_refresh_effect(unit, {
			"id": event_id,
			"name": event_name,
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [
				{"stat": "speed", "mode": "flat", "value": -2},
				{"stat": "move_range", "mode": "flat", "value": -2}
			]
		})
	_log_event(_color_log_text("EVENT MAPY: %s spowalnia wszystkie jednostki." % event_name, LOG_COLOR_YELLOW))


func _event_forest_awakening() -> void:
	_event_random_obstacles("krzok", "krzok", 3, "Przebudzenie Gaju tworzy trzy nowe krzaki.")


func _event_global_range(event_name: String) -> void:
	for unit in units:
		_apply_or_refresh_effect(unit, {
			"id": event_name.to_snake_case(),
			"name": event_name,
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [{"stat": "attack_range", "mode": "flat", "value": -1}]
		})
	_log_event(_color_log_text("EVENT MAPY: %s zmniejsza zasieg ataku wszystkich jednostek o 1." % event_name, LOG_COLOR_YELLOW))


func _event_magic_bloom() -> void:
	for target in units:
		if not map_event_cells.has(Vector2i(int(target.grid_x), int(target.grid_y))):
			continue
		var healing: int = int(target.get("base_hp", 1))
		target["current_total_hp"] = mini(int(target.get("max_total_hp", healing)), int(target.get("current_total_hp", 0)) + healing)
		_refresh_unit_health_state(target)
		_log_event("%s odzyskuje %s HP dzieki Magicznemu Rozkwitowi." % [_unit_name_log_text(target), healing])
	_log_event(_color_log_text("EVENT MAPY: Magiczny Rozkwit leczy jednostki na oznaczonych polach.", LOG_COLOR_YELLOW))


func _event_random_terrain(effect_id: String, count: int, turns: int) -> void:
	for cell in map_event_cells:
		_add_terrain_effect(cell, effect_id, turns, -1, 1 if effect_id == "poison_cloud" else 0)
	_apply_terrain_effects_in_cells(map_event_cells)
	_log_event(_color_log_text("EVENT MAPY: %s pojawia sie na %d polach." % [_map_event_name(), map_event_cells.size()], LOG_COLOR_YELLOW))


func _event_random_obstacles(type_id: String, variant: String, count: int, message: String) -> void:
	var placed := 0
	var available: int = mini(count, _available_event_obstacle_slots(type_id))
	for cell in map_event_cells:
		if placed >= available:
			break
		if type_id == "kamienie":
			var target: Dictionary = _find_unit_at_cell(cell)
			if not target.is_empty():
				var damage: int = _calculate_tick_damage(target, 1)
				_apply_damage_to_unit(target, damage)
				_cleanup_destroyed_unit(target)
				if not _find_unit_at_cell(cell).is_empty():
					continue
		obstacles.append({"grid_x": cell.x, "grid_y": cell.y, "type": type_id, "variant": variant, "source": "map_event"})
		placed += 1
	for unit in units:
		if map_event_cells.has(Vector2i(int(unit.grid_x), int(unit.grid_y))):
			_apply_terrain_entry_effect(unit)
	_log_event(_color_log_text("EVENT MAPY: %s" % message, LOG_COLOR_YELLOW))


func _event_damage_on_marked_cells(event_name: String) -> void:
	_damage_units_on_event_cells(event_name)
	_log_event(_color_log_text("EVENT MAPY: %s uderza w oznaczone pola." % event_name, LOG_COLOR_YELLOW))


func _damage_units_on_event_cells(event_name: String) -> void:
	for target in units.duplicate():
		if not map_event_cells.has(Vector2i(int(target.grid_x), int(target.grid_y))):
			continue
		var damage: int = _calculate_tick_damage(target, 1)
		_apply_damage_to_unit(target, damage)
		_log_event("%s otrzymuje %s obrazen przez %s." % [_unit_name_log_text(target), _color_log_text(str(damage), LOG_COLOR_DAMAGE), event_name])
		_cleanup_destroyed_unit(target)


func _random_map_event_cells(count: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for column in range(GRID_COLUMNS):
		for row in range(GRID_ROWS):
			var cell := Vector2i(column, row)
			if _get_terrain_at(cell).is_empty():
				cells.append(cell)
	cells.shuffle()
	cells.resize(mini(count, cells.size()))
	return cells


func _prepare_map_event_warning() -> void:
	if not _is_map_event_warning_round(round_number, next_map_event_round) or not map_event_cells.is_empty():
		return
	var cell_count: int = int({
		"gniew_korzeni": 3,
		"przebudzenie_gaju": 3,
		"magiczny_rozkwit": 3,
		"spadajacy_rumosz": 3,
		"wybuch_gazu": 3,
		"pekniecie_chodnika": 3,
		"zawal_kopalni": 2,
		"rozprzestrzeniajacy_sie_pozar": 3,
		"przerwanie_grobli": 3,
		"plonace_zabudowania": 3,
		"oblodzenie": 3,
		"lawina": 4,
		"zapadlisko": 3,
		"palacy_skwar": 3,
	}.get(next_map_event_id, 0))
	if ["wybuch_gazu", "rozprzestrzeniajacy_sie_pozar", "oblodzenie"].has(next_map_event_id):
		cell_count = randi_range(5, 8)
	var obstacle_type: String = _event_obstacle_type(next_map_event_id)
	if obstacle_type != "":
		cell_count = mini(cell_count, _available_event_obstacle_slots(obstacle_type))
	if cell_count == 0:
		return
	map_event_cells = _random_map_event_cells(cell_count)
	_log_event(_color_log_text("OSTRZEZENIE: %s uderzy w oznaczone pola w rundzie %d." % [_map_event_name(), next_map_event_round], LOG_COLOR_YELLOW), false)


func _is_map_event_warning_round(current_round_number: int, event_round: int) -> bool:
	return event_round >= 2 and current_round_number == event_round - 1


func _can_use_skill(unit: Dictionary, skill_id: String) -> bool:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return false
	if not _has_skill_id(unit, skill_id):
		return false
	if str(skill.get("target_type", "")) == "passive":
		return false
	if int(unit.get("action_points", 0)) < int(skill.get("ap_cost", 0)):
		return false
	return int(unit.get("skill_cooldowns", {}).get(skill_id, 0)) == 0


func _apply_or_refresh_effect(unit: Dictionary, effect_data: Dictionary) -> void:
	var effect_id: String = str(effect_data.get("id", ""))
	if effect_id != "":
		effect_data = UnitTypeLibrary.build_active_effect(effect_id, effect_data)
	var effects: Array = unit.get("active_effects", [])
	var previous_move_range: int = int(unit.get("move_range", 0))
	for existing in effects:
		if str(existing.get("id", "")) != str(effect_data.get("id", "")):
			continue
		if effect_data.has("remaining_turns"):
			existing["remaining_turns"] = int(effect_data.get("remaining_turns", 0))
		if effect_data.has("stack_amount"):
			existing["stack_amount"] = int(effect_data.get("stack_amount", 1))
		existing["stat_changes"] = effect_data.get("stat_changes", [])
		if effect_data.has("tick_damage"):
			existing["tick_damage"] = int(effect_data.get("tick_damage", 0))
		if effect_data.has("forced_target_id"):
			existing["forced_target_id"] = int(effect_data.get("forced_target_id", -1))
		if effect_data.has("guarded_by_id"):
			existing["guarded_by_id"] = int(effect_data.get("guarded_by_id", -1))
		if effect_data.has("block_next_attack"):
			existing["block_next_attack"] = bool(effect_data.get("block_next_attack", false))
		if effect_data.has("forward_only"):
			existing["forward_only"] = bool(effect_data.get("forward_only", false))
		if effect_data.has("permanent"):
			existing["permanent"] = bool(effect_data.get("permanent", false))
		if effect_data.has("terrain_bound"):
			existing["terrain_bound"] = bool(effect_data.get("terrain_bound", false))
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
	_remove_effect(unit, "woda")
	_apply_elf_statue_buff(unit)
	_refresh_terrain_bound_effects(unit)
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
		if bool(effect.get("permanent", false)) or bool(effect.get("terrain_bound", false)):
			kept_effects.append(effect)
			continue
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


func _find_path(unit: Dictionary, start: Vector2i, goal: Vector2i, charge_skill: Dictionary = {}) -> Array[Vector2i]:
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
			if not _is_forward_step(unit, current, neighbor, charge_skill):
				continue
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


func _get_pull_destination(source: Dictionary, target: Dictionary) -> Vector2i:
	var source_cell := Vector2i(source.grid_x, source.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _hex_distance(source_cell, target_cell) <= 1:
		return Vector2i(-1, -1)
	var pull_line: Array[Vector2i] = _get_hex_line(target_cell, source_cell)
	if pull_line.size() < 2:
		return Vector2i(-1, -1)
	var destination: Vector2i = pull_line[pull_line.size() - 2]
	if destination.x < 0 or destination.x >= GRID_COLUMNS or destination.y < 0 or destination.y >= GRID_ROWS:
		return Vector2i(-1, -1)
	if _is_cell_obstacle(destination):
		return Vector2i(-1, -1)
	if not _find_unit_at_cell(destination).is_empty():
		return Vector2i(-1, -1)
	return destination


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


func _is_immobilized(unit: Dictionary) -> bool:
	return _has_effect(unit, "immobilize")


func _remove_effect(unit: Dictionary, effect_id: String) -> void:
	var kept_effects: Array = []
	var removed := false
	for effect in unit.get("active_effects", []):
		if str(effect.get("id", "")) == effect_id:
			removed = true
			continue
		kept_effects.append(effect)
	if not removed:
		return
	unit["active_effects"] = kept_effects
	_recalculate_unit_stats(unit)


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
	var winter_mode: bool = _is_winter_scenario()
	var desert_mode: bool = _is_desert_scenario()
	var forest_mode: bool = _is_forest_scenario()
	var mine_mode: bool = _is_mine_scenario()
	var obstacle_types: Array[String]
	if desert_mode:
		obstacle_types = DESERT_OBSTACLE_TYPES
	elif winter_mode:
		obstacle_types = WINTER_OBSTACLE_TYPES
	elif forest_mode:
		obstacle_types = FOREST_OBSTACLE_TYPES
	elif mine_mode:
		obstacle_types = MINE_OBSTACLE_TYPES
	else:
		obstacle_types = OBSTACLE_TYPES
	var generated: Array[Dictionary] = ObstacleGeneratorScript.generate(units, obstacle_types, GRID_COLUMNS, GRID_ROWS, SETUP_COLUMNS, winter_mode)
	if desert_mode:
		for obstacle in generated:
			if str(obstacle.get("type", "")) == "kamienie":
				obstacle["variant"] = "dune"
	return generated


func _is_mine_scenario() -> bool:
	return current_battle_background_path.get_file().get_basename() == "dwarves_vs_goblins_mine"


func _is_forest_scenario() -> bool:
	return current_battle_background_path.get_file().get_basename() == "orcs_vs_elves_forest"


func _is_winter_scenario() -> bool:
	return current_battle_background_path.get_file().get_basename() == "elves_vs_dwarves_pass"


func _is_desert_scenario() -> bool:
	return current_battle_background_path.get_file().get_basename() == "humans_vs_goblins_desert"


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
		if _terrain_skips_turn(cell) or _has_trap_at(cell):
			break
	return result


func _has_trap_at(cell: Vector2i) -> bool:
	return not _get_terrain_effect_at(cell, "bear_trap").is_empty() or not _get_terrain_effect_at(cell, "goblin_trap").is_empty()


func _get_terrain_entry_effect(cell: Vector2i) -> Dictionary:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return {}
	var raw_entry: Variant = terrain.get("entry_effect", null)
	if raw_entry == null:
		return {}
	var effect_id: String = ""
	var overrides: Dictionary = {}
	if typeof(raw_entry) == TYPE_STRING:
		effect_id = str(raw_entry)
	elif typeof(raw_entry) == TYPE_DICTIONARY:
		var raw_dict: Dictionary = raw_entry
		effect_id = str(raw_dict.get("id", raw_dict.get("effect_id", "")))
		overrides = raw_dict.duplicate(true)
		overrides.erase("id")
		overrides.erase("effect_id")
	else:
		return {}
	if effect_id.is_empty():
		return {}
	var effect: Dictionary = UnitTypeLibrary.build_active_effect(effect_id, overrides)
	if effect.is_empty():
		push_warning("Brak efektu terenu '%s' w status_effects.json" % effect_id)
	return effect


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
	if not _is_cell_obstacle(cell):
		return false
	var terrain_id: String = str(_get_terrain_at(cell).get("id", ""))
	var passable_types: Array[String] = ["krzok", "zimowy_krzak", "holy_tree", "cart", "detonator", "hole"]
	return not passable_types.has(terrain_id)


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
	return HexUtilsScript.line(start, end)


func _cube_to_oddr(cube: Vector3i) -> Vector2i:
	return HexUtilsScript.cube_to_oddr(cube)


func _get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	return HexUtilsScript.neighbors(cell, GRID_COLUMNS, GRID_ROWS)


func _build_help_popup() -> void:
	help_popup = PanelContainer.new()
	help_popup.visible = false
	help_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	help_popup.custom_minimum_size = Vector2(640, 520)
	help_popup.set_anchors_preset(Control.PRESET_CENTER)
	help_popup.offset_left = -320
	help_popup.offset_top = -260
	help_popup.offset_right = 320
	help_popup.offset_bottom = 260
	hud.add_child(help_popup)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	help_popup.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var title := Label.new()
	title.text = "JAK GRAĆ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.86, 0.72, 0.34, 1.0))
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Przewodnik po sterowaniu, rozgrywce i interfejsie"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.75, 0.72, 0.62, 1.0))
	column.add_child(subtitle)

	var separator := TextureRect.new()
	separator.texture = preload("res://assets/ui/divider.png")
	separator.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	separator.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	separator.stretch_mode = TextureRect.STRETCH_SCALE
	separator.custom_minimum_size = Vector2(0, 2)
	separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(separator)

	help_popup_scroll = ScrollContainer.new()
	help_popup_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	help_popup_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	help_popup_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	column.add_child(help_popup_scroll)

	help_popup_content = VBoxContainer.new()
	help_popup_content.add_theme_constant_override("separation", 10)
	help_popup_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_popup_content.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	help_popup_scroll.add_child(help_popup_content)

	var nav_row := HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 12)
	nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(nav_row)

	help_popup_prev_button = Button.new()
	help_popup_prev_button.text = "< WSTECZ"
	help_popup_prev_button.custom_minimum_size = Vector2(110, 40)
	help_popup_prev_button.pressed.connect(_on_help_prev_pressed)
	nav_row.add_child(help_popup_prev_button)

	help_popup_page_label = Label.new()
	help_popup_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_popup_page_label.custom_minimum_size = Vector2(80, 0)
	help_popup_page_label.add_theme_color_override("font_color", Color(0.86, 0.72, 0.34, 1.0))
	help_popup_page_label.add_theme_font_size_override("font_size", 14)
	nav_row.add_child(help_popup_page_label)

	help_popup_next_button = Button.new()
	help_popup_next_button.text = "DALEJ >"
	help_popup_next_button.custom_minimum_size = Vector2(110, 40)
	help_popup_next_button.pressed.connect(_on_help_next_pressed)
	nav_row.add_child(help_popup_next_button)

	help_popup_action_button = Button.new()
	help_popup_action_button.text = "ROZPOCZNIJ"
	help_popup_action_button.custom_minimum_size = Vector2(220, 48)
	help_popup_action_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	help_popup_action_button.add_theme_font_size_override("font_size", 18)
	help_popup_action_button.pressed.connect(_on_help_action_pressed)
	column.add_child(help_popup_action_button)

	_help_rebuild_content()


func _make_help_section(title: String, lines: Array[String], expanded := true) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 6)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var header_button := Button.new()
	header_button.text = title
	header_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header_button.custom_minimum_size = Vector2(0, 38)
	header_button.add_theme_font_size_override("font_size", 16)
	header_button.add_theme_color_override("font_color", Color(0.86, 0.72, 0.34, 1.0))
	section.add_child(header_button)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.visible = expanded
	section.add_child(body)

	for line in lines:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = line
		label.add_theme_font_size_override("font_size", 14)
		body.add_child(label)

	header_button.pressed.connect(func() -> void:
		body.visible = not body.visible
	)
	return section


func _help_rebuild_content() -> void:
	if help_popup_content == null:
		return
	for child in help_popup_content.get_children():
		child.queue_free()

	if help_mode_tutorial:
		_build_tutorial_pages()
	else:
		_build_controls_reference()


func _build_tutorial_pages() -> void:
	var page_0: Array[String] = [
		"Witaj w prototypie turowego systemu walki!",
		"",
		"Twoim celem jest pokonanie wszystkich wrogich jednostek na heksagonalnej planszy.",
		"Przed bitwą wybierasz frakcję i rozstawiasz swoje jednostki.",
		"Po kliknięciu START rozpoczyna się walka oparta na inicjatywie.",
	]
	var page_1: Array[String] = [
		"Rozstaw swoje jednostki w trzech skrajnych kolumnach po swojej stronie planszy.",
		"",
		"Wybierz jednostkę LPM, a następnie kliknij podświetlone pole, aby się przemieścić.",
		"PPM wykonuje podstawowy atak w zasięgu aktywnej jednostki.",
		"Każda jednostka ma ograniczone Punkty Akcji (PA) i Zasięg Ruchu na turę.",
	]
	var page_2: Array[String] = [
		"Karta aktywnej jednostki wyświetla się w lewym panelu — znajdziesz tam statystyki, buffy i debuffy.",
		"",
		"Dolny panel pokazuje umiejętności specjalne jednostki.",
		"Prawy panel to generał, jego umiejętności oraz log bitwy.",
		"Górna belka to kolejka inicjatywy — kolejność aktywacji jednostek.",
	]
	var page_3: Array[String] = [
		"Teren ma znaczenie:",
		"• Woda — wejście zużywa cały pozostały ruch i pomija turę.",
		"• Kamienie — blokują ruch i linię strzału.",
		"• Krzaki — jednostka w krzaku jest niewidzialna dla wrogów poza sąsiednim krzakiem.",
		"",
		"Statusy i odporności jednostek wpływają na obrażenia oraz zachowanie w walce.",
	]
	var page_4: Array[String] = [
		"Generał może raz na bitwę użyć jednej z dwóch globalnych umiejętności.",
		"",
		"Kliknij ZAKOŃCZ TURĘ, gdy skończysz działać aktywną jednostką.",
		"Bitwę wygrywa strona, która jako pierwsza zniszczy wszystkie wrogie jednostki.",
		"",
		"Naciśnij Tab w dowolnym momencie, aby otworzyć pełną pomoc.",
	]
	var pages: Array = [page_0, page_1, page_2, page_3, page_4]

	var page_index := clampi(tutorial_page, 0, pages.size() - 1)
	var raw_page: Array = pages[page_index]
	var page_lines: Array[String] = []
	page_lines.assign(raw_page)

	for line in page_lines:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = line
		label.add_theme_font_size_override("font_size", 15)
		help_popup_content.add_child(label)

	help_popup_page_label.text = "STRONA %d / %d" % [page_index + 1, pages.size()]
	help_popup_prev_button.disabled = page_index == 0
	help_popup_next_button.disabled = page_index == pages.size() - 1
	help_popup_action_button.text = "ROZPOCZNIJ" if page_index == pages.size() - 1 else "POMIŃ"


func _build_controls_reference() -> void:
	var controls_section := _make_help_section("STEROWANIE", [
		"LPM — wybierz jednostkę, wskaż pole ruchu lub cel umiejętności.",
		"PPM — wykonaj podstawowy atak aktywną jednostką.",
		"Tab — pokaż lub ukryj tę pomoc.",
		"START — rozpocznij bitwę po rozstawieniu jednostek.",
		"RESET — wróć do ekranu wyboru frakcji.",
		"ZAKOŃCZ TURĘ — kończy turę aktywnej jednostki i przekazuje inicjatywę dalej.",
		"Umiejętności generała — dwa przyciski w prawym panelu, używalne raz na bitwę.",
	])
	help_popup_content.add_child(controls_section)

	var gameplay_section := _make_help_section("ROZGRYWKA", [
		"Przygotowanie — wybierz frakcję gracza i przeciwnika, rozstaw jednostki w trzech skrajnych kolumnach.",
		"Kolejka inicjatywy — górna belka pokazuje kolejność aktywacji w rundzie.",
		"Tura jednostki — każda jednostka ma Punkty Akcji (PA) i Zasięg Ruchu.",
		"Ruch — kliknij podświetlone pole; koszt zależy od terenu.",
		"Atak — PPM lub umiejętność; obrażenia uwzględniają DEF celu i aktywne statusy.",
		"Umiejętności — do 3 aktywnych umiejętności z cooldownem w turach.",
		"Statusy — buffy/debuffy widoczne w lewym panelu; niektóre jednostki mają odporności.",
		"Teren — woda pomija turę, kamienie blokują ruch i linię strzału, krzaki ukrywają jednostkę.",
		"Generał — globalne umiejętności wpływające na przebieg bitwy.",
		"Zwycięstwo — zniszcz wszystkie wrogie jednostki.",
	])
	help_popup_content.add_child(gameplay_section)

	var panels_section := _make_help_section("PANELE INTERFEJSU", [
		"Lewy panel — portret, nazwa, statystyki oraz aktywne buffy i debuffy wybranej jednostki.",
		"Prawy panel — generał, jego umiejętności, log bitwy i przycisk zakończenia tury.",
		"Dolny panel — karty umiejętności aktualnie aktywnej jednostki.",
		"Górna belka — kolejka inicjatywy z portretami jednostek.",
	])
	help_popup_content.add_child(panels_section)

	help_popup_page_label.text = "POMOC"
	help_popup_prev_button.disabled = true
	help_popup_next_button.disabled = true
	help_popup_action_button.text = "ZAMKNIJ"


func _on_help_prev_pressed() -> void:
	if help_mode_tutorial and tutorial_page > 0:
		tutorial_page -= 1
		_help_rebuild_content()


func _on_help_next_pressed() -> void:
	if help_mode_tutorial:
		tutorial_page += 1
		_help_rebuild_content()


func _on_help_action_pressed() -> void:
	if help_mode_tutorial:
		_on_tutorial_ok_pressed()
		return
	if help_popup != null:
		help_popup.visible = false


func _on_tutorial_ok_pressed() -> void:
	tutorial_acknowledged = true
	if help_popup != null:
		help_popup.visible = false
	_update_setup_hint_visibility()


func _build_victory_overlay() -> void:
	victory_overlay = ColorRect.new()
	victory_overlay.visible = false
	victory_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	victory_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	victory_overlay.color = Color(0.02, 0.02, 0.04, 0.78)
	hud.add_child(victory_overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 0)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -230
	panel.offset_top = -120
	panel.offset_right = 230
	panel.offset_bottom = 120
	victory_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	victory_title_label = Label.new()
	victory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_title_label.add_theme_font_size_override("font_size", 30)
	column.add_child(victory_title_label)

	var finish_button := Button.new()
	finish_button.text = "ZAKOŃCZ"
	finish_button.custom_minimum_size = Vector2(220, 52)
	finish_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	finish_button.add_theme_font_size_override("font_size", 22)
	finish_button.pressed.connect(_on_victory_finish_pressed)
	column.add_child(finish_button)


func _show_victory_overlay(winner_side: String) -> void:
	if victory_overlay == null:
		return
	var winner_name := "GRACZ" if winner_side == "player" else "PRZECIWNIK"
	victory_title_label.text = "ZWYCIĘSTWO: %s" % winner_name
	victory_overlay.visible = true


func _build_screen_message_label() -> void:
	screen_message_label = Label.new()
	screen_message_label.visible = false
	screen_message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	screen_message_label.offset_top = 90
	screen_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	screen_message_label.add_theme_font_size_override("font_size", 34)
	screen_message_label.add_theme_color_override("font_color", Color(0.95, 0.18, 0.18, 1.0))
	screen_message_label.add_theme_color_override("font_outline_color", Color(0.08, 0.02, 0.02, 1.0))
	screen_message_label.add_theme_constant_override("outline_size", 6)
	hud.add_child(screen_message_label)


func _show_screen_message(text: String, duration := 2.5) -> void:
	if screen_message_label == null:
		return
	screen_message_label.text = text
	screen_message_label.visible = true
	screen_message_label.modulate = Color.WHITE
	if screen_message_tween != null and screen_message_tween.is_valid():
		screen_message_tween.kill()
	screen_message_tween = create_tween()
	screen_message_tween.tween_interval(duration)
	screen_message_tween.tween_property(screen_message_label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.35)
	screen_message_tween.finished.connect(func() -> void:
		screen_message_label.visible = false
	)


func _on_victory_finish_pressed() -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	setup_mode = true
	current_player_faction = ""
	current_enemy_faction = ""
	free_setup_mode = false
	_set_battle_background(DEFAULT_BATTLE_BACKGROUND_PATH)
	selected_unit_id = -1
	setup_drag_unit_id = -1
	active_unit_id = -1
	current_turn = ""
	pending_skill_id = ""
	selected_obstacle_cell = Vector2i(-1, -1)
	is_animating = false
	turn_queue_index = -1
	turn_queue.clear()
	event_log.clear()
	unit_configs.clear()
	units.clear()
	obstacles.clear()
	terrain_effects.clear()
	_clear_selected_unit()
	_show_team_setup()


func _toggle_help_popup() -> void:
	if help_popup == null or hud == null or not hud.visible:
		return
	var will_show := not help_popup.visible
	help_popup.visible = will_show
	if will_show:
		help_mode_tutorial = false
		tutorial_page = 0
		_help_rebuild_content()


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
	var test_line: Array[Vector2i] = _get_hex_line(Vector2i(0, 0), Vector2i(3, 0))
	assert(test_line.size() == 4 and test_line.front() == Vector2i(0, 0) and test_line.back() == Vector2i(3, 0), "Linia heksow musi zawierac oba konce.")
	for obstacle in obstacles:
		assert(int(obstacle.grid_x) >= SETUP_COLUMNS and int(obstacle.grid_x) < GRID_COLUMNS - SETUP_COLUMNS, "Przeszkoda poza dozwolonymi kolumnami.")
		assert(int(obstacle.grid_y) >= 0 and int(obstacle.grid_y) < GRID_ROWS, "Przeszkoda poza plansza.")
	if not free_setup_mode and current_player_faction != "testowa":
		assert(_is_setup_cell_allowed_for_side("player", Vector2i(SETUP_COLUMNS - 1, 0)))
		assert(not _is_setup_cell_allowed_for_side("player", Vector2i(SETUP_COLUMNS, 0)))
	if not free_setup_mode and current_enemy_faction != "testowa":
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
	assert(_adjust_incoming_damage({"active_effects": [{"incoming_damage_percent": 50}]}, 4) == 6, "Klątwa powinna zwiekszac otrzymywane obrazenia o 50%.")
	for terrain_id in terrain_types.keys():
		var raw_entry: Variant = terrain_types[terrain_id].get("entry_effect", null)
		if raw_entry == null:
			continue
		var effect_id: String = str(raw_entry) if typeof(raw_entry) == TYPE_STRING else str((raw_entry as Dictionary).get("id", ""))
		var resolved: Dictionary = UnitTypeLibraryScript.build_active_effect(effect_id, {})
		assert(not resolved.is_empty() and str(resolved.get("category", "")) != "", "Efekt terenu musi byc w status_effects: %s" % effect_id)
	assert(next_map_event_round == 0 or next_map_event_round >= 2, "Event mapy nie moze wystapic przed druga runda.")
	assert(_is_map_event_warning_round(2, 3) and not _is_map_event_warning_round(1, 3), "Pola eventu maja byc widoczne tylko runde przed jego aktywacja.")
	for scenario_id in MAP_EVENT_POOLS:
		var event_pool: Array = MAP_EVENT_POOLS[scenario_id]
		assert(event_pool.size() == 4, "Kazdy scenariusz musi miec cztery eventy: %s" % scenario_id)
		for event_id in event_pool:
			assert(MAP_EVENT_DATA.has(event_id), "Brak danych eventu: %s" % event_id)
	assert(_calculate_damage({"dmg": 7, "count": 1}, {"def": 8, "count": 1}) == 1, "DEF x count broniacego odejmuje od calego ataku.")
	assert(_calculate_damage({"dmg": 12, "count": 4}, {"def": 3, "count": 7}) == 27, "Berserker x4 vs elf lucznik x7: 48 - 21 = 27.")
	assert(_calculate_damage({"dmg": 12, "count": 4}, {"def": 6, "count": 4}) == 24, "Berserker x4 vs def 6 x4: 48 - 24 = 24.")
	assert(_calculate_damage({"dmg": 10, "count": 1}, {"def": -4, "count": 1}) > _calculate_damage({"dmg": 10, "count": 1}, {"def": 0, "count": 1}), "Ujemna DEF powinna zwiekszac otrzymywane obrazenia.")
	for faction_id in UnitTypeLibraryScript.get_faction_ids():
		for type_data in UnitTypeLibraryScript.get_faction_units(faction_id):
			assert(int(type_data.action_points) == 1, "Jednostki prototypu powinny miec 1 AP: %s" % str(type_data.id))
			assert(int(type_data.speed) <= 10 and int(type_data.move_range) <= 6 and int(type_data.attack_range) <= 5, "Jednostka poza zakresem raw statystyk: %s" % str(type_data.id))
			assert(int(type_data.hp) <= 32 and int(type_data.dmg) <= 12 and int(type_data.def) <= 12 and int(type_data.count) <= 14, "Jednostka poza zakresem raw statystyk: %s" % str(type_data.id))
	assert(not _can_use_skill({"action_points": 1, "skill_cooldowns": {}}, "bariera_energetyczna"), "Umiejetnosci bierne nie moga byc uzywane recznie.")
	assert(skill_library.has("deszcz_strzal"), "Brak skilla deszcz_strzal w bibliotece.")
	assert(str(skill_library["deszcz_strzal"].get("effect_type", "")) == "arrow_rain", "Deszcz Strzal musi miec efekt arrow_rain.")
	assert(skill_library.has("rozszarpanie"), "Brak skilla rozszarpanie w bibliotece.")
	assert(str(skill_library["rozszarpanie"].get("effect_type", "")) == "rozszarpanie", "Rozszarpanie musi miec efekt rozszarpanie.")
	assert(skill_library.has("zadza_krwi"), "Brak skilla zadza_krwi w bibliotece.")
	assert(str(skill_library["zadza_krwi"].get("effect_type", "")) == "zadza_krwi", "Zadza krwi musi miec efekt zadza_krwi.")
	assert(not _can_use_skill({"action_points": 1, "skill_cooldowns": {}, "skill_ids": []}, "pulapka_na_niedzwiedzie"), "Jednostka nie moze uzywac umiejetnosci spoza skill_ids.")
	var previous_units: Array = units.duplicate(true)
	var previous_obstacles: Array[Dictionary] = obstacles.duplicate(true)
	var previous_terrain_effects: Array[Dictionary] = terrain_effects.duplicate(true)
	obstacles = [
		{"grid_x": 4, "grid_y": 4, "type": "kamienie"},
		{"grid_x": 5, "grid_y": 3, "type": "krzok"},
		{"grid_x": 5, "grid_y": 4, "type": "krzok"},
		{"grid_x": 5, "grid_y": 5, "type": "krzok"}
	]
	assert(_is_cell_passable(Vector2i(5, 4)), "Jednostka musi moc wejsc w krzak.")
	assert(not _is_cell_passable(Vector2i(4, 4)), "Jednostka nie moze wejsc w kamienie.")
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
		"move_range": 3,
		"base_move_range": 3,
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
	terrain_effects = [{"id": "bear_trap", "grid_x": 3, "grid_y": 4, "remaining_turns": 99, "caster_side": "enemy"}]
	assert(_has_trap_near_cell_for_side(Vector2i(3, 5), "enemy"), "AI nie powinno dublowac pulapek przy tym samym celu.")
	var melee_ai := {
		"id": 1003,
		"name": "AI Melee",
		"side": "enemy",
		"grid_x": 7,
		"grid_y": 5,
		"attack_range": 1,
		"move_range": 3,
		"base_move_range": 3,
		"action_points": 1,
		"remaining_move": 3
	}
	var crowded_target := {
		"id": 1004,
		"name": "Crowded Target",
		"side": "player",
		"grid_x": 6,
		"grid_y": 5
	}
	var open_target := {
		"id": 1005,
		"name": "Open Target",
		"side": "player",
		"grid_x": 7,
		"grid_y": 4
	}
	units = [
		melee_ai,
		crowded_target,
		open_target,
		{"id": 1006, "side": "enemy", "grid_x": 6, "grid_y": 4},
		{"id": 1007, "side": "enemy", "grid_x": 5, "grid_y": 5}
	]
	obstacles = []
	terrain_effects = []
	assert(int(_find_nearest_player_unit(melee_ai).id) == int(open_target.id), "Melee AI powinno rozkladac cele zamiast pchac sie w ten sam tlok.")
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
	bush_unit.grid_x = first_water.x
	bush_unit.grid_y = first_water.y
	_apply_terrain_effects_to_unit(bush_unit)
	assert(not _has_effect(bush_unit, "woda"), "Woda konczy biezacy ruch, ale nie moze zostawiac debuffa na nastepna ture.")
	bush_unit.action_points = 1
	_stop_unit_on_terrain(bush_unit)
	assert(int(bush_unit.remaining_move) == 0 and int(bush_unit.action_points) == 1, "Woda konczy ruch, ale nie moze zabierac punktow akcji.")
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
	var charge_unit := bush_unit.duplicate(true)
	charge_unit.id = 1001
	charge_unit.grid_x = 2
	charge_unit.grid_y = 5
	charge_unit.remaining_move = 2
	var previous_active_unit_id: int = active_unit_id
	var previous_pending_skill_id: String = pending_skill_id
	active_unit_id = int(charge_unit.id)
	pending_skill_id = "szarza"
	var charge_skill: Dictionary = skill_library.get("szarza", {})
	var charge_move_budget: int = _get_remaining_move(charge_unit) + _get_charge_stat_bonus(charge_skill, "move_range")
	for cell in _get_reachable_cells(charge_unit, charge_move_budget, charge_skill):
		assert(cell.y == charge_unit.grid_y, "Szarza gracza moze ruszac tylko bezposrednio przed siebie.")
		assert(cell.x > charge_unit.grid_x, "Szarza gracza moze ruszac tylko w prawo.")
	assert(not _is_in_attack_range(charge_unit, Vector2i(1, 5), charge_skill), "Szarza gracza nie moze atakowac w lewo.")
	var forward_enemy := {
		"id": 1002,
		"side": "enemy",
		"grid_x": 5,
		"grid_y": 5,
		"is_hidden": false
	}
	var approach_path: Array[Vector2i] = _find_charge_approach_path(charge_unit, forward_enemy, charge_skill)
	assert(not approach_path.is_empty(), "Szarza musi ruszac na wprost wroga przed atakiem.")
	for cell in approach_path:
		assert(cell.y == charge_unit.grid_y, "Szarza musi prowadzic prosto przed siebie.")
		assert(cell.x > charge_unit.grid_x, "Szarza musi prowadzic tylko do przodu.")
	assert(_can_charge_attack_target(charge_unit, forward_enemy, charge_skill), "Szarza musi pozwalac atakowac wroga przed soba.")
	var diagonal_enemy := {
		"id": 1003,
		"side": "enemy",
		"grid_x": 4,
		"grid_y": 4,
		"is_hidden": false
	}
	assert(not _can_charge_attack_target(charge_unit, diagonal_enemy, charge_skill), "Szarza nie moze atakowac wroga z boku.")
	charge_unit.side = "enemy"
	charge_unit.grid_x = 10
	charge_unit.grid_y = 5
	for cell in _get_reachable_cells(charge_unit, charge_move_budget, charge_skill):
		assert(cell.y == charge_unit.grid_y, "Szarza wroga moze ruszac tylko bezposrednio przed siebie.")
		assert(cell.x < charge_unit.grid_x, "Szarza wroga moze ruszac tylko w lewo.")
	assert(not _is_in_attack_range(charge_unit, Vector2i(11, 5), charge_skill), "Szarza wroga nie moze atakowac w prawo.")
	active_unit_id = previous_active_unit_id
	pending_skill_id = previous_pending_skill_id
	terrain_effects = previous_terrain_effects
	units = []
	obstacles = []
	var hook_caster := {
		"id": 1101,
		"side": "player",
		"grid_x": 2,
		"grid_y": 5,
		"name": "Ork Wojownik"
	}
	var hook_target := {
		"id": 1102,
		"side": "enemy",
		"grid_x": 5,
		"grid_y": 5,
		"name": "Cel"
	}
	var pull_cell: Vector2i = _get_pull_destination(hook_caster, hook_target)
	assert(pull_cell == Vector2i(3, 5), "Rzut Hakiem musi przyciagac cel na sasiedni hex rzucajacego.")
	hook_target.grid_x = pull_cell.x
	hook_target.grid_y = pull_cell.y
	assert(_get_pull_destination(hook_caster, hook_target) == Vector2i(-1, -1), "Rzut Hakiem nie moze przyciagac celu juz stojacego obok.")
	units = previous_units
	obstacles = previous_obstacles


func _on_board_animation_finished(_unit_id: int) -> void:
	is_animating = false
	_refresh_turn_queue()


func _update_action_buttons() -> void:
	var selected_unit: Dictionary = _find_unit_by_id(selected_unit_id)
	if not selected_unit.is_empty():
		unit_abilities_panel.set_skills(_build_skill_cards(selected_unit))
	var active_unit: Dictionary = _get_active_unit()
	end_turn_button.text = "START" if setup_mode else "ZAKOŃCZ TURĘ"
	end_turn_button.disabled = is_animating or (not setup_mode and (not _is_manual_turn() or active_unit.is_empty() or not _is_manual_side(str(active_unit.side))))
	_refresh_general_ability_buttons()


func _on_end_turn_button_pressed() -> void:
	if setup_mode:
		_on_start_battle_pressed()
		return
	if setup_mode or is_animating or not _is_manual_turn():
		return
	var active_unit: Dictionary = _get_active_unit()
	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)):
		return
	_end_current_activation()


func _color_log_text(text: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(false), text]


func _unit_name_log_text(unit: Dictionary) -> String:
	var color: Color = LOG_COLOR_PLAYER if unit.side == "player" else LOG_COLOR_ENEMY
	return _color_log_text(unit.name, color)


func _log_event(text: String, counts_for_turn := true) -> void:
	if active_unit_id != -1 and counts_for_turn and text.strip_edges() != "":
		active_turn_has_log = true
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
	var event_insert_index: int = visible_queue.size()
	if _has_visible_map_event() and next_map_event_round == round_number + 1:
		event_insert_index = mini(turn_queue.size() - maxi(turn_queue_index, 0), visible_queue.size())
	for index in range(visible_queue.size() + 1):
		if index == event_insert_index and _has_visible_map_event():
			turn_queue_list.add_child(_create_map_event_queue_card())
		if index >= visible_queue.size():
			continue
		var unit_id: int = visible_queue[index]
		var unit := _find_unit_by_id(unit_id)
		if unit.is_empty():
			continue
		turn_queue_list.add_child(_create_turn_queue_card(unit))

	_update_top_bar_width(visible_queue.size() + (1 if _has_visible_map_event() else 0))


func _has_visible_map_event() -> bool:
	return next_map_event_round > 0 and next_map_event_id != "" and next_map_event_id != "brak_eventu"


func _create_turn_queue_card(unit: Dictionary) -> Button:
	return TurnQueueCardScript.create(
		unit,
		selected_unit_id,
		active_unit_id,
		is_animating,
		_load_unit_portrait(unit),
		TURN_QUEUE_PLACEHOLDER_PORTRAIT,
		_on_turn_queue_pressed,
		_on_turn_queue_gui_input
	)


func _create_map_event_queue_card() -> Button:
	var event_data: Dictionary = MAP_EVENT_DATA.get(next_map_event_id, {})
	var event_unit: Dictionary = {
		"id": -100000,
		"name": "R%d: %s" % [next_map_event_round, _map_event_name()],
		"side": "event"
	}
	var card: Button = TurnQueueCardScript.create(
		event_unit,
		-100000,
		-1,
		false,
		event_data.get("icon", TURN_QUEUE_PLACEHOLDER_PORTRAIT),
		TURN_QUEUE_PLACEHOLDER_PORTRAIT,
		_on_turn_queue_pressed,
		_on_turn_queue_gui_input
	)
	card.tooltip_text = "Event mapy nastapi w rundzie %d." % next_map_event_round
	return card


func _update_top_bar_width(card_count: int) -> void:
	if top_bar == null or turn_queue_list == null:
		return
	if card_count <= 0:
		return
	var card_width := int(TurnQueueCardScript.CARD_SIZE.x)
	var card_height := int(TurnQueueCardScript.CARD_SIZE.y)
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


func _on_turn_queue_gui_input(event: InputEvent, unit_id: int) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event: InputEventMouseButton = event
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.double_click:
		return
	if unit_id == -100000:
		var event_data: Dictionary = MAP_EVENT_DATA.get(next_map_event_id, {})
		unit_details_popup.show_map_object(
			str(event_data.get("name", "Event mapy")),
			str(event_data.get("description", "Brak opisu eventu.")),
			event_data.get("icon", TURN_QUEUE_PLACEHOLDER_PORTRAIT)
		)
		return
	var unit: Dictionary = _find_unit_by_id(unit_id)
	if unit.is_empty():
		return
	unit_details_popup.show_unit(unit, skill_library, _load_unit_portrait(unit))


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
	return HexUtilsScript.distance(a, b)


func _oddr_to_cube(cell: Vector2i) -> Vector3i:
	return HexUtilsScript.oddr_to_cube(cell)


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
	if _check_victory():
		return


	while true:
		if turn_queue.is_empty():
			_rebuild_turn_queue()
			if turn_queue.is_empty():
				return

		turn_queue_index += 1
		if turn_queue_index >= turn_queue.size():
			round_number += 1
			_advance_terrain_effects()
			_try_trigger_map_event()
			_prepare_map_event_warning()
			if _check_victory():
				return
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
	active_turn_has_log = false
	_log_turn_separator()
	unit.remaining_move = int(unit.move_range)
	unit.action_points = int(unit.get("base_action_points", unit.get("action_points", 1)))
	pending_skill_id = ""
	_process_turn_start(unit)
	if _is_manual_side(str(unit.side)):
		_refresh_general_ability_buttons()
	_apply_terrain_effects_to_unit(unit, false)
	if _find_unit_by_id(unit.id).is_empty():
		_sync_board()
		_start_next_activation()
		return
	if _is_immobilized(unit) and _is_manual_side(str(unit.side)):
		_log_event("%s nie rusza sie, bo jest unieruchomiony." % _unit_name_log_text(unit))
	if not _is_manual_side(str(unit.side)) and not _can_unit_continue_turn(unit):
		if _is_immobilized(unit):
			_log_event("%s nie rusza sie, bo jest unieruchomiony." % _unit_name_log_text(unit))
		_sync_board()
		_end_current_activation()
		return
	selected_unit_id = unit.id if _is_manual_side(str(unit.side)) else -1
	board.set_selected_unit(selected_unit_id)
	_sync_board()
	if unit.side == "enemy" and not _is_manual_side(str(unit.side)):
		_enemy_take_turn()


func _get_active_unit() -> Dictionary:
	return _find_unit_by_id(active_unit_id)


func _is_player_turn() -> bool:
	return current_turn == "player"


func _is_manual_turn() -> bool:
	return _is_manual_side(current_turn)


func _is_manual_side(side: String) -> bool:
	return side == "player" or (side == "enemy" and current_player_faction == "testowa" and current_enemy_faction == "testowa")


func _log_turn_separator() -> void:
	_log_event(_color_log_text("------------------------------------------", LOG_COLOR_YELLOW), false)


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


func _check_victory() -> bool:
	var has_player := _has_units_on_side("player")
	var has_enemy := _has_units_on_side("enemy")
	if has_player and has_enemy:
		return false
	var winner_side := "player" if has_player else "enemy"
	active_unit_id = -1
	current_turn = ""
	selected_unit_id = -1
	pending_skill_id = ""
	is_animating = false
	board.set_selected_unit(-1)
	_update_selection_visibility()
	board.set_highlighted_cells([], [])
	board.set_hovered_move_path([])
	_clear_unit_details()
	_update_action_buttons()
	_refresh_turn_queue()
	_show_victory_overlay(winner_side)
	return true


func _get_visible_turn_queue() -> Array[int]:
	var visible_queue: Array[int] = []
	if turn_queue.is_empty():
		return visible_queue

	var start_index: int = maxi(turn_queue_index, 0)
	var unit_limit: int = MAX_VISIBLE_QUEUE_CARDS - (1 if _has_visible_map_event() else 0)
	for offset in range(mini(turn_queue.size(), unit_limit)):
		var index: int = (start_index + offset) % turn_queue.size()
		visible_queue.append(turn_queue[index])
	return visible_queue


func _on_skill_button_pressed(index: int) -> void:
	if not _is_manual_turn() or is_animating:
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


func _refresh_general_display() -> void:
	var faction: String = current_player_faction
	if faction == "orcs" and orc_general_is_kishak:
		general_name_label.text = ORC_GENERAL_KISHAK_NAME
		general_portrait.texture = ORC_GENERAL_KISHAK_PORTRAIT
	else:
		general_name_label.text = str(GENERAL_NAMES.get(faction, "Generał"))
		var portrait: Texture2D = GENERAL_PORTRAITS.get(faction, DEFAULT_GENERAL_PORTRAIT)
		general_portrait.texture = portrait if portrait != null else DEFAULT_GENERAL_PORTRAIT
	general_level_label.text = "Poziom 5"


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
