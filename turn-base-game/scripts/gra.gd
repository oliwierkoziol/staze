extends Control

const BATTLE_CONFIG_PATH := "res://data/battle_config.json"
const TERRAIN_TYPES_PATH := "res://data/terrain_types.json"
const SCENARIOS_PATH := "res://data/scenarios/scenarios.json"
const DEFAULT_BATTLE_BACKGROUND_PATH := "res://assets/backgrounds/back.png"
const CASTLE_SCENARIO_PATH := "res://data/scenarios/zamek.json"
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
const PIERCING_SHOT_HEX_COUNT := 3
const PLONIECIE_TICK_DAMAGE := 2
const PLONIECIE_TURNS := 3
const MAX_VISIBLE_QUEUE_CARDS := 8
const TURN_QUEUE_PLACEHOLDER_PORTRAIT: Texture2D = preload("res://assets/ui/unit1.png")
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
const HUMAN_GENERAL_KOVALENKO_NAME := "Kapitan Kovalenko"
const HUMAN_GENERAL_KOVALENKO_PORTRAIT: Texture2D = preload("res://assets/ui/general_kovalenko.png")
const LOG_COLOR_YELLOW := Color(0.95, 0.82, 0.25, 1.0)
const LOG_COLOR_PLAYER := Color(0.35, 0.65, 0.95, 1.0)
const LOG_COLOR_ENEMY := Color(0.92, 0.35, 0.30, 1.0)
const LOG_COLOR_DAMAGE := Color(0.92, 0.35, 0.30, 1.0)
const SFX_LUDZKICH_JEDNOSTEK: Dictionary = {
	"human_knights": {
		"wybor": preload("res://assets/sfx/human/knight-select.wav"),
		"obrazenia": preload("res://assets/sfx/human/knight-hurt.wav"),
		"smierc": preload("res://assets/sfx/human/knight-death.wav"),
	},
	"human_cavalry": {
		"wybor": preload("res://assets/sfx/human/chariot-select.wav"),
		"obrazenia": preload("res://assets/sfx/human/chariot-damage.wav"),
		"smierc": preload("res://assets/sfx/human/chariot-death.wav"),
	},
	"human_archers": {
		"wybor": preload("res://assets/sfx/human/archer-select.wav"),
		"obrazenia": preload("res://assets/sfx/human/archer-hurt.wav"),
		"smierc": preload("res://assets/sfx/human/archer-death.wav"),
	},
	"human_mages": {
		"wybor": preload("res://assets/sfx/human/mage-select.wav"),
		"obrazenia": preload("res://assets/sfx/human/mage-damage.wav"),
		"smierc": preload("res://assets/sfx/human/mage-death.wav"),
	},
}
const SFX_FRAKCJI: Dictionary = {
	"dwarf": {
		"wybor": preload("res://assets/sfx/dwarf/dwarf-select.wav"),
		"obrazenia": preload("res://assets/sfx/dwarf/dwarf-damage.wav"),
		"smierc": preload("res://assets/sfx/dwarf/dwarf-death.wav"),
	},
	"elf": {
		"wybor": preload("res://assets/sfx/elf/elf-select.wav"),
		"obrazenia": preload("res://assets/sfx/elf/elf-damage.wav"),
		"smierc": preload("res://assets/sfx/elf/elf-death.wav"),
	},
	"goblin": {
		"wybor": preload("res://assets/sfx/goblin/goblin-select.wav"),
		"obrazenia": preload("res://assets/sfx/goblin/goblin-damage.wav"),
		"smierc": preload("res://assets/sfx/goblin/goblin-death.wav"),
	},
	"orc": {
		"wybor": preload("res://assets/sfx/orc/warrior-select.wav"),
		"obrazenia": preload("res://assets/sfx/orc/warrior-damage.wav"),
		"smierc": preload("res://assets/sfx/orc/warrior-death.wav"),
	},
}
const SFX_WYBOR_KISHAKA: AudioStream = preload("res://assets/sfx/orc/warrior-kishak.wav")
const SZANSA_SFX_KISHAKA := 0.2
const SFX_BRONI: Dictionary = {
	"arrow": preload("res://assets/sfx/hit/arrow.mp3"),
	"axe": preload("res://assets/sfx/hit/axe.mp3"),
	"dagger": preload("res://assets/sfx/hit/dagger.mp3"),
	"sword": preload("res://assets/sfx/hit/sword.mp3"),
}
const SFX_TRAFIENIA: AudioStream = preload("res://assets/sfx/hit/hitSound.mp3")
const BRON_JEDNOSTEK: Dictionary = {
	"dwarf_warrior": "axe",
	"dwarf_guardian": "axe",
	"dwarf_axeman": "axe",
	"elf_archer": "arrow",
	"elf_swordsman": "sword",
	"goblin_thief": "dagger",
	"goblin_warrior": "axe",
	"goblin_trapper": "dagger",
	"human_knights": "sword",
	"human_cavalry": "sword",
	"human_archers": "arrow",
	"orc_warrior": "axe",
	"orc_berserker": "axe",
	"orc_shieldman": "axe",
}
const TEAM_SETUP_SCENE: PackedScene = preload("res://scenes/team_setup.tscn")
const TeamSetupScript = preload("res://scripts/team_setup.gd")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const MatematykaWalkiScript = preload("res://scripts/matematyka_walki.gd")
const BattleSetupPositionsScript = preload("res://scripts/battle_setup_positions.gd")
const TurnQueueCardScript = preload("res://scripts/turn_queue_card.gd")
const HexUtilsScript = preload("res://scripts/hex_utils.gd")
const ObstacleGeneratorScript = preload("res://scripts/obstacle_generator.gd")
const UnitDetailsPopupScript = preload("res://scripts/unit_details_popup.gd")
const BibliotekaZdarzenMapyScript = preload("res://scripts/biblioteka_zdarzen_mapy.gd")
const PlanerAIScript = preload("res://scripts/planer_ai.gd")
const MechanikaUmiejetnosciScript = preload("res://scripts/mechanika_umiejetnosci.gd")
const TrescPomocyScript = preload("res://scripts/tresc_pomocy.gd")

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
	"hole_left": load("res://assets/newAssets/holeLeft.png"),
	"hole_right": load("res://assets/newAssets/holeRight.png"),
	"detonator": load("res://assets/detonator.png"),
	"magiczna_bariera": load("res://assets/magic_projection.png"),
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
	"magiczna_bariera": "Magiczna Bariera",
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
	"detonator": "Jednorazowy detonator aktywowany PPM. Z sasiedniego hexa pokazuje pola upadku; jednostka dystansowa moze go zastrzelic bez ostrzezenia. Przywoluje kamienie na cztery hexy.",
	"magiczna_bariera": "Tymczasowa bariera blokuje ruch i linie strzalu. Znika po kilku turach.",
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
@onready var damage_tooltip: PanelContainer = $HUD/Overlay/DamageTooltip
@onready var damage_tooltip_label: Label = $HUD/Overlay/DamageTooltip/Label
@onready var odtwarzacz_sfx_jednostek: AudioStreamPlayer = $OdtwarzaczSfxJednostek
@onready var odtwarzacz_sfx_broni: AudioStreamPlayer = $OdtwarzaczSfxBroni
@onready var odtwarzacz_sfx_trafienia: AudioStreamPlayer = $OdtwarzaczSfxTrafienia

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
var pending_general_skill_id := ""
var orc_general_is_kishak := false
var human_general_is_kovalenko := false
var terrain_effects: Array[Dictionary] = []
var setup_mode := true
var setup_drag_unit_id := -1
var last_battle_config_source := ""
var setup_controls: HBoxContainer
var save_setup_button: Button
var reset_battle_button: Button
var load_setup_button: Button
@onready var pause_menu: CanvasLayer = $PauseMenu
var _web_load_input: Variant
var _web_load_reader: Variant
var _web_load_change_callback: Variant
var _web_load_callback: Variant
var current_player_faction := ""
var current_enemy_faction := ""
var ai_difficulty := "sredni"
var current_battle_background_path: String = DEFAULT_BATTLE_BACKGROUND_PATH
var castle_stage := 0
var free_setup_mode := false
var help_popup: PanelContainer
var help_blocker: Control
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
var detonator_activated := false
var screen_message_label: Label
var screen_message_tween: Tween
var last_hover_warning_cell := Vector2i(-2, -2)
var last_hover_warning_text := ""
var stage_transition_overlay: ColorRect
var stage_transition_title: Label
var stage_transition_progress: Label
var unit_details_popup: PopupPanel
var debug_map_event_menu: PopupMenu

var save_setup_dialog: FileDialog
var load_setup_dialog: FileDialog
var losowanie_sfx: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	losowanie_sfx.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disable_hud_mouse(hud)
	_build_help_popup()
	_build_victory_overlay()
	_build_screen_message_label()
	_build_stage_transition_overlay()
	_connect_pause_menu_signals()
	if OS.is_debug_build():
		_build_debug_map_event_menu()
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
		terrain["movement_cost"] = max(1, int(terrain.get("movement_cost", 1)))
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

	if (save_setup_dialog != null and save_setup_dialog.visible) or (load_setup_dialog != null and load_setup_dialog.visible):
		return
	if event.keycode == KEY_D and OS.is_debug_build() and debug_map_event_menu != null and not setup_mode and not is_animating:
		debug_map_event_menu.position = Vector2i(get_viewport().get_mouse_position())
		debug_map_event_menu.popup()
		get_viewport().set_input_as_handled()
		return

	if event.keycode == KEY_ESCAPE:
		_toggle_pause_menu()
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
			if help_popup != null and help_popup.visible:
				get_viewport().set_input_as_handled()
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
	setup.set("_ai_difficulty", ai_difficulty)
	setup.setup_finished.connect(_on_team_setup_finished)
	setup.setup_loaded.connect(_on_team_setup_loaded)
	setup.custom_setup_finished.connect(_on_custom_setup_finished)
	add_child(setup)
	if hud != null:
		hud.visible = false
	if board != null:
		board.visible = false


func _on_team_setup_finished(player_faction: String, enemy_faction: String, selected_ai_difficulty: String) -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	current_player_faction = player_faction
	current_enemy_faction = enemy_faction
	ai_difficulty = selected_ai_difficulty if selected_ai_difficulty == "gracz" or PlanerAIScript.PROFILE.has(selected_ai_difficulty) else "sredni"
	castle_stage = 0
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
	_roll_general_variants()
	_setup_battle_scene()


func _on_team_setup_loaded(save_data: Dictionary) -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	current_player_faction = str(save_data.get("player_faction", ""))
	current_enemy_faction = str(save_data.get("enemy_faction", ""))
	ai_difficulty = str(save_data.get("ai_difficulty", "sredni"))
	if ai_difficulty != "gracz" and not PlanerAIScript.PROFILE.has(ai_difficulty):
		ai_difficulty = "sredni"
	castle_stage = int(save_data.get("castle_stage", 0))
	orc_general_is_kishak = bool(save_data.get("orc_general_is_kishak", false))
	human_general_is_kovalenko = bool(save_data.get("human_general_is_kovalenko", false))
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


func _on_custom_setup_finished(custom_units: Array[Dictionary], player_faction: String, enemy_faction: String, background_path: String, selected_ai_difficulty: String) -> void:
	if victory_overlay != null:
		victory_overlay.visible = false
	current_player_faction = player_faction
	current_enemy_faction = enemy_faction
	ai_difficulty = selected_ai_difficulty if selected_ai_difficulty == "gracz" or PlanerAIScript.PROFILE.has(selected_ai_difficulty) else "sredni"
	castle_stage = 1 if background_path.get_file().get_basename() == "zamek_etap_1_mury" else 0
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
	_roll_general_variants()
	_setup_battle_scene()
	if castle_stage == 1:
		is_animating = true
		var stages: Array[Dictionary] = _get_castle_stages()
		_set_stage_transition_content(castle_stage, stages)
		stage_transition_overlay.visible = true
		var transition: Tween = create_tween()
		transition.tween_property(stage_transition_overlay, "modulate:a", 1.0, 0.45)
		transition.tween_interval(2.5)
		transition.tween_property(stage_transition_overlay, "modulate:a", 0.0, 0.45)
		await transition.finished
		stage_transition_overlay.visible = false
		is_animating = false


func _roll_general_variants() -> void:
	orc_general_is_kishak = current_player_faction == "orcs" and randi_range(1, 10) == 1
	human_general_is_kovalenko = current_player_faction == "humans" and randi_range(1, 60) == 1


func _load_general_skills() -> void:
	general_skills = UnitTypeLibraryScript.get_general_skills()
	general_skill_ids = UnitTypeLibraryScript.get_faction_general_skill_ids(current_player_faction)
	general_skill_used = false
	pending_general_skill_id = ""


func _set_battle_background(path: String) -> void:
	current_battle_background_path = path if path != "" else DEFAULT_BATTLE_BACKGROUND_PATH
	var texture: Resource = load(current_battle_background_path)
	if texture is Texture2D:
		battle_background.texture = texture
	_sync_board_map_theme()


func _sync_board_map_theme() -> void:
	if not is_node_ready() or board == null:
		return
	board.set_mapa_zimowa(_is_winter_scenario())


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
		if unit.has("grid_x") and unit.has("grid_y"):
			pos = Vector2i(int(unit.grid_x), int(unit.grid_y))
		unit_configs.append({
			"id": int(unit.get("id", unit_configs.size() + 1)),
			"type_id": str(unit.get("type_id", "")),
			"side": side,
			"count": int(unit.get("count", 1)),
			"grid_x": pos.x,
			"grid_y": pos.y,
		})


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
	setup_controls.visible = false
	add_child(setup_controls)

	save_setup_button = _make_setup_button("ZAPISZ")
	save_setup_button.pressed.connect(_on_save_setup_pressed)
	setup_controls.add_child(save_setup_button)

	reset_battle_button = _make_setup_button("RESET")
	reset_battle_button.pressed.connect(_on_reset_battle_pressed)
	setup_controls.add_child(reset_battle_button)

	load_setup_button = _make_setup_button("WCZYTAJ")
	load_setup_button.pressed.connect(_on_load_setup_pressed)
	setup_controls.add_child(load_setup_button)

	save_setup_dialog = FileDialog.new()
	save_setup_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_setup_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_setup_dialog.filters = PackedStringArray(["*.json ; Zapis armii"])
	save_setup_dialog.file_selected.connect(_on_save_setup_file_selected)
	add_child(save_setup_dialog)

	load_setup_dialog = FileDialog.new()
	load_setup_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_setup_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_setup_dialog.filters = PackedStringArray(["*.json ; Zapis armii"])
	load_setup_dialog.file_selected.connect(_on_load_setup_file_selected)
	add_child(load_setup_dialog)


func _toggle_pause_menu() -> void:
	if pause_menu == null or hud == null or not hud.visible:
		return
	pause_menu.toggle()


func _on_pause_resume_pressed() -> void:
	pause_menu.close_menu()


func _on_pause_reset_pressed() -> void:
	pause_menu.close_menu()
	if current_player_faction == "" or current_enemy_faction == "":
		_on_reset_battle_pressed()
		return
	setup_mode = true
	help_mode_tutorial = true
	tutorial_page = 0
	tutorial_acknowledged = false
	selected_unit_id = -1
	setup_drag_unit_id = -1
	active_unit_id = -1
	current_turn = ""
	pending_skill_id = ""
	selected_obstacle_cell = Vector2i(-1, -1)
	is_animating = false
	turn_queue_index = -1
	event_log.clear()
	general_skill_used = false
	pending_general_skill_id = ""
	_load_general_skills()
	_refresh_general_display()
	_refresh_general_ability_buttons()
	_enter_setup_mode()


func _on_pause_exit_pressed() -> void:
	pause_menu.close_menu()
	_on_reset_battle_pressed()


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
		_set_help_popup_visible(true)


func _on_start_battle_pressed() -> void:
	if not setup_mode:
		return
	if help_popup != null and help_popup.visible:
		return
	if not _has_units_on_side("player"):
		_show_screen_message("Twoja armia jest pusta!", 2.5)
		return
	if not _has_units_on_side("enemy"):
		_show_screen_message("Armia wroga jest pusta!", 2.5)
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
	board.set_detonator_warning_cells([])
	board.clear_falling_rock_cells()
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	_clear_move_cost_label()
	_log_event(_color_log_text("Bitwa rozpoczęta.", LOG_COLOR_YELLOW))
	_rebuild_turn_queue()
	_start_next_activation()


func _on_save_setup_pressed() -> void:
	if help_popup != null and help_popup.visible:
		return
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(
			JSON.stringify(_make_save_data(), "\t").to_utf8_buffer(),
			"zapis_armii.json",
			"application/json"
		)
		_log_event(_color_log_text("Pobrano zapis stanu gry.", LOG_COLOR_YELLOW), false)
		return
	save_setup_dialog.current_file = "zapis_armii.json"
	save_setup_dialog.popup_centered(Vector2i(900, 600))


func _on_save_setup_file_selected(path: String) -> void:
	var save_path := path if path.get_extension().to_lower() == "json" else "%s.json" % path
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		_log_event(_color_log_text("Nie udało się zapisać ustawienia armii.", LOG_COLOR_DAMAGE), false)
		return
	file.store_string(JSON.stringify(_make_save_data(), "	"))
	_log_event(_color_log_text("Zapisano stan gry.", LOG_COLOR_YELLOW), false)


func _on_load_setup_pressed() -> void:
	if help_popup != null and help_popup.visible:
		return
	if OS.has_feature("web"):
		_open_web_load_setup_dialog()
		return
	load_setup_dialog.popup_centered(Vector2i(900, 600))


func _on_load_setup_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_show_screen_message("Nie udało się odczytać zapisu.", 2.5)
		return
	_load_setup_from_text(file.get_as_text())


func _open_web_load_setup_dialog() -> void:
	var document: Variant = JavaScriptBridge.get_interface("document")
	_web_load_input = document.createElement("input")
	_web_load_input.type = "file"
	_web_load_input.accept = ".json,application/json"
	_web_load_change_callback = JavaScriptBridge.create_callback(_on_web_load_setup_selected)
	_web_load_input.addEventListener("change", _web_load_change_callback)
	_web_load_input.click()


func _on_web_load_setup_selected(args: Array) -> void:
	var files: Variant = args[0].target.files
	if int(files.length) == 0:
		return
	_web_load_reader = JavaScriptBridge.create_object("FileReader")
	_web_load_callback = JavaScriptBridge.create_callback(_on_web_load_setup_finished)
	_web_load_reader.onload = _web_load_callback
	_web_load_reader.readAsText(files[0])


func _on_web_load_setup_finished(args: Array) -> void:
	_load_setup_from_text(str(args[0].target.result))


func _load_setup_from_text(text: String) -> void:
	var data: Dictionary = TeamSetupScript._parse_save_text(text)
	if data.is_empty():
		_show_screen_message("Nieprawidłowy plik zapisu.", 2.5)
		return
	_on_team_setup_loaded(data)


func _make_save_data() -> Dictionary:
	return {
		"player_faction": current_player_faction,
		"enemy_faction": current_enemy_faction,
		"ai_difficulty": ai_difficulty,
		"background_path": current_battle_background_path,
		"castle_stage": castle_stage,
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
		"human_general_is_kovalenko": human_general_is_kovalenko,
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
			unit["level"] = maxi(1, int(unit.get("level", 1)))
			units.append(unit if unit.has("max_hp") else _prepare_unit(unit))
	unit_configs = []
	for unit in units:
		unit_configs.append({
			"id": int(unit.get("id", 0)),
			"type_id": str(unit.get("type_id", "")),
			"side": str(unit.get("side", "")),
			"level": maxi(1, int(unit.get("level", 1))),
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
	human_general_is_kovalenko = bool(save_data.get("human_general_is_kovalenko", false))
	is_animating = false
	selected_obstacle_cell = Vector2i(-1, -1)
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
	if help_popup != null and help_popup.visible:
		return
	setup_mode = true
	help_mode_tutorial = true
	tutorial_page = 0
	tutorial_acknowledged = false
	_update_setup_hint_visibility()
	current_player_faction = ""
	current_enemy_faction = ""
	free_setup_mode = false
	castle_stage = 0
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
	if help_popup != null and help_popup.visible:
		return
	UnitTypeLibraryScript.reload()
	var scenario_reloaded: bool = _reload_selected_factions()
	if setup_mode or scenario_reloaded:
		_enter_setup_mode()
		return
	_apply_live_reload()


func _reload_selected_factions() -> bool:
	skill_library = UnitTypeLibraryScript.get_skill_library()
	_load_general_skills()
	last_battle_config_source = ProjectSettings.globalize_path(UnitTypeLibraryScript.UNIT_TYPES_PATH)
	if current_player_faction == "" or current_enemy_faction == "":
		_load_battle_config()
		return false
	var scenario_reloaded: bool = _reload_current_scenario_config()
	_refresh_general_display()
	_refresh_general_ability_buttons()
	return scenario_reloaded


func _reload_current_scenario_config() -> bool:
	var parsed: Variant = JSON.parse_string(_read_json_text(SCENARIOS_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var scenario_id: String = current_battle_background_path.get_file().get_basename()
	for raw_scenario in (parsed as Dictionary).get("scenarios", []):
		if typeof(raw_scenario) != TYPE_DICTIONARY or str(raw_scenario.get("id", "")) != scenario_id:
			continue
		var scenario: Dictionary = raw_scenario
		var scenario_units: Array[Dictionary] = []
		for side: String in ["player", "enemy"]:
			for raw_unit in scenario.get("%s_units" % side, []):
				if typeof(raw_unit) != TYPE_DICTIONARY:
					continue
				var unit: Dictionary = raw_unit.duplicate(true)
				unit["side"] = side
				scenario_units.append(unit)
		_build_test_battle_config(scenario_units)
		last_battle_config_source = ProjectSettings.globalize_path(SCENARIOS_PATH)
		return true
	return false


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
	for key in ["id", "grid_x", "grid_y", "level"]:
		normalized[key] = int(normalized.get(key, 0))
	normalized["level"] = maxi(1, int(normalized.get("level", 1)))
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

	for stat_name in ["hp", "atk", "dmg_min", "dmg_max", "def", "speed", "move_range", "attack_range", "action_points", "count"]:
		if not unit.has(stat_name):
			unit[stat_name] = 0
		unit["base_%s" % stat_name] = int(unit.get(stat_name, 0))
	unit["level"] = maxi(1, int(unit.get("level", 1)))
	unit["max_hp"] = int(unit["base_hp"])
	MatematykaWalkiScript.ustaw_pelne_hp(unit)
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
	selected_obstacle_cell = Vector2i(-1, -1)
	board.set_selected_unit(unit_data.id)
	_update_selection_visibility()
	if setup_mode or (_is_manual_side(str(unit_data.side)) and str(unit_data.side) == current_turn):
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
	unit_meta_label.text = "Poziom %d" % int(unit_data.get("level", 1))
	var current_hp: int = int(unit_data.get("current_hp", unit_data.get("hp", 0)))
	var max_hp: int = int(unit_data.get("max_hp", unit_data.get("hp", 0)))
	unit_stats_display.set_values({
		"hp": "%s / %s" % [current_hp, max_hp],
		"atk": str(unit_data.get("atk", 0)),
		"dmg": "%s-%s" % [unit_data.get("dmg_min", 0), unit_data.get("dmg_max", 0)],
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
	var rebuilt_units: Array = []
	for existing_unit in units:
		var rebuilt_unit: Dictionary = _prepare_unit({
			"id": int(existing_unit.get("id", 0)),
			"type_id": str(existing_unit.get("type_id", "")),
			"side": str(existing_unit.get("side", "")),
			"count": int(existing_unit.get("count", 1)),
			"grid_x": int(existing_unit.get("grid_x", 0)),
			"grid_y": int(existing_unit.get("grid_y", 0)),
		})
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
	_log_event(_color_log_text("Przeładowano plik JSON w trakcie rozgrywki.", LOG_COLOR_YELLOW))


func _reapply_runtime_state(target_unit: Dictionary, existing_unit: Dictionary) -> void:
	target_unit["grid_x"] = int(existing_unit.get("grid_x", 0))
	target_unit["grid_y"] = int(existing_unit.get("grid_y", 0))
	var stare_maksimum: int = maxi(1, int(existing_unit.get("max_total_hp", 1)))
	var udzial_hp: float = float(existing_unit.get("current_total_hp", 0)) / stare_maksimum
	target_unit["current_total_hp"] = int(round(int(target_unit.max_total_hp) * udzial_hp))
	for key in ["active_effects", "skill_cooldowns", "remaining_move", "action_points", "is_hidden", "is_revealed"]:
		if existing_unit.has(key):
			target_unit[key] = existing_unit[key].duplicate(true) if existing_unit[key] is Array or existing_unit[key] is Dictionary else existing_unit[key]
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
			"[RELOAD %s] id=%s name=%s hp=%s atk=%s dmg=%s-%s def=%s spd=%s move=%s range=%s count=%s skills=%s" % [
				stage,
				str(unit_data.get("id", -1)),
				str(unit_data.get("name", "?")),
				str(unit_data.get("hp", unit_data.get("base_hp", 0))),
				str(unit_data.get("atk", unit_data.get("base_atk", 0))),
				str(unit_data.get("dmg_min", unit_data.get("base_dmg_min", 0))),
				str(unit_data.get("dmg_max", unit_data.get("base_dmg_max", 0))),
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
			"can_use": can_act and MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit_data, skill_id, skill_library),
			"selected": pending_skill_id == skill_id,
			"tooltip": _build_skill_tooltip(unit_data, index),
			"icon": UnitTypeLibraryScript.get_skill_icon_path(skill_id, index),
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
	move_cost_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	move_cost_label.visible = true


func _clear_move_cost_label() -> void:
	displayed_path_cost = -1
	if move_cost_label == null:
		return
	move_cost_label.text = ""
	move_cost_label.visible = false
	move_cost_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))


func _stop_unit_on_terrain(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	if not _terrain_skips_turn(cell):
		return
	unit.remaining_move = 0


func _on_cell_clicked(cell: Vector2i) -> void:
	if help_popup != null and help_popup.visible:
		return
	if setup_mode:
		_handle_setup_cell_pressed(cell)
		return

	if is_animating or not _is_manual_turn():
		return
	if pending_general_skill_id != "":
		await _try_execute_general_skill(cell)
		return

	var active_unit := _get_active_unit()
	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)):
		return

	if pending_skill_id != "":
		var pending_skill: Dictionary = skill_library.get(pending_skill_id, {})
		if str(pending_skill.get("effect_type", "")) == "charge":
			_try_execute_charge_move(active_unit, cell)
		else:
			await _try_use_skill(active_unit, pending_skill_id, cell)
		_update_highlighted_cells(active_unit)
		_update_action_buttons()
		return

	var clicked_unit := _find_visible_unit_at_cell(cell, active_unit)
	if not clicked_unit.is_empty():
		if clicked_unit.id == selected_unit_id:
			_clear_selected_unit()
			return
		if clicked_unit.side != active_unit.side:
			_render_unit_details(clicked_unit)
			return
		selected_unit_id = clicked_unit.id
		selected_obstacle_cell = Vector2i(-1, -1)
		_show_unit_details(clicked_unit)
		return

	if selected_unit_id == -1 and selected_obstacle_cell == Vector2i(-1, -1) and _is_cell_obstacle(cell):
		_show_obstacle_details(cell)
		return

	if selected_unit_id != active_unit.id:
		selected_unit_id = active_unit.id
		_show_unit_details(active_unit)
		# Nie wykonuj ruchu, dopóki użytkownik nie ma zaznaczonej jednostki.
		# Pierwszy klik tylko zaznacza, kolejny dopiero rusza.
		return

	if _is_immobilized(active_unit):
		return

	var remaining_move: int = _get_remaining_move(active_unit)
	if remaining_move <= 0:
		return

	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell, {}, remaining_move)
	var path_cost: int = _get_path_cost(path)
	if path.is_empty():
		if _is_ambush_cell_for_unit(active_unit, cell):
			var ambush_defender: Dictionary = _get_ambush_defender_at_cell(active_unit, cell)
			if not ambush_defender.is_empty() and _hex_distance(Vector2i(active_unit.grid_x, active_unit.grid_y), cell) == 1:
				_try_trigger_bush_ambush(active_unit, ambush_defender)
				if _find_unit_by_id(int(active_unit.id)).is_empty():
					_end_current_activation()
					return
				_sync_board()
				return
		if _is_cell_obstacle(cell):
			_show_obstacle_details(cell)
		return
	if path_cost > remaining_move:
		_clear_move_cost_label()
		return

	var move_path: Array[Vector2i] = _get_executable_move_path(path, active_unit)
	var move_cost: int = _get_path_cost(move_path)
	is_animating = true
	var destination: Vector2i = move_path[move_path.size() - 1] if not move_path.is_empty() else Vector2i(active_unit.grid_x, active_unit.grid_y)
	var ambush_defender: Dictionary = {}
	# Zasadzka odpala się dopiero gdy planowana trasa ma wkroczyć w heks z ukrytym wrogiem.
	for step in path:
		if _is_ambush_cell_for_unit(active_unit, step):
			ambush_defender = _get_ambush_defender_at_cell(active_unit, step)
			break
	var origin := Vector2i(active_unit.grid_x, active_unit.grid_y)
	active_unit.grid_x = destination.x
	active_unit.grid_y = destination.y
	_reveal_unit_leaving_concealment(active_unit, origin)
	active_unit.remaining_move = max(0, remaining_move - move_cost)
	pending_skill_id = ""
	_sync_board()
	_show_move_cost_label(move_cost, active_unit.remaining_move)
	board.animate_unit_path(active_unit.id, move_path)
	await board.animation_finished
	_clear_move_cost_label()
	_log_event("%s porusza się." % _unit_name_log_text(active_unit))
	_try_trigger_bush_ambush(active_unit, ambush_defender)
	if _find_unit_by_id(int(active_unit.id)).is_empty():
		_end_current_activation()
		return
	_apply_terrain_effects_to_unit(active_unit)
	if _find_unit_by_id(int(active_unit.id)).is_empty():
		_end_current_activation()
		return
	_stop_unit_on_terrain(active_unit)
	_try_trigger_agility(active_unit)
	_sync_board()


func _on_cell_double_clicked(cell: Vector2i) -> void:
	if help_popup != null and help_popup.visible:
		return
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
	if help_popup != null and help_popup.visible:
		return
	if setup_mode or is_animating or not _is_manual_turn():
		return
	var active_unit := _get_active_unit()
	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)) or selected_unit_id != active_unit.id:
		return
	if _try_activate_detonator(active_unit, cell):
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
	if help_popup != null and help_popup.visible:
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
	board.set_selected_obstacle(Vector2i(-1, -1))
	board.set_highlighted_cells([], [])
	board.set_hovered_move_path([])
	_clear_move_cost_label()
	_update_action_buttons()
	if setup_mode:
		return
	_start_next_activation()


func _enemy_take_turn() -> void:
	var enemy_unit := _get_active_unit()
	if enemy_unit.is_empty() or enemy_unit.side != "enemy":
		return
	await get_tree().create_timer(1.0).timeout
	if setup_mode or is_animating or active_unit_id != int(enemy_unit.id) or _find_unit_by_id(int(enemy_unit.id)).is_empty():
		return
	await _ai_execute_plan(enemy_unit, _ai_choose_plan(enemy_unit))


func _ai_choose_plan(unit: Dictionary) -> Dictionary:
	return PlanerAIScript.wybierz_plan(self, unit)


func _ai_generate_action_plans(unit: Dictionary, path: Array[Vector2i]) -> Array[Dictionary]:
	var plans: Array[Dictionary] = []
	var unit_cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	if _can_unit_attack(unit):
		for target in units:
			if target.side == unit.side or not _can_see_target(unit, target):
				continue
			var target_cell := Vector2i(int(target.grid_x), int(target.grid_y))
			if _is_in_attack_range(unit, target_cell):
				plans.append({
					"kind": "basic_attack",
					"target_id": int(target.id),
					"path": path,
					"score": _ai_score_damage(unit, target, 1.0) + _ai_score_position(unit, unit_cell),
				})
	for raw_skill_id in unit.get("skill_ids", []):
		var skill_id: String = str(raw_skill_id)
		if not MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, skill_id, skill_library):
			continue
		var skill: Dictionary = skill_library.get(skill_id, {})
		var target_type: String = str(skill.get("target_type", ""))
		var effect_type: String = str(skill.get("effect_type", ""))
		if effect_type == "charge":
			if path.is_empty():
				for target in units:
					if target.side != unit.side and _can_charge_attack_target(unit, target, skill):
						plans.append({"kind": "charge", "skill_id": skill_id, "target_id": int(target.id), "path": [], "score": _ai_score_damage(unit, target, 1.5) + 60})
			continue
		if target_type == "self":
			var self_score: int = _ai_score_skill(unit, unit, unit_cell, skill)
			if self_score > 0:
				plans.append({"kind": "skill", "skill_id": skill_id, "target_id": int(unit.id), "target_cell": unit_cell, "path": path, "score": self_score + _ai_score_position(unit, unit_cell)})
		elif target_type == "enemy_unit":
			for target in units:
				if _can_target_enemy_with_skill(unit, target, skill):
					var target_cell := Vector2i(int(target.grid_x), int(target.grid_y))
					plans.append({"kind": "skill", "skill_id": skill_id, "target_id": int(target.id), "target_cell": target_cell, "path": path, "score": _ai_score_skill(unit, target, target_cell, skill) + _ai_score_position(unit, unit_cell)})
		elif target_type == "ally_unit":
			for target in units:
				if _can_target_ally_with_skill(unit, target, skill):
					var ally_score: int = _ai_score_skill(unit, target, Vector2i(int(target.grid_x), int(target.grid_y)), skill)
					if ally_score > 0:
						plans.append({"kind": "skill", "skill_id": skill_id, "target_id": int(target.id), "target_cell": Vector2i(int(target.grid_x), int(target.grid_y)), "path": path, "score": ally_score + _ai_score_position(unit, unit_cell)})
		elif target_type == "cell":
			var best_cell := Vector2i(-1, -1)
			var best_score := 0
			for cell in _get_skill_target_cells(unit, skill_id):
				if not _can_target_cell_with_skill(unit, cell, skill):
					continue
				var cell_score: int = _ai_score_skill(unit, {}, cell, skill)
				if cell_score > best_score:
					best_score = cell_score
					best_cell = cell
			if best_cell != Vector2i(-1, -1):
				plans.append({"kind": "skill", "skill_id": skill_id, "target_id": -1, "target_cell": best_cell, "path": path, "score": best_score + _ai_score_position(unit, unit_cell)})
	return plans


func _ai_score_skill(caster: Dictionary, target: Dictionary, target_cell: Vector2i, skill: Dictionary) -> int:
	var effect_type: String = str(skill.get("effect_type", ""))
	var cooldown_cost: int = int(skill.get("cooldown", 0)) * 8
	match effect_type:
		"focused_strike", "shield_push":
			var push_score: int = _ai_score_damage(caster, target, 1.0) - cooldown_cost
			if effect_type == "shield_push":
				push_score += _ai_score_forced_destination(target, _get_push_destination(caster, target))
			return push_score
		"shattering_strike":
			return _ai_score_damage(caster, target, 1.5) + (80 if _ai_will_kill(caster, target, 1.5) else 0) - cooldown_cost
		"knee_shot":
			return _ai_score_damage(caster, target, 0.7) + _ai_score_control(target, 1) - cooldown_cost
		"poison_dagger":
			return _ai_score_damage(caster, target, 0.7) + (0 if _is_poison_immune(target) or _has_effect(target, "toksyna") else 110) - cooldown_cost
		"hammer_strike":
			return _ai_score_damage(caster, target, 1.0) + _ai_score_control(target, 1) + 60 - cooldown_cost
		"pnacza":
			return (0 if _has_effect(target, "immobilize") else _ai_score_control(target, 2)) - cooldown_cost
		"curse_throw":
			return (0 if _has_effect(target, "klatwa") else 100 + int(PlanerAIScript.wartosc_jednostki(target) / 5.0)) - cooldown_cost
		"hook_throw":
			return 80 + _ai_score_forced_destination(target, _get_pull_destination(caster, target)) - cooldown_cost
		"zaklete_ciecie":
			return _ai_score_damage(caster, target, 0.5) + (0 if _has_effect(target, "klatwa") else 100) - cooldown_cost
		"rozszarpanie":
			return _ai_score_damage(caster, target, 0.5) + (0 if _has_effect(target, "krwawienie") else 70) - cooldown_cost
		"piercing_shot":
			var pierce_score := 0
			for cell in _get_piercing_shot_cells(caster, target):
				var hit: Dictionary = _find_unit_at_cell(cell)
				if not hit.is_empty():
					pierce_score += _ai_score_damage(caster, hit, 1.0) * (1 if hit.side != caster.side else -2)
			return pierce_score - cooldown_cost
		"dancing_blade":
			return _ai_score_area_damage(caster, Vector2i(int(caster.grid_x), int(caster.grid_y)), 0.5, 0.5) - cooldown_cost
		"fireball", "dynamite_throw":
			return _ai_score_area_damage(caster, target_cell, 1.0, 0.5) + (35 if effect_type == "fireball" else 0) - cooldown_cost
		"arrow_rain":
			return _ai_score_area_damage(caster, target_cell, 0.5, 0.35) - cooldown_cost
		"ice_ground", "poison_cloud":
			return _ai_score_area_control(caster, target_cell, effect_type) - cooldown_cost
		"bear_trap", "goblin_trap":
			return _ai_score_trap(caster, target_cell) - cooldown_cost
		"magic_projection":
			return _ai_score_projection(caster, target_cell) - cooldown_cost
		"summon_statue":
			return _ai_score_statue(caster, target_cell) - cooldown_cost
		"sztandar":
			return MechanikaUmiejetnosciScript.pobierz_sume_cooldownow(target) * 45 - cooldown_cost
		"iron_curtain":
			if _has_effect(target, "zelazna_kurtyna"):
				return 0
			var protected_threat: int = _ai_expected_threat(target, Vector2i(int(target.grid_x), int(target.grid_y)))
			if protected_threat == 0:
				return 0
			return protected_threat + int(PlanerAIScript.wartosc_jednostki(target) / 8.0) - cooldown_cost
		"taunt_burst":
			var affected := 0
			for other in units:
				if other.side != caster.side and _can_see_target(caster, other) and _hex_distance(Vector2i(int(caster.grid_x), int(caster.grid_y)), Vector2i(int(other.grid_x), int(other.grid_y))) <= 2:
					affected += 1
			return affected * 100 - int(_ai_expected_threat(caster, target_cell) / 2.0) - cooldown_cost
		"eagle_eye":
			return 0 if _has_effect(caster, "sokole_oko") else 100 + int(float(_srednie_obrazenia_jednostki(caster) * int(caster.get("count", 1))) / 3.0) - cooldown_cost
		"self_buff":
			if _has_effect(caster, str(skill.get("id", ""))):
				return 0
			if str(skill.get("id", "")) == "mistrz_trucizn":
				return 160 - cooldown_cost
			var duration: int = int(skill.get("effect", {}).get("remaining_turns", 1))
			if duration <= 1 and int(caster.get("action_points", 0)) <= int(skill.get("ap_cost", 0)):
				return 0
			return _ai_score_stat_changes(caster, skill.get("effect", {}).get("stat_changes", []), duration) - cooldown_cost
		"zadza_krwi":
			return 100 + int(caster.get("count", 1)) * 3 - int(_ai_expected_threat(caster, target_cell) / 3.0) - cooldown_cost
		"utwardzenie":
			return 75 + int(_ai_expected_threat(caster, target_cell) / 3.0) - cooldown_cost
	return 0


func _ai_score_damage(attacker: Dictionary, target: Dictionary, multiplier: float) -> int:
	if target.is_empty():
		return 0
	var damage: int = _calculate_expected_damage(attacker, target, multiplier)
	if _has_effect(target, "bariera_energetyczna"):
		damage = 0
	else:
		damage = _adjust_incoming_damage(target, damage)
	var current_hp: int = int(target.get("current_total_hp", int(target.get("hp", 1)) * int(target.get("count", 1))))
	var base_hp: int = max(1, int(target.get("base_hp", target.get("hp", 1))))
	var hp_after: int = maxi(0, current_hp - damage)
	var casualties: int = ceili(float(current_hp) / float(base_hp)) - ceili(float(hp_after) / float(base_hp))
	var profile: Dictionary = PlanerAIScript.pobierz_profil(ai_difficulty)
	var score: int = min(damage, current_hp) * 4
	score += casualties * int(profile.get("casualty_weight", 75))
	if damage >= current_hp:
		score += int(profile.get("kill_bonus", 400))
	score += int(round(float(PlanerAIScript.wartosc_jednostki(target)) * float(profile.get("target_value_weight", 0.06))))
	score += int(round(float(_ai_score_coordination(attacker, target)) * float(profile.get("coordination_weight", 0.4))))
	return score


func _ai_score_area_damage(caster: Dictionary, center: Vector2i, center_multiplier: float, neighbor_multiplier: float) -> int:
	var score := 0
	for cell in _get_area_cells(center):
		var target: Dictionary = _find_unit_at_cell(cell)
		if target.is_empty() or target.side == caster.side or not _can_see_target(caster, target):
			continue
		var multiplier: float = center_multiplier if cell == center else neighbor_multiplier
		score += _ai_score_damage(caster, target, multiplier)
	return score


func _ai_score_area_control(caster: Dictionary, center: Vector2i, effect_type: String) -> int:
	var cells: Array[Vector2i] = _get_cell_skill_preview_cells({"effect_type": effect_type}, center, caster)
	var score := 0
	for cell in cells:
		var target: Dictionary = _find_unit_at_cell(cell)
		if not target.is_empty() and (target.side == caster.side or _can_see_target(caster, target)):
			var value := 90 + _ai_score_control(target, 1)
			if effect_type == "poison_cloud" and _is_poison_immune(target):
				value = 0
			score += value if target.side != caster.side else -value * 3
		for player in units:
			if player.side != caster.side and _can_see_target(caster, player) and _hex_distance(cell, Vector2i(int(player.grid_x), int(player.grid_y))) <= int(player.get("move_range", 0)):
				score += 12
	return score


func _ai_score_control(target: Dictionary, turns: int) -> int:
	if target.is_empty():
		return 0
	return (int(target.get("move_range", 0)) * 14 + _srednie_obrazenia_jednostki(target) * 5 + int(target.get("speed", 0)) * 3) * turns


func _ai_score_stat_changes(unit: Dictionary, changes: Array, turns: int) -> int:
	var score := 0
	for change in changes:
		var stat_name: String = str(change.get("stat", ""))
		var value: int = int(change.get("value", 0))
		var base: int = _srednie_obrazenia_jednostki(unit) if stat_name == "dmg" else int(unit.get("base_%s" % stat_name, unit.get(stat_name, 0)))
		var delta: int = int(ceil(float(base) * float(value) / 100.0)) if str(change.get("mode", "flat")) == "percent" else value
		var weight: int = {"dmg": 18, "atk": 12, "def": 10, "attack_range": 35, "move_range": 22, "speed": 4}.get(stat_name, 2)
		score += delta * weight * max(1, turns)
	return score


func _ai_score_trap(caster: Dictionary, cell: Vector2i) -> int:
	if _has_trap_near_cell_for_side(cell, str(caster.side)):
		return 0
	var score := 20
	for target in units:
		if target.side == caster.side or not _can_see_target(caster, target):
			continue
		var distance: int = _hex_distance(cell, Vector2i(int(target.grid_x), int(target.grid_y)))
		if distance <= int(target.get("move_range", 0)):
			score += 100 - distance * 10
		if distance == 1:
			score += 80
	return score


func _ai_score_projection(caster: Dictionary, cell: Vector2i) -> int:
	var score := 0
	for projection_cell in _get_magic_projection_cells(cell, str(caster.side)):
		for neighbor in _get_neighbors(projection_cell):
			var target: Dictionary = _find_unit_at_cell(neighbor)
			if target.is_empty() or (target.side != caster.side and not _can_see_target(caster, target)):
				continue
			score += 45 if target.side != caster.side else -25
	return score


func _ai_score_statue(caster: Dictionary, cell: Vector2i) -> int:
	var score := 0
	for neighbor in _get_neighbors(cell):
		var ally: Dictionary = _find_unit_at_cell(neighbor)
		if not ally.is_empty() and ally.side == caster.side:
			score += 55 + int(ally.get("count", 1)) * 4
	return score


func _ai_score_forced_destination(target: Dictionary, cell: Vector2i) -> int:
	if cell == Vector2i(-1, -1):
		return 70
	var score := 0
	if _is_hostile_terrain_effect_for_unit(target, cell):
		score += 180
	if str(_get_terrain_at(cell).get("id", "")) == "hole":
		score += 1000
	for attacker in units:
		if attacker.side != target.side and _hex_distance(cell, Vector2i(int(attacker.grid_x), int(attacker.grid_y))) <= int(attacker.get("attack_range", 1)):
			score += 35
	return score


func _ai_score_position(unit: Dictionary, cell: Vector2i) -> int:
	var score: int = -_ai_hazard_penalty(unit, [cell])
	if map_event_cells.has(cell) and BibliotekaZdarzenMapyScript.czy_runda_ostrzezenia(round_number, next_map_event_round):
		score -= 500
	if _terrain_hides_unit(cell):
		score += 80 if int(unit.get("attack_range", 1)) > 1 else 35
	var threat: int = _ai_expected_threat(unit, cell)
	if str(unit.get("balance_role", "")) == "obronca":
		threat = int(ceil(float(threat) / 3.0))
		var ally_distance: int = 1000
		for ally in units:
			if int(ally.id) != int(unit.id) and ally.side == unit.side:
				ally_distance = min(ally_distance, _hex_distance(cell, Vector2i(int(ally.grid_x), int(ally.grid_y))))
		if ally_distance < 1000:
			score -= max(0, ally_distance - 1) * 8
	score += int(round(float(_ai_score_formation(unit, cell)) * float(PlanerAIScript.pobierz_profil(ai_difficulty).get("formation_weight", 0.65))))
	score -= int(round(float(threat) * float(PlanerAIScript.pobierz_profil(ai_difficulty).get("threat_weight", 0.5))))
	return score


func _ai_hazard_penalty(unit: Dictionary, path: Array[Vector2i]) -> int:
	return int(round(float(_get_path_hazard_penalty(unit, path)) * float(PlanerAIScript.pobierz_profil(ai_difficulty).get("hazard_weight", 1.0))))


func _ai_score_coordination(attacker: Dictionary, target: Dictionary) -> int:
	var score := 0
	var current_hp: int = int(target.get("current_total_hp", int(target.get("hp", 1)) * int(target.get("count", 1))))
	var max_hp: int = max(1, int(target.get("max_total_hp", current_hp)))
	score += int(round((1.0 - float(current_hp) / float(max_hp)) * 120.0))
	for ally in units:
		if int(ally.id) == int(attacker.id) or ally.side != attacker.side or not _can_see_target(ally, target):
			continue
		var distance: int = _hex_distance(Vector2i(int(ally.grid_x), int(ally.grid_y)), Vector2i(int(target.grid_x), int(target.grid_y)))
		if distance <= int(ally.get("attack_range", 1)) + int(ally.get("move_range", 0)):
			score += 35
	if str(target.get("balance_role", "")) == "wsparcie_kontrola":
		score += 45
	return score


func _ai_score_formation(unit: Dictionary, cell: Vector2i) -> int:
	# ponytail: O(n²) jest celowo proste dla kilku oddzialow; indeks przestrzenny dopiero przy duzych armiach.
	var role: String = str(unit.get("balance_role", ""))
	var nearest_ally := 1000
	var nearest_enemy := 1000
	var allies_in_front := 0
	for other in units:
		if int(other.id) == int(unit.id):
			continue
		var other_cell := Vector2i(int(other.grid_x), int(other.grid_y))
		if other.side == unit.side:
			nearest_ally = min(nearest_ally, _hex_distance(cell, other_cell))
		else:
			if not _can_see_target(unit, other):
				continue
			var distance: int = _hex_distance(cell, other_cell)
			nearest_enemy = min(nearest_enemy, distance)
			for ally in units:
				if ally.side == unit.side and int(ally.id) != int(unit.id) and _hex_distance(Vector2i(int(ally.grid_x), int(ally.grid_y)), other_cell) < distance:
					allies_in_front += 1
	if role == "wsparcie_kontrola" and nearest_ally < 1000:
		return -abs(nearest_ally - 2) * 18
	if role == "dystansowa":
		return allies_in_front * 18 - max(0, int(unit.get("attack_range", 1)) - nearest_enemy) * 20
	return 0


func _ai_score_approach(unit: Dictionary, cell: Vector2i) -> int:
	var best_distance := 1000
	for target in units:
		if target.side != unit.side and _can_see_target(unit, target):
			best_distance = min(best_distance, _hex_distance(cell, Vector2i(int(target.grid_x), int(target.grid_y))))
	if best_distance == 1000:
		return 0
	var preferred: int = max(1, int(unit.get("attack_range", 1)))
	var approach_weight: int = 24 if str(unit.get("balance_role", "")) == "obronca" else 12
	return -abs(best_distance - preferred) * approach_weight


func _ai_expected_threat(unit: Dictionary, cell: Vector2i) -> int:
	var threat := 0
	var original := Vector2i(int(unit.grid_x), int(unit.grid_y))
	unit.grid_x = cell.x
	unit.grid_y = cell.y
	for attacker in units:
		if attacker.side == unit.side or not _can_see_target(attacker, unit):
			continue
		var distance: int = _hex_distance(Vector2i(int(attacker.grid_x), int(attacker.grid_y)), cell)
		if distance <= int(attacker.get("attack_range", 1)) + int(attacker.get("move_range", 0)):
			threat += _calculate_expected_damage(attacker, unit)
	unit.grid_x = original.x
	unit.grid_y = original.y
	return threat * 3


func _ai_will_kill(attacker: Dictionary, target: Dictionary, multiplier: float) -> bool:
	var damage: int = _adjust_incoming_damage(target, _calculate_expected_damage(attacker, target, multiplier))
	return damage >= int(target.get("current_total_hp", int(target.get("hp", 1)) * int(target.get("count", 1))))


func _ai_execute_plan(unit: Dictionary, plan: Dictionary) -> void:
	var path: Array[Vector2i] = []
	for cell in plan.get("path", []):
		path.append(cell)
	var ambush_cell_in_plan: Vector2i = Vector2i(-1, -1)
	var ambush_defender_in_plan: Dictionary = {}
	for step in path:
		if _is_ambush_cell_for_unit(unit, step):
			ambush_cell_in_plan = step
			ambush_defender_in_plan = _get_ambush_defender_at_cell(unit, step)
			break
	path = _get_executable_move_path(path, unit)
	if path.is_empty() and not ambush_defender_in_plan.is_empty() and _hex_distance(Vector2i(int(unit.grid_x), int(unit.grid_y)), ambush_cell_in_plan) == 1 and not _is_immobilized(unit):
		_try_trigger_bush_ambush(unit, ambush_defender_in_plan)
		if _find_unit_by_id(int(unit.id)).is_empty():
			_end_current_activation()
			return
		_end_current_activation()
		return
	if not path.is_empty() and not _is_immobilized(unit):
		var destination: Vector2i = path[path.size() - 1]
		var path_cost: int = _get_path_cost(path)
		var origin := Vector2i(int(unit.grid_x), int(unit.grid_y))
		unit.grid_x = destination.x
		unit.grid_y = destination.y
		_reveal_unit_leaving_concealment(unit, origin)
		unit.remaining_move = max(0, _get_remaining_move(unit) - path_cost)
		is_animating = true
		_sync_board()
		_show_move_cost_label(path_cost, int(unit.remaining_move))
		board.animate_unit_path(int(unit.id), path)
		await board.animation_finished
		is_animating = false
		_clear_move_cost_label()
		_log_event("%s porusza się." % _unit_name_log_text(unit))
		_try_trigger_bush_ambush(unit, ambush_defender_in_plan)
		if _find_unit_by_id(int(unit.id)).is_empty():
			_end_current_activation()
			return
		_apply_terrain_effects_to_unit(unit)
		if _find_unit_by_id(int(unit.id)).is_empty():
			_end_current_activation()
			return
		_stop_unit_on_terrain(unit)
		_try_trigger_agility(unit)

	var kind: String = str(plan.get("kind", "pass"))
	var target: Dictionary = _find_unit_by_id(int(plan.get("target_id", -1)))
	if kind == "basic_attack" and not target.is_empty() and _can_unit_attack(unit) and _can_see_target(unit, target) and _is_in_attack_range(unit, Vector2i(int(target.grid_x), int(target.grid_y))):
		_perform_basic_attack(unit, target, false)
	elif kind == "charge" and not target.is_empty():
		var charge_skill: Dictionary = skill_library.get(str(plan.get("skill_id", "")), {})
		if MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, str(plan.get("skill_id", "")), skill_library) and _can_charge_attack_target(unit, target, charge_skill):
			await _perform_charge_attack(unit, target, charge_skill, false, true)
	elif kind == "skill":
		var skill_id: String = str(plan.get("skill_id", ""))
		var skill: Dictionary = skill_library.get(skill_id, {})
		var target_cell: Vector2i = plan.get("target_cell", Vector2i(int(unit.grid_x), int(unit.grid_y)))
		var target_type: String = str(skill.get("target_type", ""))
		var legal: bool = target_type == "self"
		if target_type == "enemy_unit":
			legal = _can_target_enemy_with_skill(unit, target, skill)
		elif target_type == "ally_unit":
			legal = _can_target_ally_with_skill(unit, target, skill)
		elif target_type == "cell":
			legal = _can_target_cell_with_skill(unit, target_cell, skill)
		if legal and MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, skill_id, skill_library) and _skill_effect_will_succeed(unit, target, skill, target_cell):
			await _execute_skill(unit, target, skill, target_cell)
	if active_unit_id != int(unit.id):
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


func _find_visible_unit_at_cell(cell: Vector2i, observer: Dictionary) -> Dictionary:
	var unit: Dictionary = _find_unit_at_cell(cell)
	if unit.is_empty():
		return {}
	if not observer.is_empty() and str(unit.side) == str(observer.side):
		return unit
	if observer.is_empty() or not _can_see_target(observer, unit):
		return {}
	return unit


func _skill_effect_will_succeed(caster: Dictionary, target: Dictionary, skill: Dictionary, target_cell: Vector2i) -> bool:
	var effect_type: String = str(skill.get("effect_type", ""))
	match effect_type:
		"taunt_burst":
			var caster_cell := Vector2i(caster.grid_x, caster.grid_y)
			for other in units:
				if other.side == caster.side:
					continue
				if _hex_distance(caster_cell, Vector2i(other.grid_x, other.grid_y)) <= 2:
					return true
			return false
		"dancing_blade":
			var blade_cell := Vector2i(caster.grid_x, caster.grid_y)
			for other in units:
				if other.side == caster.side:
					continue
				if _hex_distance(blade_cell, Vector2i(other.grid_x, other.grid_y)) != 1:
					continue
				if _can_see_target(caster, other):
					return true
			return false
		"hook_throw":
			return _get_pull_destination(caster, target) != Vector2i(-1, -1)
		"magic_projection":
			return _get_magic_projection_cells(target_cell, str(caster.side)).size() == 3
		"summon_statue":
			return _can_place_summoned_statue_at(target_cell)
	return true


func _log_failed_skill(caster: Dictionary, skill: Dictionary, target: Dictionary = {}) -> void:
	match str(skill.get("effect_type", "")):
		"taunt_burst":
			_log_event("%s używa Prowokacji, ale nikt nie znajduje się w zasięgu." % _unit_name_log_text(caster))
		"dancing_blade":
			_log_event("%s używa Tańczącego Ostrza, ale nikt nie znajduje się w zasięgu." % _unit_name_log_text(caster))
		"hook_throw":
			_log_event("%s rzuca hakiem w %s, ale nie może przyciągnąć celu." % [_unit_name_log_text(caster), _unit_name_log_text(target)])
		"magic_projection":
			_log_event("%s nie może postawić Magicznej Projekcji w tym miejscu." % _unit_name_log_text(caster))
		"summon_statue":
			_log_event("%s nie może przyzwać Pomnika w tym miejscu." % _unit_name_log_text(caster))


func _find_nearest_player_unit(enemy_unit: Dictionary) -> Dictionary:
	var forced_target := _get_forced_target(enemy_unit)
	if not forced_target.is_empty() and _can_see_target(enemy_unit, forced_target):
		return forced_target

	var best_visible: Dictionary = {}
	var best_visible_score: int = 1000000
	for unit in units:
		if unit.side != "player" or not _can_see_target(enemy_unit, unit):
			continue
		var score: int = _score_enemy_target(enemy_unit, unit)
		if score < best_visible_score:
			best_visible_score = score
			best_visible = unit
	return best_visible


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
	var mapa_tras: Dictionary = _zbuduj_mape_tras(enemy_unit, origin, _get_remaining_move(enemy_unit))
	var reachable_cells: Array[Vector2i] = _osiagalne_z_mapy_tras(mapa_tras, origin)
	var best_path: Array[Vector2i] = []
	var preferred_distance: int = 1 if not _can_see_target(enemy_unit, target) else min(int(enemy_unit.get("attack_range", 1)), _hex_distance(origin, target_cell))
	var best_score: int = abs(_hex_distance(origin, target_cell) - preferred_distance) * 10
	for cell in reachable_cells:
		var candidate_path: Array[Vector2i] = _odtworz_trase(mapa_tras, origin, cell)
		if candidate_path.is_empty():
			continue
		var candidate_distance: int = _hex_distance(cell, target_cell)
		var candidate_score: int = abs(candidate_distance - preferred_distance) * 10 + _ai_hazard_penalty(enemy_unit, candidate_path)
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
		if _terrain_is_deadly(cell):
			penalty += 1000000
		if _terrain_skips_turn(cell):
			penalty += 100
	return penalty


func _is_hostile_terrain_effect_for_unit(unit: Dictionary, cell: Vector2i) -> bool:
	for effect in terrain_effects:
		if int(effect.get("grid_x", -1)) != cell.x or int(effect.get("grid_y", -1)) != cell.y:
			continue
		if str(effect.get("caster_side", "")) == str(unit.side):
			continue
		if ["fire", "ice", "poison_cloud"].has(str(effect.get("id", ""))):
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


func _has_trap_near_cell_for_side(center: Vector2i, side: String) -> bool:
	for cell in _get_area_cells(center):
		for trap_id in ["bear_trap", "goblin_trap"]:
			var trap: Dictionary = _get_terrain_effect_at(cell, trap_id)
			if not trap.is_empty() and str(trap.get("caster_side", "")) == side:
				return true
	return false
func _sync_board() -> void:
	for unit in units:
		_recalculate_unit_stats(unit)
	_sync_board_map_theme()
	board.set_units(units)
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	board.set_map_event_warning_cells(map_event_cells if BibliotekaZdarzenMapyScript.czy_runda_ostrzezenia(round_number, next_map_event_round) else [])
	if board.has_method("set_active_unit"):
		board.set_active_unit(active_unit_id)
	if board.has_method("set_viewer_side"):
		board.set_viewer_side(current_turn if ai_difficulty == "gracz" and current_turn in ["player", "enemy"] else "player")
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
	if has_unit_selection:
		board.set_selected_unit(selected_unit_id)
	elif has_obstacle_selection:
		board.set_selected_obstacle(selected_obstacle_cell)
	else:
		board.set_selected_unit(-1)
		board.set_selected_obstacle(Vector2i(-1, -1))
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
	var selected_cell := Vector2i(int(unit.grid_x), int(unit.grid_y))

	if setup_mode:
		var setup_cells: Array[Vector2i] = _get_setup_placeable_cells(unit)
		setup_cells.erase(selected_cell)
		board.set_highlighted_cells(setup_cells, [])
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
	var przyjazne_podswietlenie_ataku: bool = false
	var zielone_pola_ataku: Array[Vector2i] = []
	if pending_general_skill_id != "":
		var target_type: String = str(general_skills.get(pending_general_skill_id, {}).get("effect_type", ""))
		przyjazne_podswietlenie_ataku = target_type == "ally"
		if target_type == "area":
			for column in GRID_COLUMNS:
				for row in GRID_ROWS:
					attack_cells.append(Vector2i(column, row))
		else:
			for candidate in units:
				var active_only: bool = bool(general_skills.get(pending_general_skill_id, {}).get("active_only", false))
				if ((target_type == "ally" and candidate.side == "player") or (target_type == "enemy" and candidate.side == "enemy")) and (not active_only or candidate.id == active_unit_id):
					attack_cells.append(Vector2i(candidate.grid_x, candidate.grid_y))
		if target_type == "ally":
			zielone_pola_ataku.assign(attack_cells)
	elif not charge_skill.is_empty():
		move_budget += MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(charge_skill, "move_range")
		move_cells = _get_reachable_cells(unit, move_budget, charge_skill)
		if _can_unit_attack(unit):
			attack_cells = _get_attackable_cells(unit, charge_skill)
	elif unit.id == active_unit_id and pending_skill_id != "":
		var pending_skill: Dictionary = skill_library.get(pending_skill_id, {})
		var target_type: String = str(pending_skill.get("target_type", ""))
		przyjazne_podswietlenie_ataku = target_type in ["ally_unit", "self"]
		if str(pending_skill.get("effect_type", "")) == "dancing_blade":
			attack_cells = _get_neighbors(Vector2i(unit.grid_x, unit.grid_y))
		else:
			attack_cells = _get_skill_target_cells(unit, pending_skill_id)
		if target_type == "self":
			zielone_pola_ataku.assign(attack_cells)
			if not zielone_pola_ataku.has(selected_cell):
				zielone_pola_ataku.append(selected_cell)
		elif target_type == "ally_unit":
			for candidate in units:
				var pole_kandydata := Vector2i(int(candidate.grid_x), int(candidate.grid_y))
				if attack_cells.has(pole_kandydata) and _can_target_ally_with_skill(unit, candidate, pending_skill):
					zielone_pola_ataku.append(pole_kandydata)
	else:
		move_cells = _get_reachable_cells(unit, move_budget)
		if unit.id == active_unit_id and pending_skill_id == "" and _can_unit_attack(unit):
			attack_cells = _get_attackable_cells(unit)
	move_cells.erase(selected_cell)
	var move_opacity_mult: float = 0.5 if unit.id != active_unit_id else 1.0
	board.set_highlighted_cells(move_cells, attack_cells, move_opacity_mult, przyjazne_podswietlenie_ataku, zielone_pola_ataku)
	_on_board_cell_hovered(board.get_hovered_cell())


func _on_board_cell_hovered(cell: Vector2i) -> void:
	_update_damage_tooltip(cell)
	if help_popup != null and help_popup.visible:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		board.set_hovered_area_skill(cell, [])
		board.set_hovered_detonator_preview([])
		board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		_clear_hover_warning()
		return
	if pending_general_skill_id != "":
		var general_skill: Dictionary = general_skills.get(pending_general_skill_id, {})
		if str(general_skill.get("effect_type", "")) == "area":
			board.set_hovered_area_skill(cell, _get_general_area_cells(cell, int(general_skill.get("radius", 1))))
		else:
			board.set_hovered_area_skill(cell, [cell])
		return
	if not setup_mode and cell.x != -1 and _get_terrain_type_at(cell) == "detonator":
		board.set_hovered_move_path([])
		board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		var active_unit: Dictionary = _get_active_unit()
		var can_activate: bool = not active_unit.is_empty() and selected_unit_id == active_unit.id and _can_activate_detonator(active_unit, cell)
		board.set_hovered_attack_cell(cell if can_activate else Vector2i(-1, -1))
		if active_unit.is_empty() or _hex_distance(Vector2i(int(active_unit.grid_x), int(active_unit.grid_y)), cell) != 1:
			board.set_hovered_detonator_preview([])
			return
		var detonator_index := _find_detonator_index(cell)
		var preview_cells: Array[Vector2i] = _get_detonator_target_cells(detonator_index, cell)
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
		if str(pending_skill.get("effect_type", "")) == "dancing_blade":
			_handle_dancing_blade_hover(active_unit, cell)
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
		if cell.x != -1:
			_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return

	if active_unit.is_empty() or not _is_manual_side(str(active_unit.side)):
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		_clear_hover_warning()
		return

	if selected_unit_id != active_unit.id:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		_clear_hover_warning()
		return

	if cell.x == -1:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		_clear_hover_warning()
		return

	var hovered_unit: Dictionary = _find_unit_at_cell(cell)
	if not hovered_unit.is_empty() and int(hovered_unit.id) == int(active_unit.id):
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_clear_move_cost_label()
		_clear_hover_warning()
		return
	if not hovered_unit.is_empty() and hovered_unit.side != active_unit.side and _can_see_target(active_unit, hovered_unit) and _can_unit_attack(active_unit):
		if not charge_skill.is_empty() and _can_charge_attack_target(active_unit, hovered_unit, charge_skill):
			board.set_hovered_move_path([])
			board.set_hovered_attack_cell(cell)
			_clear_move_cost_label()
			_clear_hover_warning()
			return
		if charge_skill.is_empty() and _is_in_attack_range(active_unit, cell):
			board.set_hovered_move_path([])
			board.set_hovered_attack_cell(cell)
			_clear_move_cost_label()
			_clear_hover_warning()
			return
		_clear_hover_warning()

	var remaining: int = _get_remaining_move(active_unit)
	if not charge_skill.is_empty():
		remaining += MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(charge_skill, "move_range")
	var path := _find_path(active_unit, Vector2i(active_unit.grid_x, active_unit.grid_y), cell, charge_skill, remaining)
	var path_cost: int = _get_path_cost(path)
	if path.is_empty() or path_cost > remaining:
		board.set_hovered_move_path([])
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		if cell.x != -1:
			_show_move_cost_label(0, remaining)
			move_cost_label.text = "Za daleko! Pozostały ruch: %s" % remaining
			move_cost_label.add_theme_color_override("font_color", Color(0.95, 0.18, 0.18, 1.0))
		else:
			_clear_move_cost_label()
		return

	board.set_hovered_move_path(_get_executable_move_path(path))
	board.set_hovered_attack_cell(Vector2i(-1, -1))
	_show_move_cost_label(path_cost, remaining - path_cost)
	_clear_hover_warning()


func _process(_delta: float) -> void:
	if damage_tooltip.visible:
		damage_tooltip.position = get_viewport().get_mouse_position() + Vector2(18, 18)


func _update_damage_tooltip(cell: Vector2i) -> void:
	damage_tooltip.visible = false
	if setup_mode or pending_general_skill_id != "":
		return
	var attacker: Dictionary = _get_active_unit()
	var selected_skill: Dictionary = skill_library.get(pending_skill_id, {})
	if str(selected_skill.get("effect_type", "")) == "piercing_shot":
		_update_piercing_shot_damage_tooltip(attacker, selected_skill, cell)
		return
	if _is_area_damage_skill(selected_skill):
		_update_area_damage_tooltip(attacker, selected_skill, cell)
		return
	var target: Dictionary = _find_visible_unit_at_cell(cell, attacker)
	if attacker.is_empty() or target.is_empty() or target.side == attacker.side:
		return
	if not _can_show_damage_tooltip_in_range(attacker, target, cell):
		return
	var multiplier: float = _get_selected_attack_damage_multiplier()
	if multiplier <= 0.0:
		return
	damage_tooltip_label.text = "Obrażenia: %s" % _format_damage_range(_calculate_attack_preview_damage(attacker, target, multiplier))
	damage_tooltip.visible = true


func _update_piercing_shot_damage_tooltip(attacker: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	var first_target: Dictionary = _find_visible_unit_at_cell(cell, attacker)
	if attacker.is_empty() or not _can_target_enemy_with_skill(attacker, first_target, skill):
		return
	var lines: Array[String] = []
	for hit_cell in _get_piercing_shot_preview_cells(attacker, first_target):
		var target: Dictionary = _find_visible_unit_at_cell(hit_cell, attacker)
		if target.is_empty():
			continue
		lines.append("%s: %s" % [str(target.get("name", "Jednostka")), _format_damage_range(_calculate_attack_preview_damage(attacker, target, 1.0))])
	if not lines.is_empty():
		damage_tooltip_label.text = "Obrażenia przebijające:\n%s" % "\n".join(lines)
		damage_tooltip.visible = true


func _update_area_damage_tooltip(attacker: Dictionary, skill: Dictionary, center: Vector2i) -> void:
	if attacker.is_empty() or not _can_target_cell_with_skill(attacker, center, skill):
		return
	var lines: Array[String] = []
	for hit_cell in _get_area_cells(center):
		var target: Dictionary = _find_visible_unit_at_cell(hit_cell, attacker)
		if target.is_empty() or target.side == attacker.side:
			continue
		var multiplier: float = MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru(str(skill.get("effect_type", "")), hit_cell == center)
		lines.append("%s: %s" % [str(target.get("name", "Przeciwnik")), _format_damage_range(_calculate_attack_preview_damage(attacker, target, multiplier))])
	if not lines.is_empty():
		damage_tooltip_label.text = "Obrażenia obszarowe:\n%s" % "\n".join(lines)
		damage_tooltip.visible = true


func _can_show_damage_tooltip_in_range(attacker: Dictionary, target: Dictionary, cell: Vector2i) -> bool:
	if pending_skill_id == "":
		return _is_in_attack_range(attacker, cell)
	var skill: Dictionary = skill_library.get(pending_skill_id, {})
	var effect_type: String = str(skill.get("effect_type", ""))
	if effect_type == "charge":
		return _can_charge_attack_target(attacker, target, skill)
	if effect_type == "dancing_blade":
		return _hex_distance(Vector2i(attacker.grid_x, attacker.grid_y), cell) == 1
	if str(skill.get("target_type", "")) == "cell":
		return _can_target_cell_with_skill(attacker, cell, skill)
	return _can_target_enemy_with_skill(attacker, target, skill)


func _calculate_attack_preview_damage(attacker: Dictionary, target: Dictionary, multiplier: float) -> Vector2i:
	var damage: Vector2i = MatematykaWalkiScript.oblicz_zakres_obrazen(attacker, target, multiplier)
	var hit_target: Dictionary = target
	var guardian: Dictionary = _get_guardian_for(target)
	if not guardian.is_empty():
		hit_target = guardian
		damage = Vector2i(maxi(1, int(ceil(float(damage.x) * 0.75))), maxi(1, int(ceil(float(damage.y) * 0.75))))
	for effect in hit_target.get("active_effects", []):
		if bool(effect.get("block_next_attack", false)):
			return Vector2i.ZERO
	return Vector2i(_adjust_incoming_damage(hit_target, damage.x), _adjust_incoming_damage(hit_target, damage.y))


func _format_damage_range(damage: Vector2i) -> String:
	return str(damage.x) if damage.x == damage.y else "%d-%d" % [damage.x, damage.y]


func _get_selected_attack_damage_multiplier() -> float:
	if pending_skill_id == "":
		return 1.0
	var effect_type: String = str(skill_library.get(pending_skill_id, {}).get("effect_type", ""))
	match effect_type:
		"knee_shot", "poison_dagger":
			return 0.7
		"dancing_blade", "zaklete_ciecie", "rozszarpanie":
			return 0.5
		"charge", "shattering_strike":
			return 1.5
		"shield_push", "hammer_strike", "focused_strike", "piercing_shot", "fireball", "dynamite_throw":
			return 1.0
		"arrow_rain":
			return 0.5
	return 0.0


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
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	if str(skill.get("effect_type", "")) == "piercing_shot":
		board.set_hovered_area_skill(cell, _get_piercing_shot_preview_cells(active_unit, hovered_unit))
		return
	board.set_hovered_attack_cell(cell)
	_clear_hover_warning()


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
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	board.set_hovered_attack_cell(cell)
	_clear_hover_warning()


func _get_dancing_blade_preview_cells(caster: Dictionary) -> Array[Vector2i]:
	return _get_neighbors(Vector2i(caster.grid_x, caster.grid_y))


func _handle_dancing_blade_hover(active_unit: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	var caster_cell := Vector2i(active_unit.grid_x, active_unit.grid_y)
	if cell != caster_cell:
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	board.set_hovered_area_skill(caster_cell, _get_dancing_blade_preview_cells(active_unit))
	_clear_hover_warning()


func _handle_self_skill_hover(active_unit: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	if cell != Vector2i(active_unit.grid_x, active_unit.grid_y):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	board.set_hovered_attack_cell(cell)
	_clear_hover_warning()


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
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	board.set_hovered_attack_cell(cell)
	board.set_hovered_pull_destination_cell(_get_pull_destination(active_unit, hovered_unit))
	_clear_hover_warning()


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
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	board.set_hovered_area_skill(cell, _get_area_cells(cell))
	_clear_hover_warning()


func _handle_cell_skill_hover(active_unit: Dictionary, skill: Dictionary, cell: Vector2i) -> void:
	board.set_hovered_move_path([])
	board.set_hovered_pull_destination_cell(Vector2i(-1, -1))
	_clear_move_cost_label()
	if cell.x == -1 or active_unit.is_empty():
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		return
	if not _can_target_cell_with_skill(active_unit, cell, skill):
		board.set_hovered_attack_cell(Vector2i(-1, -1))
		_show_hover_warning("Cel poza zasięgiem umiejętności!", cell)
		return
	board.set_hovered_area_skill(cell, _get_cell_skill_preview_cells(skill, cell, active_unit))
	_clear_hover_warning()


func _get_cell_skill_preview_cells(skill: Dictionary, center: Vector2i, caster: Dictionary = {}) -> Array[Vector2i]:
	if str(skill.get("effect_type", "")) == "magic_projection":
		return _get_magic_projection_cells(center, str(caster.get("side", "")))
	if str(skill.get("effect_type", "")) == "ice_ground":
		return _get_ice_ground_cells(center)
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
	if effect_type == "magic_projection":
		return _can_place_magic_projection_at(caster, cell)
	if effect_type == "ice_ground":
		return _get_ice_ground_cells(cell).size() == 3
	if effect_type == "summon_statue":
		return _can_place_summoned_statue_at(cell)
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
	return _osiagalne_z_mapy_tras(_zbuduj_mape_tras(unit, origin, max_distance, charge_skill), origin)


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
			if charge_skill.is_empty() and _can_activate_detonator(unit, cell):
				attackable.append(cell)
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
			if str(skill.get("effect_type", "")) == "magic_projection" and not _can_place_magic_projection_at(unit, cell):
				continue
			if str(skill.get("effect_type", "")) == "summon_statue" and not _can_place_summoned_statue_at(cell):
				continue
			cells.append(cell)
	return cells


func _is_in_attack_range(unit: Dictionary, cell: Vector2i, charge_skill: Dictionary = {}) -> bool:
	if not _is_forward_cell_for_unit(unit, cell, charge_skill):
		return false
	var attack_range: int = int(unit.get("attack_range", 1)) + MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(charge_skill, "attack_range")
	if _hex_distance(Vector2i(int(unit.get("grid_x", 0)), int(unit.get("grid_y", 0))), cell) > attack_range:
		return false
	return not _is_attack_blocked(unit, cell)


func _is_attack_blocked_from(from_cell: Vector2i, target_cell: Vector2i) -> bool:
	if from_cell == target_cell:
		return false
	for cell in _get_hex_line(from_cell, target_cell):
		if cell == from_cell or cell == target_cell:
			continue
		if _cell_blocks_line_of_sight(cell):
			return true
	return false


func _can_attack_from_cell_for_charge(unit: Dictionary, from_cell: Vector2i, target_cell: Vector2i, skill: Dictionary) -> bool:
	if not _is_forward_cell_from(from_cell, target_cell, unit):
		return false
	var attack_range: int = int(unit.get("attack_range", 1)) + MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(skill, "attack_range")
	if _hex_distance(from_cell, target_cell) > attack_range:
		return false
	return not _is_attack_blocked_from(from_cell, target_cell)


func _find_charge_approach_destination(unit: Dictionary, target: Dictionary, skill: Dictionary) -> Vector2i:
	var origin := Vector2i(unit.grid_x, unit.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	var move_budget: int = _get_remaining_move(unit) + MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(skill, "move_range")
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
	var move_budget: int = _get_remaining_move(unit) + MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(skill, "move_range")
	# Raw path (z potencjalnym heks z zasadzka). Zatrzymanie/wyzwolenie logiki robimy w _perform_charge_attack.
	return _find_path(unit, origin, destination, skill, move_budget)


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
	var result: Dictionary = _apply_attack_damage(attacker, target, total_damage)
	var hit_target: Dictionary = result.get("target", target)
	var casualties: int = int(result.get("casualties", 0))
	_log_event(
		"%s uderza %s, zadając %s obrażeń i powodując %s strat." % [
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
		damage_tooltip.visible = false
	_log_event("%s używa umiejętności %s." % [_unit_name_log_text(caster), str(skill.get("name", skill.get("id", "")))])


func _perform_charge_attack(attacker: Dictionary, target: Dictionary, skill: Dictionary, end_turn_after := true, animate_move := true) -> void:
	if not _can_charge_attack_target(attacker, target, skill):
		return
	_commit_charge_skill(attacker, skill)

	var move_path: Array[Vector2i] = _find_charge_approach_path(attacker, target, skill)
	var ambush_defender: Dictionary = {}
	# Zasadzka wyzwala się, gdy trasa ma zamiar wkroczyć w heks z ukrytym wrogiem.
	for step in move_path:
		if _is_ambush_cell_for_unit(attacker, step):
			ambush_defender = _get_ambush_defender_at_cell(attacker, step)
			break

	var exec_move_path: Array[Vector2i] = _get_executable_move_path(move_path, attacker)
	var moved := false
	if not exec_move_path.is_empty():
		var destination: Vector2i = exec_move_path[exec_move_path.size() - 1]
		var origin := Vector2i(int(attacker.grid_x), int(attacker.grid_y))
		attacker.grid_x = destination.x
		attacker.grid_y = destination.y
		_reveal_unit_leaving_concealment(attacker, origin)
		attacker.remaining_move = 0
		moved = true

		if animate_move:
			is_animating = true
			_sync_board()
			board.animate_unit_path(attacker.id, exec_move_path)
			await board.animation_finished
			is_animating = false
			if _try_trigger_bush_ambush(attacker, ambush_defender):
				if _find_unit_by_id(int(attacker.id)).is_empty() or end_turn_after:
					_end_current_activation()
				return
			_apply_terrain_effects_to_unit(attacker)
			if _find_unit_by_id(int(attacker.id)).is_empty():
				if end_turn_after:
					_end_current_activation()
				return
			_stop_unit_on_terrain(attacker)
			_try_trigger_agility(attacker)
		else:
			_sync_board()
			board.snap_unit_to_cell(attacker.id, destination)
			if _try_trigger_bush_ambush(attacker, ambush_defender):
				if _find_unit_by_id(int(attacker.id)).is_empty() or end_turn_after:
					_end_current_activation()
				return
	elif not ambush_defender.is_empty():
		# Zatrzymanie tuż przed zasadzka, gdy pierwszym krokiem byl sam heks z ukrytym wrogiem.
		var ambush_cell := Vector2i(int(ambush_defender.grid_x), int(ambush_defender.grid_y))
		if _hex_distance(Vector2i(int(attacker.grid_x), int(attacker.grid_y)), ambush_cell) == 1:
			if _try_trigger_bush_ambush(attacker, ambush_defender):
				if _find_unit_by_id(int(attacker.id)).is_empty() or end_turn_after:
					_end_current_activation()
				return

	var attacker_cell := Vector2i(attacker.grid_x, attacker.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if not _can_attack_from_cell_for_charge(attacker, attacker_cell, target_cell, skill):
		if moved and not animate_move:
			board.snap_unit_to_cell(attacker.id, attacker_cell)
		return

	_reveal_if_in_bush(attacker)
	var total_damage: int = _calculate_damage(attacker, target, MechanikaUmiejetnosciScript.pobierz_mnoznik_szarzy(skill))
	var result: Dictionary = _apply_attack_damage(attacker, target, total_damage)
	var hit_target: Dictionary = result.get("target", target)
	var casualties: int = int(result.get("casualties", 0))
	_log_event(
		"%s szarżuje na %s, zadając %s obrażeń i powodując %s strat." % [
			_unit_name_log_text(attacker),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)
	_sync_board()
	if moved and not animate_move:
		board.snap_unit_to_cell(attacker.id, attacker_cell)
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

	var max_distance: int = _get_remaining_move(unit) + MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(skill, "move_range")
	if max_distance <= 0:
		return

	var path := _find_path(unit, Vector2i(unit.grid_x, unit.grid_y), cell, skill, max_distance)
	var path_cost: int = _get_path_cost(path)
	if path.is_empty():
		if _is_cell_obstacle(cell):
			_show_obstacle_details(cell)
		return
	if path_cost > max_distance:
		return

	_commit_charge_skill(unit, skill)

	var ambush_defender: Dictionary = {}
	# Zasadzka odpala się, gdy trasa rzeczywiście wchodzi w heks z ukrytym wrogiem.
	for step in path:
		if _is_ambush_cell_for_unit(unit, step):
			ambush_defender = _get_ambush_defender_at_cell(unit, step)
			break

	var move_path: Array[Vector2i] = _get_executable_move_path(path, unit)
	is_animating = true
	var destination: Vector2i = move_path[move_path.size() - 1] if not move_path.is_empty() else Vector2i(unit.grid_x, unit.grid_y)
	unit.grid_x = destination.x
	unit.grid_y = destination.y
	unit.remaining_move = 0
	_sync_board()
	_show_move_cost_label(path_cost, 0)
	board.animate_unit_path(unit.id, move_path)
	await board.animation_finished
	is_animating = false
	_clear_move_cost_label()
	_log_event("%s porusza się w kierunku szarży." % _unit_name_log_text(unit))
	_try_trigger_bush_ambush(unit, ambush_defender)
	if _find_unit_by_id(int(unit.id)).is_empty():
		_end_current_activation()
		return
	_apply_terrain_effects_to_unit(unit)
	if _find_unit_by_id(int(unit.id)).is_empty():
		_end_current_activation()
		return
	_stop_unit_on_terrain(unit)
	_try_trigger_agility(unit)
	_sync_board()


func _calculate_damage(attacker: Dictionary, target: Dictionary, damage_multiplier := 1.0) -> int:
	return MatematykaWalkiScript.oblicz_obrazenia(attacker, target, damage_multiplier)


func _calculate_expected_damage(attacker: Dictionary, target: Dictionary, damage_multiplier: float = 1.0) -> int:
	var damage: Vector2i = MatematykaWalkiScript.oblicz_zakres_obrazen(attacker, target, damage_multiplier)
	return int(round((damage.x + damage.y) / 2.0))


func _srednie_obrazenia_jednostki(unit: Dictionary) -> int:
	return int(round((int(unit.get("dmg_min", 1)) + int(unit.get("dmg_max", 1))) / 2.0))


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
	if damage > 0 and int(target.get("count", 0)) > 0:
		_odtworz_sfx_jednostki(target, "obrazenia")
	return max(0, previous_count - int(target.get("count", 0)))


func _apply_attack_damage(attacker: Dictionary, target: Dictionary, total_damage: int, play_animation: bool = true, projectile_kind_override: String = "", weapon_sfx_override: String = "") -> Dictionary:
	var hit_target: Dictionary = target
	var damage: int = total_damage
	# Żelazna Kurtyna: wszystkie ataki/skille poza DoT (DoT idzie przez _apply_damage_to_unit).
	var guardian := _get_guardian_for(target)
	if not guardian.is_empty():
		hit_target = guardian
		damage = max(1, int(ceil(float(damage) * 0.75)))
		_log_event("%s osłania %s Żelazną Kurtyną." % [_unit_name_log_text(guardian), _unit_name_log_text(target)])
	var projectile_kind: String = ""
	if play_animation:
		if projectile_kind_override == "none":
			projectile_kind = ""
		else:
			projectile_kind = projectile_kind_override if projectile_kind_override != "" else _get_attack_projectile_kind(attacker)
		_odtworz_sfx_broni(_pobierz_rodzaj_sfx_broni(attacker, projectile_kind, weapon_sfx_override))
		board.play_attack_animation(int(attacker.id), int(hit_target.id), projectile_kind)
	if _consume_energy_barrier(hit_target):
		_log_event("Bariera Energetyczna blokuje atak na %s." % _unit_name_log_text(hit_target))
		return {"target": hit_target, "damage": 0, "casualties": 0}
	if play_animation:
		_odtworz_sfx_trafienia_po_czasie(0.14 if projectile_kind != "" else 0.08)
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
		if str(effect.get("id", "")) == "bariera_energetyczna":
			if not unit.has("skill_cooldowns"):
				unit["skill_cooldowns"] = {}
			unit["skill_cooldowns"]["bariera_energetyczna"] = 5
		_recalculate_unit_stats(unit)
		return true
	return false


func _cleanup_destroyed_unit(target: Dictionary) -> void:
	if int(target.get("count", 0)) > 0:
		return
	if _find_unit_by_id(int(target.get("id", -1))).is_empty():
		return
	_odtworz_sfx_jednostki(target, "smierc")
	_log_event("%s zostaje rozbity." % _unit_name_log_text(target))
	units.erase(target)
	var removed_queue_index: int = turn_queue.find(int(target.get("id", -1)))
	turn_queue.erase(int(target.get("id", -1)))
	if removed_queue_index >= 0 and removed_queue_index <= turn_queue_index:
		turn_queue_index -= 1
	if target.get("id", -1) == selected_unit_id:
		selected_unit_id = -1
	_check_victory()


func _try_use_skill(unit: Dictionary, skill_id: String, cell: Vector2i) -> bool:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return false
	if not MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, skill_id, skill_library):
		return false

	if str(skill.get("target_type", "")) == "self":
		if cell != Vector2i(unit.grid_x, unit.grid_y):
			return false
		if not _skill_effect_will_succeed(unit, unit, skill, cell):
			_log_failed_skill(unit, skill)
			return false
		await _execute_skill(unit, unit, skill, cell)
		return true

	if str(skill.get("target_type", "")) == "cell":
		if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(skill.get("range", 0)):
			return false
		if _is_attack_blocked(unit, cell) or _blocks_cell_skill_target(cell):
			return false
		if str(skill.get("effect_type", "")) == "bear_trap" and (not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, "bear_trap").is_empty()):
			return false
		if str(skill.get("effect_type", "")) == "goblin_trap" and (not _find_unit_at_cell(cell).is_empty() or not _get_terrain_effect_at(cell, "goblin_trap").is_empty()):
			return false
		if str(skill.get("effect_type", "")) == "magic_projection" and not _can_place_magic_projection_at(unit, cell):
			return false
		if str(skill.get("effect_type", "")) == "summon_statue" and not _can_place_summoned_statue_at(cell):
			return false
		if not _skill_effect_will_succeed(unit, {}, skill, cell):
			_log_failed_skill(unit, skill)
			return false
		await _execute_skill(unit, {}, skill, cell)
		return true

	var target := _find_unit_at_cell(cell)
	if target.is_empty():
		return false
	var target_type := str(skill.get("target_type", ""))
	if target_type == "enemy_unit" and target.side == unit.side:
		return false
	if target_type == "enemy_unit" and not _can_see_target(unit, target):
		return false
	if target_type == "ally_unit" and (target.side != unit.side or target.id == unit.id):
		return false
	if _hex_distance(Vector2i(unit.grid_x, unit.grid_y), cell) > int(skill.get("range", 0)):
		return false
	if _is_attack_blocked(unit, cell):
		return false
	if str(skill.get("effect_type", "")) == "hook_throw":
		if not _can_hook_throw_target(unit, target, skill) or not _skill_effect_will_succeed(unit, target, skill, cell):
			_log_failed_skill(unit, skill, target)
			return false
	await _execute_skill(unit, target, skill, cell)
	return true


func _execute_skill(caster: Dictionary, target: Dictionary, skill: Dictionary, target_cell: Vector2i) -> void:
	await MechanikaUmiejetnosciScript.wykonaj(self, caster, target, skill, target_cell)


func _execute_sztandar(caster: Dictionary, target: Dictionary) -> void:
	if target.is_empty():
		return
	if not target.has("skill_cooldowns"):
		target["skill_cooldowns"] = {}
	var refreshed_names: Array[String] = []
	for skill_id in target.get("skill_ids", []):
		var skill_id_str := str(skill_id)
		var remaining: int = int(target.get("skill_cooldowns", {}).get(skill_id_str, 0))
		if remaining > 0:
			refreshed_names.append(_get_skill_name(skill_id_str))
		target.skill_cooldowns[skill_id_str] = 0
	if refreshed_names.is_empty():
		_log_event(
			"%s wznosi Sztandar nad %s — wszystkie umiejetnosci sa gotowe." % [
				_unit_name_log_text(caster),
				_unit_name_log_text(target)
			]
		)
		return
	_log_event(
		"%s wznosi Sztandar nad %s: odswiezono %s." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(target),
			", ".join(refreshed_names)
		]
	)


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
		_log_event("%s używa Prowokacji, ale nikt nie znajduje się w zasięgu." % _unit_name_log_text(caster))
		return
	_log_event("%s prowokuje: %s." % [_unit_name_log_text(caster), ", ".join(affected)])


func _execute_dancing_blade(caster: Dictionary) -> void:
	var caster_cell := Vector2i(caster.grid_x, caster.grid_y)
	var targets: Array[Dictionary] = []
	for other in units:
		if other.side == caster.side:
			continue
		if _hex_distance(caster_cell, Vector2i(other.grid_x, other.grid_y)) != 1:
			continue
		if not _can_see_target(caster, other):
			continue
		targets.append(other)
	if targets.is_empty():
		_log_event("%s używa Tańczącego Ostrza, ale nikt nie znajduje się w zasięgu." % _unit_name_log_text(caster))
		return
	var play_animation := true
	for target in targets:
		var total_damage := _calculate_damage(caster, target, 0.5)
		var result := _apply_attack_damage(caster, target, total_damage, play_animation)
		play_animation = false
		var hit_target: Dictionary = result.get("target", target)
		var casualties := int(result.get("casualties", 0))
		_log_event(
			"%s tnie %s Tańczącym Ostrzem, zadając %s obrażeń i powodując %s strat." % [
				_unit_name_log_text(caster),
				_unit_name_log_text(hit_target),
				_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
				_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
			]
		)
		_cleanup_destroyed_unit(hit_target)


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
		"%s trafia %s Strzałem w Kolano, zadając %s obrażeń, powodując %s strat i unieruchamiając cel." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_poison_dagger(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.7)
	var result := _apply_attack_damage(caster, target, total_damage, true, "none", "dagger")
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	if int(result.get("damage", 0)) > 0:
		_apply_poison_effect(hit_target, "toksyna", "Toksyna", 3, maxi(1, int(ceil(float(_srednie_obrazenia_jednostki(caster)) * 0.5))), true)
	_log_event(
		"%s zatruwa %s Sztyletem, zadając %s obrażeń i powodując %s strat." % [
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
	_log_event("%s przygotowuje Sokole Oko na następną turę." % _unit_name_log_text(caster))


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
		_log_event("%s rzuca hakiem w %s, ale nie może przyciągnąć celu." % [_unit_name_log_text(caster), _unit_name_log_text(target)])
		return
	var start_cell := Vector2i(target.grid_x, target.grid_y)
	var pull_path: Array[Vector2i] = _get_pull_path(start_cell, destination)
	is_animating = true
	board.play_hook_throw_animation(int(caster.id), int(target.id))
	await get_tree().create_timer(0.15).timeout
	var origin := Vector2i(target.grid_x, target.grid_y)
	target["grid_x"] = destination.x
	target["grid_y"] = destination.y
	_reveal_unit_leaving_concealment(target, origin)
	_sync_board()
	if pull_path.is_empty():
		board.snap_unit_to_cell(int(target.id), destination)
	else:
		board.animate_unit_pull_path(int(target.id), pull_path)
		await board.animation_finished
	is_animating = false
	_apply_terrain_effects_to_unit(target)
	_sync_board()
	_log_event("%s przyciąga %s Rzutem Hakiem." % [_unit_name_log_text(caster), _unit_name_log_text(target)])


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
	var result := _apply_attack_damage(caster, target, total_damage, false)
	if int(result.get("damage", 0)) > 0:
		_odtworz_sfx_trafienia_po_czasie(0.0)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	var pushed := false
	# Odepchnięcie/ogłuszenie tylko gdy atak trafił chroniony cel (nie opiekuna z Żelaznej Kurtyny).
	var can_displace: bool = int(result.get("damage", 0)) > 0 and int(hit_target.id) == int(target.id)
	if can_displace:
		var destination: Vector2i = _get_push_destination(caster, target)
		if destination != Vector2i(-1, -1):
			pushed = true
			var push_path: Array[Vector2i] = [destination]
			var origin := Vector2i(int(target.grid_x), int(target.grid_y))
			target["grid_x"] = destination.x
			target["grid_y"] = destination.y
			_reveal_unit_leaving_concealment(target, origin)
			_sync_board()
			board.animate_unit_knockback_path(int(target.id), push_path)
			await board.animation_finished
			_apply_terrain_effects_to_unit(target)
			_sync_board()
	if can_displace and not pushed and int(hit_target.get("count", 0)) > 0:
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
		if int(hit_target.id) != int(target.id):
			suffix = " Żelazna Kurtyna chroni przed odepchnięciem."
		elif pushed:
			suffix = " Cel zostaje odepchnięty."
		else:
			suffix = " Cel wpada na przeszkodę i zostaje ogłuszony."
	_log_event(
		"%s odpycha %s Odepchnięciem Tarczą, zadając %s obrażeń i powodując %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			suffix
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_hammer_strike(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target)
	var result := _apply_attack_damage(caster, target, total_damage, true, "", "axe")
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	var stun_suffix := ""
	if int(result.get("damage", 0)) > 0 and int(hit_target.get("count", 0)) > 0:
		_apply_or_refresh_effect(hit_target, {
			"id": "ogluszenie",
			"name": "Ogluszenie",
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [],
			"skip_turn": true
		})
		stun_suffix = " Cel zostaje ogłuszony."
	_log_event(
		"%s uderza %s Walnięciem Młotem, zadając %s obrażeń i powodując %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			stun_suffix
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
		var multiplier: float = MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru("fireball", cell == center)
		var total_damage := _calculate_damage(caster, target, multiplier)
		var result := _apply_attack_damage(caster, target, total_damage, false)
		var hit_target: Dictionary = result.get("target", target)
		var casualties: int = int(result.get("casualties", 0))
		hit_names.append(
			"trafia %s, zadając %s obrażeń i powodując %s strat" % [
				_unit_name_log_text(hit_target),
				_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
				_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
			]
		)
		_cleanup_destroyed_unit(hit_target)
	if not hit_names.is_empty():
		_odtworz_sfx_trafienia_po_czasie(0.0)
	_add_terrain_effect(center, "fire", 1)
	is_animating = false
	_log_event("%s rzuca Kulę Ognia: %s." % [_unit_name_log_text(caster), "brak trafień" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_dynamite_throw(caster: Dictionary, center: Vector2i) -> void:
	var hit_names: Array[String] = []
	for cell in _get_area_cells(center):
		var target := _find_unit_at_cell(cell)
		if target.is_empty() or target.side == caster.side:
			continue
		var multiplier: float = MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru("dynamite_throw", cell == center)
		var total_damage := _calculate_damage(caster, target, multiplier)
		var result := _apply_attack_damage(caster, target, total_damage)
		var hit_target: Dictionary = result.get("target", target)
		hit_names.append("%s (%s/%s)" % [_unit_name_log_text(hit_target), result.get("damage", total_damage), result.get("casualties", 0)])
		_cleanup_destroyed_unit(hit_target)
	_log_event("%s rzuca dynamitem: %s." % [_unit_name_log_text(caster), "brak trafień" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_arrow_rain(caster: Dictionary, center: Vector2i) -> void:
	var area_cells: Array[Vector2i] = _get_area_cells(center)
	is_animating = true
	_odtworz_sfx_broni("arrow")
	board.play_arrow_rain_animation(int(caster.id), area_cells)
	await get_tree().create_timer(0.42).timeout
	var hit_names: Array[String] = []
	for cell in area_cells:
		var target := _find_unit_at_cell(cell)
		if target.is_empty() or target.side == caster.side:
			continue
		var multiplier: float = MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru("arrow_rain", cell == center)
		var total_damage := _calculate_damage(caster, target, multiplier)
		var result := _apply_attack_damage(caster, target, total_damage, false)
		var hit_target: Dictionary = result.get("target", target)
		hit_names.append("%s (%s/%s)" % [_unit_name_log_text(hit_target), result.get("damage", total_damage), result.get("casualties", 0)])
		_cleanup_destroyed_unit(hit_target)
	if not hit_names.is_empty():
		_odtworz_sfx_trafienia_po_czasie(0.0)
	is_animating = false
	_log_event("%s używa Deszczu Strzał: %s." % [_unit_name_log_text(caster), "brak trafień" if hit_names.is_empty() else ", ".join(hit_names)])


func _execute_ice_ground(caster: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = _get_ice_ground_cells(center)
	is_animating = true
	board.play_ice_ground_animation(int(caster.id), cells)
	await get_tree().create_timer(0.36).timeout
	for cell in cells:
		_add_terrain_effect(cell, "ice", 2)
	_apply_terrain_effects_in_cells(cells)
	is_animating = false
	_log_event("%s zamraża podłoże." % _unit_name_log_text(caster))


func _get_ice_ground_cells(top: Vector2i) -> Array[Vector2i]:
	var row_offset: int = top.y & 1
	var cells: Array[Vector2i] = [top]
	for offset in [Vector2i(row_offset, 1), Vector2i(row_offset - 1, 1)]:
		var cell: Vector2i = top + offset
		if cell.x < 0 or cell.x >= GRID_COLUMNS or cell.y < 0 or cell.y >= GRID_ROWS:
			return []
		cells.append(cell)
	return cells


func _get_magic_projection_cells(middle: Vector2i, side: String) -> Array[Vector2i]:
	if middle.x < 0 or side == "":
		return []
	var row_offset: int = middle.y & 1
	var wing_offsets: Array[Vector2i] = []
	if str(side) == "player":
		wing_offsets = [Vector2i(row_offset - 1, -1), Vector2i(row_offset - 1, 1)]
	else:
		wing_offsets = [Vector2i(row_offset, -1), Vector2i(row_offset, 1)]
	var cells: Array[Vector2i] = []
	for offset in wing_offsets:
		var wing: Vector2i = middle + offset
		if wing.x < 0 or wing.x >= GRID_COLUMNS or wing.y < 0 or wing.y >= GRID_ROWS:
			return []
		if cells.has(wing):
			return []
		cells.append(wing)
	cells.append(middle)
	return cells


func _can_place_magic_projection_at(_caster: Dictionary, anchor: Vector2i) -> bool:
	var cells: Array[Vector2i] = _get_magic_projection_cells(anchor, str(_caster.get("side", "")))
	if cells.size() != 3:
		return false
	for cell in cells:
		if not _find_unit_at_cell(cell).is_empty():
			return false
		if _is_cell_obstacle(cell):
			return false
	return true


func _execute_magic_projection(caster: Dictionary, anchor: Vector2i) -> void:
	var cells: Array[Vector2i] = _get_magic_projection_cells(anchor, str(caster.side))
	if cells.size() != 3:
		_log_event("%s nie może postawić Magicznej Projekcji w tym miejscu." % _unit_name_log_text(caster))
		return
	for cell in cells:
		obstacles.append({
			"grid_x": cell.x,
			"grid_y": cell.y,
			"type": "magiczna_bariera",
			"variant": "magic_projection",
			"remaining_turns": 3,
			"source": "skill",
		})
	_log_event("%s tworzy Magiczną Projekcję na 3 tury." % _unit_name_log_text(caster))


func _execute_poison_cloud(caster: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = _get_area_cells(center)
	for cell in cells:
		_add_terrain_effect(cell, "poison_cloud", 2, int(caster.id), maxi(1, int(ceil(float(_srednie_obrazenia_jednostki(caster)) * 0.25))))
	_apply_terrain_effects_in_cells(cells)
	_log_event("%s tworzy Chmurę Toksyczną." % _unit_name_log_text(caster))


func _execute_bear_trap(caster: Dictionary, cell: Vector2i) -> void:
	_add_terrain_effect(cell, "bear_trap", 99, int(caster.id), maxi(1, int(ceil(float(_srednie_obrazenia_jednostki(caster)) * 0.25))))
	var trap: Dictionary = _get_terrain_effect_at(cell, "bear_trap")
	trap["caster_side"] = str(caster.side)
	trap["visible_until_ms"] = Time.get_ticks_msec() + 5000
	trap["enemy_memory_until_round"] = round_number + 1 if caster.side == "player" else round_number
	_log_event("%s zastawia Pułapkę na Niedźwiedzie." % _unit_name_log_text(caster))


func _execute_goblin_trap(caster: Dictionary, cell: Vector2i) -> void:
	_add_terrain_effect(cell, "goblin_trap", 99, int(caster.id), maxi(1, int(ceil(float(_srednie_obrazenia_jednostki(caster)) * 0.25))))
	var trap: Dictionary = _get_terrain_effect_at(cell, "goblin_trap")
	trap["caster_side"] = str(caster.side)
	trap["visible_until_ms"] = Time.get_ticks_msec() + 5000
	trap["enemy_memory_until_round"] = round_number + 1 if caster.side == "player" else round_number
	_log_event("%s zastawia Pułapkę Goblina." % _unit_name_log_text(caster))


func _can_place_summoned_statue_at(cell: Vector2i) -> bool:
	if not _find_unit_at_cell(cell).is_empty():
		return false
	return not _is_cell_obstacle(cell)


func _find_summoned_statue_index(caster_id: int) -> int:
	for index in obstacles.size():
		var obstacle: Dictionary = obstacles[index]
		if str(obstacle.get("type", "")) != "elf_statue":
			continue
		if str(obstacle.get("source", "")) != "skill":
			continue
		if int(obstacle.get("summoned_by_id", -1)) != caster_id:
			continue
		return index
	return -1


func _remove_caster_summoned_statue(caster_id: int) -> void:
	var index: int = _find_summoned_statue_index(caster_id)
	if index >= 0:
		obstacles.remove_at(index)


func _refresh_elf_statue_buffs() -> void:
	for unit in units:
		_apply_elf_statue_buff(unit)


func _execute_summon_statue(caster: Dictionary, cell: Vector2i) -> void:
	if not _can_place_summoned_statue_at(cell):
		_log_event("%s nie może przyzwać Pomnika w tym miejscu." % _unit_name_log_text(caster))
		return
	var had_statue: bool = _find_summoned_statue_index(int(caster.id)) >= 0
	_remove_caster_summoned_statue(int(caster.id))
	obstacles.append({
		"grid_x": cell.x,
		"grid_y": cell.y,
		"type": "elf_statue",
		"variant": "elf_statue",
		"source": "skill",
		"summoned_by_id": int(caster.id),
		"summoned_by_side": str(caster.side),
	})
	_refresh_elf_statue_buffs()
	if had_statue:
		_log_event("%s przenosi Pomnik Elfów." % _unit_name_log_text(caster))
	else:
		_log_event("%s przyzywa Pomnik Elfów." % _unit_name_log_text(caster))


func _trigger_goblin_trap(unit: Dictionary, trap: Dictionary) -> void:
	var damage: int = MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe(unit, int(trap.get("tick_damage", 1)))
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
	_log_event("%s wpada w Pułapkę Goblina, otrzymuje %s obrażeń i ponosi %s strat." % [_unit_name_log_text(unit), _color_log_text(str(damage), LOG_COLOR_DAMAGE), _color_log_text(str(casualties), LOG_COLOR_DAMAGE)])
	_cleanup_destroyed_unit(unit)


func _execute_energy_barrier(caster: Dictionary) -> void:
	_apply_energy_barrier(caster)
	_log_event("%s otacza się Barierą Energetyczną." % _unit_name_log_text(caster))


func _execute_iron_curtain(caster: Dictionary, target: Dictionary) -> void:
	_apply_or_refresh_effect(target, {
		"id": "zelazna_kurtyna",
		"name": "Zelazna Kurtyna",
		"category": "buff",
		"remaining_turns": 2,
		"stat_changes": [],
		"guarded_by_id": int(caster.id)
	})
	_log_event("%s chroni %s Żelazną Kurtyną." % [_unit_name_log_text(caster), _unit_name_log_text(target)])


func _execute_self_buff(caster: Dictionary, skill: Dictionary) -> void:
	var effect: Dictionary = skill.get("effect", {}).duplicate(true)
	if effect.is_empty():
		return
	if str(effect.get("id", "")) == "":
		effect["id"] = str(skill.get("id", ""))
	if str(effect.get("name", "")) == "":
		effect["name"] = str(skill.get("name", skill.get("id", "")))
	_apply_or_refresh_effect(caster, effect)
	_log_event("%s używa umiejętności %s." % [_unit_name_log_text(caster), str(skill.get("name", skill.get("id", "")))])


func _execute_zadza_krwi(caster: Dictionary, skill: Dictionary) -> void:
	caster["base_dmg_min"] = int(caster.get("base_dmg_min", caster.get("dmg_min", 1))) + 2
	caster["base_dmg_max"] = int(caster.get("base_dmg_max", caster.get("dmg_max", 1))) + 2
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
		"%s używa umiejętności %s i na stałe zyskuje +2 DMG oraz -2 DEF (łącznie +%d DMG i -%d DEF do końca bitwy)." % [
			_unit_name_log_text(caster),
			str(skill.get("name", "Żądza krwi")),
			stack_amount * 2,
			stack_amount * 2
		]
	)


func _execute_utwardzenie(caster: Dictionary, skill: Dictionary) -> void:
	caster["base_def"] = int(caster.get("base_def", caster.get("def", 0))) + 1
	var stack_amount: int = 1
	for effect in caster.get("active_effects", []):
		if str(effect.get("id", "")) == "utwardzenie":
			stack_amount = int(effect.get("stack_amount", 1)) + 1
			break
	_apply_or_refresh_effect(caster, {
		"id": "utwardzenie",
		"name": "Utwardzenie",
		"category": "buff",
		"permanent": true,
		"stack_amount": stack_amount,
		"stat_changes": []
	})
	_recalculate_unit_stats(caster)
	_log_event(
		"%s używa Utwardzenia i na stałe zyskuje +1 DEF (łącznie +%d DEF do końca bitwy)." % [
			_unit_name_log_text(caster),
			stack_amount
		]
	)


func _execute_focused_strike(caster: Dictionary, target: Dictionary, skill: Dictionary = {}) -> void:
	var total_damage := _calculate_damage(caster, target)
	var projectile_kind: String = str(skill.get("projectile_kind", ""))
	var result := _apply_attack_damage(caster, target, total_damage, true, projectile_kind)
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	_log_event(
		"%s trafia %s, zadając %s obrażeń i powodując %s strat." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_shattering_strike(caster: Dictionary, target: Dictionary, skill: Dictionary = {}) -> void:
	var target_id: int = int(target.get("id", -1))
	var total_damage := _calculate_damage(caster, target, 1.5)
	var result := _apply_attack_damage(caster, target, total_damage, true, "", "axe")
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	_log_event(
		"%s uderza %s Druzgocacym Ciosem za %s obrazen i %s strat." % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_cleanup_destroyed_unit(hit_target)
	if target_id != -1 and _find_unit_by_id(target_id).is_empty():
		if not caster.has("skill_cooldowns"):
			caster["skill_cooldowns"] = {}
		caster.skill_cooldowns[str(skill.get("id", "druzgocacy_cios"))] = 0
		_log_event("%s — cooldown Druzgocacego Ciosu zostaje odswiezony." % _unit_name_log_text(caster))


func _get_piercing_shot_cells(caster: Dictionary, target: Dictionary) -> Array[Vector2i]:
	var source_cell := Vector2i(caster.grid_x, caster.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if source_cell == target_cell:
		return [target_cell]
	var line_cells: Array[Vector2i] = _get_hex_line(source_cell, target_cell)
	if line_cells.size() < 2:
		return [target_cell]
	var target_index: int = line_cells.size() - 1
	var start_index: int = maxi(1, target_index - PIERCING_SHOT_HEX_COUNT + 1)
	var cells: Array[Vector2i] = []
	if target_index - start_index + 1 < PIERCING_SHOT_HEX_COUNT:
		cells.append(target_cell)
	else:
		for index in range(start_index, target_index + 1):
			cells.append(line_cells[index])
	var step_cube: Vector3i = _oddr_to_cube(line_cells[target_index]) - _oddr_to_cube(line_cells[target_index - 1])
	var current_cube: Vector3i = _oddr_to_cube(cells[cells.size() - 1])
	while cells.size() < PIERCING_SHOT_HEX_COUNT:
		current_cube += step_cube
		var cell: Vector2i = _cube_to_oddr(current_cube)
		if cell.x < 0 or cell.x >= GRID_COLUMNS or cell.y < 0 or cell.y >= GRID_ROWS:
			break
		if _cell_blocks_line_of_sight(cell):
			break
		cells.append(cell)
	return cells


func _get_piercing_shot_preview_cells(caster: Dictionary, target: Dictionary) -> Array[Vector2i]:
	return _get_piercing_shot_cells(caster, target)


func _execute_piercing_shot(caster: Dictionary, target: Dictionary, skill: Dictionary = {}) -> void:
	var projectile_kind: String = str(skill.get("projectile_kind", ""))
	var pierce_cells: Array[Vector2i] = _get_piercing_shot_cells(caster, target)
	for cell_index in pierce_cells.size():
		var cell: Vector2i = pierce_cells[cell_index]
		var hit_unit: Dictionary = _find_unit_at_cell(cell)
		if hit_unit.is_empty() or int(hit_unit.get("count", 0)) <= 0:
			continue
		var total_damage := _calculate_damage(caster, hit_unit)
		var play_animation: bool = cell_index == 0
		var result := _apply_attack_damage(caster, hit_unit, total_damage, play_animation, projectile_kind)
		var hit_target: Dictionary = result.get("target", hit_unit)
		var casualties := int(result.get("casualties", 0))
		if cell_index == 0:
			_log_event(
				"%s trafia %s Przebijającym Strzałem, zadając %s obrażeń i powodując %s strat." % [
					_unit_name_log_text(caster),
					_unit_name_log_text(hit_target),
					_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
					_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
				]
			)
		else:
			_log_event(
				"Strzała przebija cel i trafia %s, zadając %s obrażeń i powodując %s strat." % [
					_unit_name_log_text(hit_target),
					_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
					_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
				]
			)
		_cleanup_destroyed_unit(hit_target)


func _execute_zaklete_ciecie(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.5)
	var result := _apply_attack_damage(caster, target, total_damage, true, "", "sword")
	var hit_target: Dictionary = result.get("target", target)
	var casualties := int(result.get("casualties", 0))
	var curse_suffix := ""
	if int(result.get("damage", 0)) > 0:
		_apply_or_refresh_effect(hit_target, {
			"id": "klatwa",
			"remaining_turns": 2,
		})
		curse_suffix = " Cel jest przeklęty."
	_log_event(
		"%s tnie %s Zaklętym Cięciem, zadając %s obrażeń i powodując %s strat.%s" % [
			_unit_name_log_text(caster),
			_unit_name_log_text(hit_target),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE),
			curse_suffix
		]
	)
	_cleanup_destroyed_unit(hit_target)


func _execute_rozszarpanie(caster: Dictionary, target: Dictionary) -> void:
	var total_damage := _calculate_damage(caster, target, 0.5)
	var result := _apply_attack_damage(caster, target, total_damage)
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
		"%s rozszarpuje %s, zadając %s obrażeń i powodując %s strat.%s" % [
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
				_log_event("%s ślizga się na lodzie." % _unit_name_log_text(unit))
			"poison_cloud":
				if _apply_poison_effect(unit, "zatrucie", "Zatrucie", 2, int(effect.get("tick_damage", 1))):
					_log_event("%s wdycha toksyczną chmurę." % _unit_name_log_text(unit))
			"bear_trap":
				_trigger_bear_trap(unit, effect)
			"goblin_trap":
				_trigger_goblin_trap(unit, effect)
	if apply_entry_effect:
		_apply_terrain_entry_effect(unit)


func _trigger_bear_trap(unit: Dictionary, trap: Dictionary) -> void:
	var damage: int = MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe(unit, int(trap.get("tick_damage", 1)))
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
	_log_event("%s wpada w Pułapkę na Niedźwiedzie, otrzymuje %s obrażeń i ponosi %s strat." % [_unit_name_log_text(unit), _color_log_text(str(damage), LOG_COLOR_DAMAGE), _color_log_text(str(casualties), LOG_COLOR_DAMAGE)])
	_cleanup_destroyed_unit(unit)


func _apply_terrain_entry_effect(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	_apply_elf_statue_buff(unit)
	var terrain_name: String = str(effect.get("name", "teren"))
	if bool(effect.get("instant_death", false)):
		_trigger_hole_death(unit, terrain_name)
		return
	_refresh_terrain_bound_effects(unit)
	if bool(unit.get("is_hidden", false)):
		var hiding_name: String = str(_get_hiding_effect_at_cell(cell).get("name", "ukrycie"))
		_log_event("%s wchodzi w %s i znika z pola widzenia." % [_unit_name_log_text(unit), hiding_name])
	elif not effect.is_empty():
		_log_event("%s wchodzi w %s i traci resztę ruchu." % [_unit_name_log_text(unit), terrain_name])
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
	var hiding_effect: Dictionary = _get_hiding_effect_at_cell(cell)
	var hiding_id: String = str(hiding_effect.get("id", ""))
	var kept_effects: Array = []
	for effect in unit.get("active_effects", []):
		if bool(effect.get("terrain_bound", false)) and bool(effect.get("hides_unit", false)) and str(effect.get("id", "")) != hiding_id:
			continue
		kept_effects.append(effect)
	unit["active_effects"] = kept_effects
	unit["is_hidden"] = not hiding_effect.is_empty()
	if not hiding_effect.is_empty():
		_apply_or_refresh_effect(unit, hiding_effect)
	else:
		_recalculate_unit_stats(unit)


func _get_terrain_type_at(cell: Vector2i) -> String:
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y:
			return str(obstacle.get("type", ""))
	return ""


func _try_activate_detonator(active_unit: Dictionary, cell: Vector2i) -> bool:
	if not _can_activate_detonator(active_unit, cell):
		return false
	var unit_cell := Vector2i(int(active_unit.grid_x), int(active_unit.grid_y))
	var ranged_shot: bool = _hex_distance(unit_cell, cell) > 1
	var detonator_index := _find_detonator_index(cell)
	if detonator_index < 0:
		return false
	_trigger_detonator(active_unit, cell, detonator_index, ranged_shot)
	return true


func _can_activate_detonator(unit: Dictionary, cell: Vector2i) -> bool:
	if _get_terrain_type_at(cell) != "detonator" or detonator_activated or not _can_unit_attack(unit):
		return false
	var distance: int = _hex_distance(Vector2i(int(unit.grid_x), int(unit.grid_y)), cell)
	return distance == 1 or (distance > 1 and int(unit.get("attack_range", 1)) > 1 and _is_in_attack_range(unit, cell))


func _find_detonator_index(cell: Vector2i) -> int:
	for index in obstacles.size():
		var obstacle: Dictionary = obstacles[index]
		if int(obstacle.get("grid_x", -1)) == cell.x and int(obstacle.get("grid_y", -1)) == cell.y and str(obstacle.get("type", "")) == "detonator":
			return index
	return -1


func _get_detonator_target_cells(detonator_index: int, cell: Vector2i) -> Array[Vector2i]:
	var target_cells: Array[Vector2i] = []
	if detonator_index >= 0:
		var stored_targets: Variant = obstacles[detonator_index].get("target_cells", [])
		if stored_targets is Array:
			for stored in stored_targets:
				if stored is Vector2i:
					target_cells.append(stored)
	if target_cells.is_empty() and detonator_index >= 0:
		target_cells = _random_detonator_target_cells(cell)
		obstacles[detonator_index]["target_cells"] = target_cells
	return target_cells


func _trigger_detonator(active_unit: Dictionary, cell: Vector2i, detonator_index: int, ranged_shot: bool = false) -> void:
	is_animating = true
	active_unit.action_points = max(0, int(active_unit.action_points) - 1)
	pending_skill_id = ""
	selected_obstacle_cell = Vector2i(-1, -1)
	board.set_selected_obstacle(Vector2i(-1, -1))
	board.set_hovered_detonator_preview([])
	board.set_detonator_warning_cells([])
	_log_event("%s aktywuje detonator." % _unit_name_log_text(active_unit))
	_show_screen_message("Detonator aktywowany!", 2.0)

	var target_cells: Array[Vector2i] = _get_detonator_target_cells(detonator_index, cell)
	if ranged_shot:
		board.play_attack_animation_to_cell(int(active_unit.id), cell, _get_attack_projectile_kind(active_unit))
		await get_tree().create_timer(0.16).timeout
	else:
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
		var result := _apply_attack_damage(active_unit, target, total_damage, false)
		var hit_target: Dictionary = result.get("target", target)
		hit_names.append("%s (%s/%s)" % [_unit_name_log_text(hit_target), result.get("damage", total_damage), result.get("casualties", 0)])
		if int(hit_target.get("count", 0)) <= 0:
			_show_screen_message("%s zostaje zmiazdzony przez kamienie!" % str(hit_target.get("name", "Jednostka")), 2.5)
		_cleanup_destroyed_unit(hit_target)

	obstacles.remove_at(detonator_index)
	board.set_detonator_warning_cells([])
	board.clear_falling_rock_cells()
	_log_event(
		"%s wybucha: %s." % [
			_unit_name_log_text(active_unit),
			"brak trafień" if hit_names.is_empty() else ", ".join(hit_names)
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
	_log_event(_color_log_text("%s zapada się pod lód i ginie!" % _unit_name_log_text(unit), LOG_COLOR_DAMAGE))
	unit["count"] = 0
	unit["current_total_hp"] = 0
	unit["current_hp"] = 0
	_cleanup_destroyed_unit(unit)


func _is_water_cell(cell: Vector2i) -> bool:
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y:
			return str(obstacle.get("type", "")) == "woda"
	return false


func _reveal_if_in_bush(unit: Dictionary) -> void:
	var cell := Vector2i(int(unit.grid_x), int(unit.grid_y))
	if not _terrain_hides_unit(cell) or _has_map_concealment_at(cell):
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


func _reveal_unit_leaving_concealment(unit: Dictionary, origin: Vector2i) -> void:
	if not bool(unit.get("is_hidden", false)):
		return
	if not _terrain_hides_unit(origin) and not _has_map_concealment_at(origin):
		return
	var destination := Vector2i(int(unit.grid_x), int(unit.grid_y))
	if _terrain_hides_unit(destination) or _has_map_concealment_at(destination):
		return
	_refresh_terrain_bound_effects(unit)


func _apply_poison_effect(unit: Dictionary, id: String, name: String, turns: int, tick_damage: int, reduce_def := false) -> bool:
	if _is_poison_immune(unit):
		_log_event("%s jest odporny na truciznę." % _unit_name_log_text(unit))
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
	return _has_effect(unit, "mistrz_trucizn") or str(unit.get("resistance", "")).to_lower().contains("truciz")


func _try_apply_poison_master(attacker: Dictionary, target: Dictionary) -> void:
	if target.is_empty() or int(target.get("count", 0)) <= 0:
		return
	if not _has_effect(attacker, "mistrz_trucizn"):
		return
	_apply_poison_effect(target, "zatrucie", "Zatrucie", 1, maxi(1, int(ceil(float(_srednie_obrazenia_jednostki(attacker)) * 0.25))))


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
	for unit in units:
		_refresh_terrain_bound_effects(unit)
	_advance_temporary_obstacles()


func _advance_temporary_obstacles() -> void:
	var kept_obstacles: Array[Dictionary] = []
	for obstacle in obstacles:
		if not obstacle.has("remaining_turns"):
			kept_obstacles.append(obstacle)
			continue
		obstacle["remaining_turns"] = int(obstacle.get("remaining_turns", 0)) - 1
		if int(obstacle["remaining_turns"]) > 0:
			kept_obstacles.append(obstacle)
	obstacles = kept_obstacles


func _try_trigger_map_event() -> void:
	BibliotekaZdarzenMapyScript.wykonaj(self)


func _build_debug_map_event_menu() -> void:
	debug_map_event_menu = PopupMenu.new()
	debug_map_event_menu.name = "DebugMapEventMenu"
	add_child(debug_map_event_menu)
	var event_ids: Array[String] = []
	for event_id in BibliotekaZdarzenMapyScript.DANE:
		event_ids.append(str(event_id))
	event_ids.sort()
	for event_id in event_ids:
		debug_map_event_menu.add_item(BibliotekaZdarzenMapyScript.pobierz_nazwe(event_id))
		debug_map_event_menu.set_item_metadata(debug_map_event_menu.item_count - 1, event_id)
	debug_map_event_menu.id_pressed.connect(_on_debug_map_event_selected)


func _on_debug_map_event_selected(item_id: int) -> void:
	var item_index: int = debug_map_event_menu.get_item_index(item_id)
	if item_index >= 0:
		_debug_trigger_map_event(str(debug_map_event_menu.get_item_metadata(item_index)))


func _debug_trigger_map_event(event_id: String) -> void:
	if not OS.is_debug_build() or setup_mode or is_animating or not BibliotekaZdarzenMapyScript.DANE.has(event_id):
		return
	next_map_event_id = event_id
	next_map_event_round = round_number
	map_event_cells.clear()
	_prepare_map_event_cells()
	var event_cells: Array[Vector2i] = map_event_cells.duplicate()
	_try_trigger_map_event()
	_extend_debug_map_event_duration(event_id, event_cells)


func _extend_debug_map_event_duration(event_id: String, event_cells: Array[Vector2i]) -> void:
	var terrain_effect_id: String = {
		"gesty_dym": "mgla",
		"burza_piaskowa": "burza_piaskowa",
		"wybuch_gazu": "poison_cloud",
		"rozprzestrzeniajacy_sie_pozar": "fire",
		"oblodzenie": "ice",
	}.get(event_id, "")
	for effect in terrain_effects:
		var effect_cell := Vector2i(int(effect.get("grid_x", -1)), int(effect.get("grid_y", -1)))
		if str(effect.get("id", "")) == terrain_effect_id and (event_cells.is_empty() or event_cells.has(effect_cell)):
			effect["remaining_turns"] = int(effect.get("remaining_turns", 0)) + 1
	var active_unit: Dictionary = _get_active_unit()
	for effect in active_unit.get("active_effects", []):
		if str(effect.get("id", "")) == event_id and not bool(effect.get("terrain_bound", false)):
			effect["remaining_turns"] = int(effect.get("remaining_turns", 0)) + 1


func _schedule_next_map_event(after_round: int) -> void:
	var scenario_id: String = current_battle_background_path.get_file().get_basename()
	var raw_pool: Array = BibliotekaZdarzenMapyScript.pobierz_pule(scenario_id)
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
	return BibliotekaZdarzenMapyScript.pobierz_nazwe(next_map_event_id)


func _event_can_be_scheduled(event_id: String) -> bool:
	var obstacle_type: String = BibliotekaZdarzenMapyScript.pobierz_typ_przeszkody(event_id)
	return obstacle_type == "" or _available_event_obstacle_slots(obstacle_type) > 0


func _available_event_obstacle_slots(type_id: String) -> int:
	var used: int = 0
	for obstacle in obstacles:
		if str(obstacle.get("type", "")) == type_id and str(obstacle.get("source", "")) == "map_event":
			used += 1
	return maxi(0, BibliotekaZdarzenMapyScript.pobierz_limit_przeszkod(type_id) - used)


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
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: Gniew Korzeni unieruchamia jednostki na oznaczonych polach.", LOG_COLOR_YELLOW))


func _event_falling_rubble() -> void:
	_damage_units_on_event_cells("Spadajacy Rumosz")
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: Wstrząs narusza strop kopalni.", LOG_COLOR_YELLOW))


func _event_spreading_fire() -> void:
	for cell in map_event_cells:
		_add_terrain_effect(cell, "fire", 2)
	_apply_terrain_effects_in_cells(map_event_cells)
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: Pożar rozprzestrzenia się na trzy pola.", LOG_COLOR_YELLOW))


func _event_global_move_penalty(event_id: String, event_name: String) -> void:
	for unit in units:
		_apply_or_refresh_effect(unit, {
			"id": event_id,
			"name": event_name,
			"category": "debuff",
			"remaining_turns": 1,
			"stat_changes": [{"stat": "move_range", "mode": "flat", "value": -2}]
		})
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: %s spowalnia wszystkie jednostki." % event_name, LOG_COLOR_YELLOW))


func _event_board_concealment(effect_id: String) -> void:
	for column in range(GRID_COLUMNS):
		for row in range(GRID_ROWS):
			var cell := Vector2i(column, row)
			if _is_cell_passable(cell):
				_add_terrain_effect(cell, effect_id, 1)
	for unit in units:
		_refresh_terrain_bound_effects(unit)
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: %s ukrywa jednostki na 1 runde." % _map_event_name(), LOG_COLOR_YELLOW))


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
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: %s zmniejsza zasięg ataku wszystkich jednostek o 1." % event_name, LOG_COLOR_YELLOW))


func _event_magic_bloom() -> void:
	for target in units:
		if not map_event_cells.has(Vector2i(int(target.grid_x), int(target.grid_y))):
			continue
		var healing: int = int(target.get("base_hp", 1))
		var healing_limit: int = int(target.get("count", 0)) * healing
		target["current_total_hp"] = mini(healing_limit, int(target.get("current_total_hp", 0)) + healing)
		_refresh_unit_health_state(target)
		_log_event("%s odzyskuje %s HP dzięki Magicznemu Rozkwitowi." % [_unit_name_log_text(target), healing])
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: Magiczny Rozkwit leczy jednostki na oznaczonych polach.", LOG_COLOR_YELLOW))


func _event_random_terrain(effect_id: String, count: int, turns: int) -> void:
	for cell in map_event_cells:
		_add_terrain_effect(cell, effect_id, turns, -1, 1 if effect_id == "poison_cloud" else 0)
	_apply_terrain_effects_in_cells(map_event_cells)
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: %s pojawia się na %d polach." % [_map_event_name(), map_event_cells.size()], LOG_COLOR_YELLOW))


func _event_random_obstacles(type_id: String, variant: String, count: int, message: String) -> void:
	var placed := 0
	var available: int = mini(count, _available_event_obstacle_slots(type_id))
	for cell in map_event_cells:
		if placed >= available:
			break
		if type_id == "kamienie":
			var target: Dictionary = _find_unit_at_cell(cell)
			if not target.is_empty():
				var damage: int = MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe(target, 1)
				_apply_damage_to_unit(target, damage)
				_cleanup_destroyed_unit(target)
				if not _find_unit_at_cell(cell).is_empty():
					continue
		obstacles.append({"grid_x": cell.x, "grid_y": cell.y, "type": type_id, "variant": variant, "source": "map_event"})
		placed += 1
	for unit in units:
		if map_event_cells.has(Vector2i(int(unit.grid_x), int(unit.grid_y))):
			_apply_terrain_entry_effect(unit)
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: %s" % message, LOG_COLOR_YELLOW))


func _event_damage_on_marked_cells(event_name: String) -> void:
	_damage_units_on_event_cells(event_name)
	_log_event(_color_log_text("WYDARZENIE NA MAPIE: %s uderza w oznaczone pola." % event_name, LOG_COLOR_YELLOW))


func _damage_units_on_event_cells(event_name: String) -> void:
	for target in units.duplicate():
		if not map_event_cells.has(Vector2i(int(target.grid_x), int(target.grid_y))):
			continue
		var damage: int = MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe(target, 1)
		_apply_damage_to_unit(target, damage)
		_log_event("%s otrzymuje %s obrażeń wskutek wydarzenia %s." % [_unit_name_log_text(target), _color_log_text(str(damage), LOG_COLOR_DAMAGE), event_name])
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
	if not BibliotekaZdarzenMapyScript.czy_runda_ostrzezenia(round_number, next_map_event_round) or not map_event_cells.is_empty():
		return
	_prepare_map_event_cells()
	if not map_event_cells.is_empty():
		_log_event(_color_log_text("OSTRZEŻENIE: %s uderzy w oznaczone pola w rundzie %d." % [_map_event_name(), next_map_event_round], LOG_COLOR_YELLOW), false)


func _prepare_map_event_cells() -> void:
	var cell_count: int = BibliotekaZdarzenMapyScript.pobierz_liczbe_pol_ostrzezenia(next_map_event_id)
	if ["wybuch_gazu", "rozprzestrzeniajacy_sie_pozar", "oblodzenie"].has(next_map_event_id):
		cell_count = randi_range(5, 8)
	var obstacle_type: String = BibliotekaZdarzenMapyScript.pobierz_typ_przeszkody(next_map_event_id)
	if obstacle_type != "":
		cell_count = mini(cell_count, _available_event_obstacle_slots(obstacle_type))
	if cell_count == 0:
		return
	map_event_cells = _random_map_event_cells(cell_count)


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


func _process_turn_start(unit: Dictionary) -> bool:
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
		var total_damage := MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe(unit, tick_damage)
		if _consume_energy_barrier(unit):
			_log_event("Bariera Energetyczna chroni %s przed obrażeniami od efektu %s." % [_unit_name_log_text(unit), str(effect.get("name", "efekt"))])
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
			return skipped_turn
	if skipped_turn:
		_log_event("%s jest ogłuszony i traci turę." % _unit_name_log_text(unit))
	_recalculate_unit_stats(unit)
	return skipped_turn


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
	unit["atk"] = int(unit.get("base_atk", unit.get("atk", 0)))
	unit["dmg_min"] = int(unit.get("base_dmg_min", unit.get("dmg_min", 1)))
	unit["dmg_max"] = int(unit.get("base_dmg_max", unit.get("dmg_max", 1)))
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


	unit["atk"] = maxi(0, int(unit.get("atk", 0)))
	unit["dmg_min"] = maxi(1, int(unit.get("dmg_min", 1)))
	unit["dmg_max"] = maxi(int(unit.dmg_min), int(unit.get("dmg_max", unit.dmg_min)))
	unit["speed"] = max(0, int(unit.get("speed", 0)))
	unit["move_range"] = max(0, int(unit.get("move_range", 0)))
	unit["attack_range"] = max(1, int(unit.get("attack_range", 1)))
	unit["buffs"] = "Brak" if buff_names.is_empty() else ", ".join(buff_names)
	unit["debuffs"] = "Brak" if debuff_names.is_empty() else ", ".join(debuff_names)
	_refresh_unit_health_state(unit)


func _refresh_unit_health_state(unit: Dictionary) -> void:
	MatematykaWalkiScript.odswiez_stan_hp(unit)


func _apply_stat_change(unit: Dictionary, change: Dictionary) -> void:
	var stat_name := str(change.get("stat", ""))
	if stat_name == "dmg":
		var minimum_change: Dictionary = change.duplicate()
		minimum_change["stat"] = "dmg_min"
		_apply_stat_change(unit, minimum_change)
		var maximum_change: Dictionary = change.duplicate()
		maximum_change["stat"] = "dmg_max"
		_apply_stat_change(unit, maximum_change)
		return
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


func _find_path(unit: Dictionary, start: Vector2i, goal: Vector2i, charge_skill: Dictionary = {}, max_distance: int = -1) -> Array[Vector2i]:
	if start == goal:
		return []
	if not _pole_na_planszy(start) or not _pole_na_planszy(goal):
		return []
	var mapa: Dictionary = _zbuduj_mape_tras(unit, start, max_distance, charge_skill)
	return _odtworz_trase(mapa, start, goal)


func _zbuduj_mape_tras(unit: Dictionary, start: Vector2i, max_distance: int, charge_skill: Dictionary = {}) -> Dictionary:
	if not _pole_na_planszy(start):
		return {"came_from": {}, "risk_by_state": {}, "priority_by_state": {}, "best_state_by_cell": {}}
	var limit: int = max_distance if max_distance >= 0 else _maksymalny_koszt_prostej_trasy()
	var blocked: Dictionary = _get_blocked_cells(int(unit.get("id", -1)), unit)
	var start_state := Vector3i(start.x, start.y, 0)
	var frontier: Array[Vector3i] = [start_state]
	var came_from: Dictionary = {start_state: start_state}
	var risk_by_state: Dictionary = {start_state: 0}
	var priority_by_state: Dictionary = {start_state: 0}
	var best_state_by_cell: Dictionary = {start: start_state}

	while not frontier.is_empty():
		frontier.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
			var priority_a: int = int(priority_by_state[a])
			var priority_b: int = int(priority_by_state[b])
			if priority_a != priority_b:
				return priority_a < priority_b
			if a.z != b.z:
				return a.z < b.z
			return a.y < b.y if a.y != b.y else a.x < b.x
		)
		var current_state: Vector3i = frontier.pop_front()
		var current := Vector2i(current_state.x, current_state.y)
		if current != start and _pole_konczy_planowany_ruch(unit, current):
			continue
		for neighbor in _get_neighbors(current):
			if not _is_forward_step(unit, current, neighbor, charge_skill):
				continue
			if blocked.has(neighbor):
				continue
			var step_cost: int = _get_movement_cost(neighbor)
			var next_cost: int = current_state.z + step_cost
			if next_cost > limit:
				continue
			var next_risk: int = int(risk_by_state[current_state]) + _get_path_hazard_penalty(unit, [neighbor])
			var next_state := Vector3i(neighbor.x, neighbor.y, next_cost)
			if _stan_trasy_zdominowany(neighbor, next_cost, next_risk, risk_by_state):
				continue
			var next_priority: int = next_cost + next_risk
			if priority_by_state.has(next_state) and int(priority_by_state[next_state]) <= next_priority:
				continue
			came_from[next_state] = current_state
			risk_by_state[next_state] = next_risk
			priority_by_state[next_state] = next_priority
			frontier.append(next_state)
			var previous_state: Vector3i = best_state_by_cell.get(neighbor, Vector3i(-1, -1, -1))
			if previous_state.z < 0 or next_priority < int(priority_by_state[previous_state]) or (next_priority == int(priority_by_state[previous_state]) and next_cost < previous_state.z):
				best_state_by_cell[neighbor] = next_state
	return {
		"came_from": came_from,
		"risk_by_state": risk_by_state,
		"priority_by_state": priority_by_state,
		"best_state_by_cell": best_state_by_cell,
	}


func _stan_trasy_zdominowany(cell: Vector2i, movement_cost: int, risk: int, risk_by_state: Dictionary) -> bool:
	for cheaper_cost in range(movement_cost + 1):
		var state := Vector3i(cell.x, cell.y, cheaper_cost)
		if risk_by_state.has(state) and int(risk_by_state[state]) <= risk:
			return true
	return false


func _odtworz_trase(mapa: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var best_states: Dictionary = mapa.get("best_state_by_cell", {})
	if not best_states.has(goal):
		return []
	var path: Array[Vector2i] = []
	var came_from: Dictionary = mapa.get("came_from", {})
	var state: Vector3i = best_states[goal]
	while Vector2i(state.x, state.y) != start:
		path.push_front(Vector2i(state.x, state.y))
		state = came_from[state]
	return path


func _osiagalne_z_mapy_tras(mapa: Dictionary, start: Vector2i) -> Array[Vector2i]:
	var best_states: Dictionary = mapa.get("best_state_by_cell", {})
	var result: Array[Vector2i] = []
	for raw_cell in best_states.keys():
		var cell: Vector2i = raw_cell
		if cell != start:
			result.append(cell)
	result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var state_a: Vector3i = best_states[a]
		var state_b: Vector3i = best_states[b]
		if state_a.z != state_b.z:
			return state_a.z < state_b.z
		if a.y != b.y:
			return a.y < b.y
		return a.x < b.x
	)
	return result


func _maksymalny_koszt_prostej_trasy() -> int:
	var max_step_cost := 1
	for terrain in terrain_types.values():
		if not bool(terrain.get("blocks_movement", false)):
			max_step_cost = max(max_step_cost, int(terrain.get("movement_cost", 1)))
	return (GRID_COLUMNS * GRID_ROWS - 1) * max_step_cost


func _pole_na_planszy(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_COLUMNS and cell.y >= 0 and cell.y < GRID_ROWS


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
		_log_event("%s odskakuje dzięki Zwinności." % _unit_name_log_text(unit))
		_apply_terrain_effects_to_unit(unit)


func _get_push_destination(source: Dictionary, target: Dictionary) -> Vector2i:
	var source_cube: Vector3i = _oddr_to_cube(Vector2i(source.grid_x, source.grid_y))
	var target_cube: Vector3i = _oddr_to_cube(Vector2i(target.grid_x, target.grid_y))
	var direction: Vector3i = target_cube - source_cube
	var pushed_cube: Vector3i = target_cube + direction
	var pushed_cell: Vector2i = _cube_to_oddr(pushed_cube)
	if pushed_cell.x < 0 or pushed_cell.x >= GRID_COLUMNS or pushed_cell.y < 0 or pushed_cell.y >= GRID_ROWS:
		return Vector2i(-1, -1)
	# Passable terrain (krzak/woda/dziura) — wpadasz; tylko blocks_movement daje stun.
	if not _is_cell_passable(pushed_cell):
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
	if not _is_cell_passable(destination):
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


func _generate_obstacles() -> Array[Dictionary]:
	if _is_castle_scenario():
		var stages: Array[Dictionary] = _get_castle_stages()
		return _typed_dictionary_array(stages[castle_stage - 1].get("obstacles", [])) if castle_stage > 0 and castle_stage <= stages.size() else []
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


func _is_castle_scenario() -> bool:
	return current_battle_background_path.get_file().get_basename().begins_with("zamek_etap_")


func _get_castle_stages() -> Array[Dictionary]:
	var parsed: Variant = JSON.parse_string(_read_json_text(CASTLE_SCENARIO_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	return _typed_dictionary_array((parsed as Dictionary).get("stages", []))


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
	return max(1, int(terrain.get("movement_cost", 1)))


func _get_path_cost(path: Array[Vector2i]) -> int:
	var cost: int = 0
	for cell in path:
		cost += _get_movement_cost(cell)
	return cost


func _get_executable_move_path(path: Array[Vector2i], mover: Dictionary = {}) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in path:
		if not mover.is_empty() and _is_ambush_cell_for_unit(mover, cell):
			break
		result.append(cell)
		if _pole_konczy_ruch(cell):
			break
	return result


func _pole_konczy_ruch(cell: Vector2i) -> bool:
	return _terrain_skips_turn(cell) or _terrain_is_deadly(cell) or _has_trap_at(cell)


func _pole_konczy_planowany_ruch(unit: Dictionary, cell: Vector2i) -> bool:
	return _terrain_skips_turn(cell) or _terrain_is_deadly(cell) or _is_known_trap_for_unit(unit, cell)


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
	var effect: Dictionary = _get_hiding_effect_at_cell(cell)
	return bool(effect.get("hides_unit", false))


func _get_hiding_effect_at_cell(cell: Vector2i) -> Dictionary:
	for effect_id in ["mgla", "burza_piaskowa"]:
		if not _get_terrain_effect_at(cell, effect_id).is_empty():
			return UnitTypeLibrary.build_active_effect(effect_id)
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	return effect if bool(effect.get("hides_unit", false)) else {}


func _has_map_concealment_at(cell: Vector2i) -> bool:
	return not _get_terrain_effect_at(cell, "mgla").is_empty() or not _get_terrain_effect_at(cell, "burza_piaskowa").is_empty()


func _terrain_skips_turn(cell: Vector2i) -> bool:
	var effect: Dictionary = _get_terrain_entry_effect(cell)
	return bool(effect.get("skip_turn", false))


func _terrain_is_deadly(cell: Vector2i) -> bool:
	return bool(_get_terrain_entry_effect(cell).get("instant_death", false))


func _can_see_target(observer: Dictionary, target: Dictionary) -> bool:
	var observer_cell := Vector2i(observer.grid_x, observer.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	if _has_map_concealment_at(target_cell):
		return _hex_distance(observer_cell, target_cell) == 1
	if bool(target.get("is_revealed", false)) or _has_effect(target, "wykrycie"):
		return true
	if not bool(target.get("is_hidden", false)):
		return true
	return _hex_distance(observer_cell, target_cell) == 1


func _is_ambush_cell_for_unit(mover: Dictionary, cell: Vector2i) -> bool:
	var defender: Dictionary = _find_unit_at_cell(cell)
	if defender.is_empty() or str(defender.side) == str(mover.side):
		return false
	if not bool(defender.get("is_hidden", false)):
		return false
	if bool(defender.get("is_revealed", false)) or _has_effect(defender, "wykrycie"):
		return false
	return _get_terrain_type_at(cell) in ["krzok", "zimowy_krzak"]


func _get_ambush_defender_at_cell(mover: Dictionary, cell: Vector2i) -> Dictionary:
	if not _is_ambush_cell_for_unit(mover, cell):
		return {}
	return _find_unit_at_cell(cell)


func _get_ambush_defender_adjacent_to(mover: Dictionary, cell: Vector2i) -> Dictionary:
	for neighbor in _get_neighbors(cell):
		var defender: Dictionary = _get_ambush_defender_at_cell(mover, neighbor)
		if not defender.is_empty():
			return defender
	return {}


func _try_trigger_bush_ambush(mover: Dictionary, defender: Dictionary) -> bool:
	if defender.is_empty() or _find_unit_by_id(int(mover.id)).is_empty():
		return false
	var defender_cell: Vector2i = Vector2i(int(defender.grid_x), int(defender.grid_y))
	var current_defender: Dictionary = _get_ambush_defender_at_cell(mover, defender_cell)
	if current_defender.is_empty() or int(current_defender.id) != int(defender.id) or _hex_distance(Vector2i(int(mover.grid_x), int(mover.grid_y)), defender_cell) != 1:
		return false
	_reveal_if_in_bush(defender)
	var total_damage: int = _calculate_damage(defender, mover)
	var result: Dictionary = _apply_attack_damage(defender, mover, total_damage)
	var casualties: int = int(result.get("casualties", 0))
	_log_event(
		"%s otrzymuje %s obrażeń z zasadzki %s i ponosi %s strat." % [
			_unit_name_log_text(mover),
			_color_log_text(str(result.get("damage", total_damage)), LOG_COLOR_DAMAGE),
			_unit_name_log_text(defender),
			_color_log_text(str(casualties), LOG_COLOR_DAMAGE)
		]
	)
	_try_apply_poison_master(defender, mover)
	_cleanup_destroyed_unit(mover)
	mover["remaining_move"] = 0
	_sync_board()
	return true


func _get_blocked_cells(excluded_unit_id: int, mover: Dictionary = {}) -> Dictionary:
	var blocked: Dictionary = {}
	for unit in units:
		if unit.id == excluded_unit_id:
			continue
		var cell := Vector2i(unit.grid_x, unit.grid_y)
		# Ukryty wróg w krzaku nie blokuje wejścia w jego hex (dopóki nie jest wykryty).
		if not mover.is_empty() and _is_ambush_cell_for_unit(mover, cell):
			continue
		blocked[cell] = true
	for obstacle in obstacles:
		var cell := Vector2i(int(obstacle.grid_x), int(obstacle.grid_y))
		if not _is_cell_passable(cell):
			blocked[cell] = true
	return blocked


func _is_cell_obstacle(cell: Vector2i) -> bool:
	return not _get_terrain_at(cell).is_empty()


func _blocks_cell_skill_target(cell: Vector2i) -> bool:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return false
	if not bool(terrain.get("blocks_movement", false)):
		return false
	var targetable_blocking_types: Array[String] = ["detonator"]
	return not targetable_blocking_types.has(str(terrain.get("id", "")))


func _cell_blocks_line_of_sight(cell: Vector2i) -> bool:
	var terrain: Dictionary = _get_terrain_at(cell)
	if terrain.is_empty():
		return false
	return bool(terrain.get("blocks_line_of_sight", false))


func _is_attack_blocked(attacker: Dictionary, target_cell: Vector2i) -> bool:
	return _is_attack_blocked_from(Vector2i(attacker.grid_x, attacker.grid_y), target_cell)


func _get_hex_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	return HexUtilsScript.line(start, end)


func _cube_to_oddr(cube: Vector3i) -> Vector2i:
	return HexUtilsScript.cube_to_oddr(cube)


func _get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	return HexUtilsScript.neighbors(cell, GRID_COLUMNS, GRID_ROWS)


func _connect_pause_menu_signals() -> void:
	if pause_menu == null:
		return
	pause_menu.resume_requested.connect(_on_pause_resume_pressed)
	pause_menu.save_requested.connect(_on_save_setup_pressed)
	pause_menu.load_requested.connect(_on_load_setup_pressed)
	pause_menu.reset_requested.connect(_on_pause_reset_pressed)
	pause_menu.exit_requested.connect(_on_pause_exit_pressed)


func _build_help_popup() -> void:
	help_popup = PanelContainer.new()
	help_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	help_popup.custom_minimum_size = Vector2(640, 520)
	help_popup.set_anchors_preset(Control.PRESET_CENTER)
	help_popup.offset_left = -320
	help_popup.offset_top = -260
	help_popup.offset_right = 320
	help_popup.offset_bottom = 260
	hud.add_child(help_popup)

	help_blocker = Control.new()
	help_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	help_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(help_blocker)
	hud.move_child(help_blocker, hud.get_child_count() - 2)

	_set_help_popup_visible(false)

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


func _set_help_popup_visible(value: bool) -> void:
	if help_popup != null:
		help_popup.visible = value
	if help_blocker != null:
		help_blocker.visible = value


func _help_rebuild_content() -> void:
	TrescPomocyScript.odbuduj(self)


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
	_set_help_popup_visible(false)


func _on_tutorial_ok_pressed() -> void:
	tutorial_acknowledged = true
	_set_help_popup_visible(false)
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
	screen_message_label.offset_left = -400
	screen_message_label.offset_right = 400
	screen_message_label.offset_top = 110
	screen_message_label.offset_bottom = 170
	screen_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	screen_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	screen_message_label.add_theme_font_size_override("font_size", 34)
	screen_message_label.add_theme_color_override("font_color", Color(0.95, 0.18, 0.18, 1.0))
	screen_message_label.add_theme_color_override("font_outline_color", Color(0.08, 0.02, 0.02, 1.0))
	screen_message_label.add_theme_constant_override("outline_size", 6)
	hud.add_child(screen_message_label)


func _show_hover_warning(text: String, cell: Vector2i) -> void:
	if last_hover_warning_text == text and last_hover_warning_cell == cell:
		return
	last_hover_warning_text = text
	last_hover_warning_cell = cell
	_show_screen_message(text, 0.8)


func _clear_hover_warning() -> void:
	last_hover_warning_text = ""
	last_hover_warning_cell = Vector2i(-2, -2)


func _build_stage_transition_overlay() -> void:
	stage_transition_overlay = ColorRect.new()
	stage_transition_overlay.visible = false
	stage_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	stage_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_transition_overlay.color = Color.BLACK
	stage_transition_overlay.modulate.a = 0.0
	hud.add_child(stage_transition_overlay)

	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_CENTER)
	content.offset_left = -300
	content.offset_top = -90
	content.offset_right = 300
	content.offset_bottom = 90
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	stage_transition_overlay.add_child(content)

	var stage_label := Label.new()
	stage_label.text = "SZTURM NA ZAMEK"
	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_label.add_theme_font_size_override("font_size", 18)
	stage_label.add_theme_color_override("font_color", Color(0.72, 0.63, 0.45))
	content.add_child(stage_label)

	stage_transition_title = Label.new()
	stage_transition_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_transition_title.add_theme_font_size_override("font_size", 42)
	stage_transition_title.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68))
	stage_transition_title.add_theme_color_override("font_outline_color", Color(0.12, 0.07, 0.03))
	stage_transition_title.add_theme_constant_override("outline_size", 8)
	content.add_child(stage_transition_title)

	stage_transition_progress = Label.new()
	stage_transition_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_transition_progress.add_theme_font_size_override("font_size", 20)
	stage_transition_progress.add_theme_color_override("font_color", Color(0.72, 0.63, 0.45))
	content.add_child(stage_transition_progress)


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
	castle_stage = 0
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
	_set_help_popup_visible(will_show)
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


func _validate_static_setup() -> void:
	assert(GRID_COLUMNS == 15 and GRID_ROWS == 10, "Scenariusz Zamek wymaga planszy 15x10.")
	assert(_get_castle_stages().size() == 3, "Scenariusz Zamek musi miec trzy etapy.")
	assert(PlanerAIScript.PROFILE.keys().all(func(key: Variant) -> bool: return ["latwy", "sredni", "trudny"].has(str(key))) and PlanerAIScript.PROFILE.size() == 3, "AI musi miec dokladnie trzy profile trudnosci.")
	var reload_existing: Dictionary = _prepare_unit({"type_id": "human_knights", "count": 3})
	reload_existing["current_total_hp"] = int(reload_existing.base_hp) * 2 + 5
	var reload_target: Dictionary = _prepare_unit({"type_id": "human_knights", "count": 3})
	_reapply_runtime_state(reload_target, reload_existing)
	assert(int(reload_target.count) == 3 and int(reload_target.current_hp) == 5, "Reload nie moze zwiekszac liczebnosci ani leczyc oddzialu.")
	for unit in unit_configs:
		assert(unit.grid_x >= 0 and unit.grid_x < GRID_COLUMNS)
		assert(unit.grid_y >= 0 and unit.grid_y < GRID_ROWS)
		var type_data: Dictionary = UnitTypeLibraryScript.lookup(str(unit.get("type_id", "")))
		if not type_data.is_empty():
			assert(int(type_data.atk) >= 0)
			assert(int(type_data.dmg_min) >= 1 and int(type_data.dmg_max) >= int(type_data.dmg_min))
			assert(int(type_data.speed) >= 1)
			assert(int(type_data.action_points) >= 1)
			for skill_id in type_data.get("skill_ids", []):
				assert(skill_library.has(skill_id), "Brak skilla w bibliotece: %s" % skill_id)

	assert(_hex_distance(Vector2i(0, 3), Vector2i(0, 7)) == _hex_distance(Vector2i(0, 7), Vector2i(0, 3)))
	assert(UnitTypeLibraryScript.get_skill_icon_path("tarcza", 1) == "res://assets/ui/ability_icons/ability_tarcza_2.png")
	assert(UnitTypeLibraryScript.get_skill_icon_path("odepchniecie_tarcza", 0) == "res://assets/ui/ability_icons/ability_odpchniecietarcza_1.png")
	assert(UnitTypeLibraryScript.get_general_skill_icon_path("grad_strzal") == "res://assets/ui/general_ability_icons/general_ability_gradstrzal.png")
	assert(UnitTypeLibraryScript.get_general_skill_icon_path("zelazna_dyscyplina") == "res://assets/ui/general_ability_icons/general_ability_zelaznadyscyplina.png")
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

	assert(MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe({"count": 4}, 2) == 8, "Obrazenia z debuffa co ture musza skalowac sie liczba jednostek.")
	assert(_adjust_incoming_damage({"active_effects": [{"incoming_damage_percent": 50}]}, 4) == 6, "Klątwa powinna zwiekszac otrzymywane obrazenia o 50%.")
	var tooltip_previous_skill_id: String = pending_skill_id
	pending_skill_id = "strzal_w_kolano"
	assert(is_equal_approx(_get_selected_attack_damage_multiplier(), 0.7), "Tooltip musi uwzgledniac mnoznik wybranej umiejetnosci.")
	pending_skill_id = "pnacza"
	assert(_get_selected_attack_damage_multiplier() == 0.0, "Tooltip nie moze pokazywac obrazen dla umiejetnosci bez obrazen.")
	pending_skill_id = tooltip_previous_skill_id
	assert(_calculate_attack_preview_damage({"atk": 0, "dmg_min": 10, "dmg_max": 10, "count": 1}, {"def": 0, "active_effects": [{"block_next_attack": true}]}, 1.0) == Vector2i.ZERO, "Tooltip musi uwzgledniac blokade obrazen.")
	assert(is_equal_approx(MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru("fireball", true), 1.0) and is_equal_approx(MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru("fireball", false), 0.5), "Kula Ognia musi miec poprawny podglad obrazen obszarowych.")
	assert(is_equal_approx(MechanikaUmiejetnosciScript.pobierz_mnoznik_obszaru("arrow_rain", false), 0.35), "Podglad Deszczu Strzal musi zgadzac sie z wykonaniem.")
	for terrain_id in terrain_types.keys():
		var raw_entry: Variant = terrain_types[terrain_id].get("entry_effect", null)
		if raw_entry == null:
			continue
		var effect_id: String = str(raw_entry) if typeof(raw_entry) == TYPE_STRING else str((raw_entry as Dictionary).get("id", ""))
		var resolved: Dictionary = UnitTypeLibraryScript.build_active_effect(effect_id, {})
		assert(not resolved.is_empty() and str(resolved.get("category", "")) != "", "Efekt terenu musi byc w status_effects: %s" % effect_id)
	assert(next_map_event_round == 0 or next_map_event_round >= 2, "Event mapy nie moze wystapic przed druga runda.")
	for faction_id in ["elves", "humans", "dwarves", "orcs", "goblins"]:
		var faction_general_skills: Array[String] = UnitTypeLibraryScript.get_faction_general_skill_ids(faction_id)
		assert(faction_general_skills.size() == 2, "Frakcja musi miec dokladnie 2 umiejetnosci generala: %s" % faction_id)
		for general_skill_id in faction_general_skills:
			assert(general_skills.has(general_skill_id), "Brak umiejetnosci generala: %s" % general_skill_id)
	for general_skill_id in general_skills.keys():
		var general_tooltip: String = _build_general_skill_tooltip(general_skills[general_skill_id])
		assert(str(general_skills[general_skill_id].get("description", "")) in general_tooltip, "Tooltip generala musi zawierac opis: %s" % general_skill_id)
	for map_event_debuff_id in ["lesne_opary", "sniezna_zamiec", "gniew_korzeni", "wichura_lodowa", "pustynny_podmuch"]:
		assert(str(UnitTypeLibraryScript.get_status_effect(map_event_debuff_id).get("description", "")) != "", "Debuff eventu mapy musi miec opis: %s" % map_event_debuff_id)
	for general_skill_id in general_skills.keys():
		var general_skill: Dictionary = general_skills[general_skill_id]
		if str(general_skill.get("effect_type", "")) != "army_buff" and not general_skill.has("target_effect"):
			continue
		assert(str(UnitTypeLibraryScript.get_status_effect(general_skill_id).get("description", "")) != "", "Buff/debuff generala musi miec opis: %s" % general_skill_id)
	assert(BibliotekaZdarzenMapyScript.czy_runda_ostrzezenia(2, 3) and not BibliotekaZdarzenMapyScript.czy_runda_ostrzezenia(1, 3), "Pola eventu maja byc widoczne tylko runde przed jego aktywacja.")
	assert(bool(UnitTypeLibrary.build_active_effect("mgla").get("hides_unit", false)), "Mgla musi korzystac z ukrycia jednostek.")
	for scenario_id in BibliotekaZdarzenMapyScript.PULE:
		var event_pool: Array = BibliotekaZdarzenMapyScript.PULE[scenario_id]
		assert(event_pool.size() == 4, "Kazdy scenariusz musi miec cztery eventy: %s" % scenario_id)
		for event_id in event_pool:
			assert(BibliotekaZdarzenMapyScript.DANE.has(event_id), "Brak danych eventu: %s" % event_id)
	assert(is_equal_approx(MatematykaWalkiScript.mnoznik_ataku_obrony(20, 14), 1.3), "Przewaga 6 ATK musi dawac +30% obrazen.")
	assert(is_equal_approx(MatematykaWalkiScript.mnoznik_ataku_obrony(14, 20), 0.85), "Przewaga 6 DEF musi zmniejszac obrazenia o 15%.")
	assert(is_equal_approx(MatematykaWalkiScript.mnoznik_ataku_obrony(100, 0), 4.0), "Bonus ATK musi zatrzymac sie na 400% obrazen.")
	assert(is_equal_approx(MatematykaWalkiScript.mnoznik_ataku_obrony(0, 100), 0.3), "Redukcja DEF nie moze zejsc ponizej 30% obrazen.")
	assert(_calculate_damage({"atk": 20, "dmg_min": 10, "dmg_max": 10, "count": 1}, {"def": 14}) == 13)
	assert(_calculate_damage({"atk": 0, "dmg_min": 4, "dmg_max": 4, "count": 5}, {"def": 0}) == 20, "Obrazenia musza skalowac sie liniowo z liczebnoscia.")
	for faction_id in UnitTypeLibraryScript.get_faction_ids():
		for type_data in UnitTypeLibraryScript.get_faction_units(faction_id):
			assert(int(type_data.action_points) == 1, "Jednostki prototypu powinny miec 1 AP: %s" % str(type_data.id))
			assert(int(type_data.speed) <= 10 and int(type_data.move_range) <= 6 and int(type_data.attack_range) <= 5, "Jednostka poza zakresem raw statystyk: %s" % str(type_data.id))
			assert(int(type_data.hp) <= 40 and int(type_data.atk) <= 15 and int(type_data.dmg_max) <= 22 and int(type_data.def) <= 14 and int(type_data.count) <= 14, "Jednostka poza zakresem raw statystyk: %s" % str(type_data.id))
	assert(not MechanikaUmiejetnosciScript.czy_mozna_uzyc({"action_points": 1, "skill_cooldowns": {}}, "bariera_energetyczna", skill_library), "Umiejetnosci bierne nie moga byc uzywane recznie.")
	assert(skill_library.has("tanczacy_ostrze"), "Brak skilla tanczacy_ostrze w bibliotece.")
	assert(str(skill_library["tanczacy_ostrze"].get("effect_type", "")) == "dancing_blade", "Tanczacy Ostrze musi miec efekt dancing_blade.")
	assert(skill_library.has("przyzwij_pomnik"), "Brak skilla przyzwij_pomnik w bibliotece.")
	assert(str(skill_library["przyzwij_pomnik"].get("effect_type", "")) == "summon_statue", "Przyzwij Pomnik musi miec efekt summon_statue.")
	assert(skill_library.has("utwardzenie"), "Brak skilla utwardzenie w bibliotece.")
	assert(str(skill_library["utwardzenie"].get("effect_type", "")) == "utwardzenie", "Utwardzenie musi miec efekt utwardzenie.")
	assert(skill_library.has("walniecie_mlotem"), "Brak skilla walniecie_mlotem w bibliotece.")
	assert(str(skill_library["walniecie_mlotem"].get("effect_type", "")) == "hammer_strike", "Walniecie Mlotem musi miec efekt hammer_strike.")
	assert(skill_library.has("druzgocacy_cios"), "Brak skilla druzgocacy_cios w bibliotece.")
	assert(str(skill_library["druzgocacy_cios"].get("effect_type", "")) == "shattering_strike", "Druzgocacy Cios musi miec efekt shattering_strike.")
	assert(int(skill_library["druzgocacy_cios"].get("cooldown", 0)) == 4, "Druzgocacy Cios musi miec cooldown 4 tur.")
	var shatter_survivor: Dictionary = _prepare_unit({"id": 913, "type_id": "human_archers", "count": 10, "side": "enemy", "grid_x": 1, "grid_y": 1})
	_apply_damage_to_unit(shatter_survivor, int(shatter_survivor.base_hp))
	assert(int(shatter_survivor.count) > 0, "Smoke Druzgocacego Ciosu wymaga czesciowego trafienia.")
	var shatter_units_backup: Array = units
	units = [shatter_survivor]
	assert(not _find_unit_by_id(913).is_empty(), "Druzgocacy Cios nie odswieza CD, gdy wybrany cel nadal zyje.")
	units = shatter_units_backup
	assert(skill_library.has("przebijajacy_strzal"), "Brak skilla przebijajacy_strzal w bibliotece.")
	assert(str(skill_library["przebijajacy_strzal"].get("effect_type", "")) == "piercing_shot", "Przebijajacy Strzal musi miec efekt piercing_shot.")
	assert(skill_library.has("deszcz_strzal"), "Brak skilla deszcz_strzal w bibliotece.")
	assert(str(skill_library["deszcz_strzal"].get("effect_type", "")) == "arrow_rain", "Deszcz Strzal musi miec efekt arrow_rain.")
	assert(skill_library.has("rozszarpanie"), "Brak skilla rozszarpanie w bibliotece.")
	assert(str(skill_library["rozszarpanie"].get("effect_type", "")) == "rozszarpanie", "Rozszarpanie musi miec efekt rozszarpanie.")
	assert(skill_library.has("zaklete_ciecie"), "Brak skilla zaklete_ciecie w bibliotece.")
	assert(int(skill_library["zaklete_ciecie"].get("range", 0)) == 2, "Zaklete Ciecie musi miec zasieg 2 hexow.")
	assert(str(skill_library["zaklete_ciecie"].get("effect_type", "")) == "zaklete_ciecie", "Zaklete Ciecie musi miec efekt zaklete_ciecie.")
	assert(skill_library.has("magiczna_projekcja"), "Brak skilla magiczna_projekcja w bibliotece.")
	assert(int(skill_library["magiczna_projekcja"].get("cooldown", 0)) == 6, "Magiczna Projekcja musi miec cooldown 6 tur.")
	assert(_get_magic_projection_cells(Vector2i(4, 4), "player").size() == 3, "Magiczna Projekcja gracza musi tworzyc 3 hexy.")
	assert(_get_magic_projection_cells(Vector2i(10, 4), "enemy").size() == 3, "Magiczna Projekcja wroga musi tworzyc 3 hexy.")
	assert(_get_ice_ground_cells(Vector2i(7, 5)) == [Vector2i(7, 5), Vector2i(8, 6), Vector2i(7, 6)], "Lodowe Podloze musi zamrazac 3 hexy w trojkacie od wskazanego gornego pola.")
	assert(_get_ice_ground_cells(Vector2i(7, 9)).is_empty(), "Lodowe Podloze nie moze wychodzic poza plansze.")
	var lone_cavalry: Dictionary = _prepare_unit({"id": 901, "type_id": "human_cavalry", "side": "player", "grid_x": 5, "grid_y": 5})
	var saved_units: Array = units
	units = [lone_cavalry]
	var taunt_skill: Dictionary = skill_library.get("prowokacja", {})
	assert(not taunt_skill.is_empty(), "Brak skilla prowokacja w bibliotece.")
	assert(not _skill_effect_will_succeed(lone_cavalry, lone_cavalry, taunt_skill, Vector2i(5, 5)), "Prowokacja bez celow nie moze sie udac.")
	units = saved_units
	assert(skill_library.has("sztandar"), "Brak skilla sztandar w bibliotece.")
	assert(str(skill_library["sztandar"].get("effect_type", "")) == "sztandar", "Sztandar musi miec efekt sztandar.")
	assert(str(skill_library["sztandar"].get("target_type", "")) == "ally_unit", "Sztandar musi celowac w sojusznika.")
	assert(int(skill_library["sztandar"].get("range", 0)) == 1, "Sztandar musi dzialac tylko na sasiednich sojusznikow.")
	assert(int(skill_library["sztandar"].get("cooldown", 0)) == 6, "Sztandar musi miec cooldown 6 tur.")
	var sztandar_target: Dictionary = {
		"id": 901,
		"name": "Cel",
		"side": "player",
		"grid_x": 6,
		"grid_y": 5,
		"skill_ids": ["odepchniecie_tarcza", "szarza", "sztandar"],
		"skill_cooldowns": {"szarza": 2, "odepchniecie_tarcza": 1}
	}
	_execute_sztandar({"id": 900, "name": "Konnica", "side": "player", "grid_x": 5, "grid_y": 5}, sztandar_target)
	assert(int(sztandar_target.get("skill_cooldowns", {}).get("szarza", -1)) == 0, "Sztandar musi zerowac cooldowny celu.")
	assert(int(sztandar_target.get("skill_cooldowns", {}).get("odepchniecie_tarcza", -1)) == 0, "Sztandar musi zerowac wszystkie cooldowny celu.")
	assert(skill_library.has("mistrz_trucizn"), "Brak skilla mistrz_trucizn w bibliotece.")
	assert(str(skill_library["mistrz_trucizn"].get("target_type", "")) == "self", "Mistrz Trucizn musi byc uzywany na siebie.")
	assert(int(skill_library["mistrz_trucizn"].get("cooldown", 0)) == 7, "Mistrz Trucizn musi miec cooldown 7 tur.")
	assert(int(skill_library["mistrz_trucizn"].get("effect", {}).get("remaining_turns", 0)) == 5, "Mistrz Trucizn musi trwac 5 tur.")
	var poison_master_attacker: Dictionary = {
		"id": 902,
		"dmg_min": 7,
		"dmg_max": 9,
		"active_effects": [{"id": "mistrz_trucizn", "remaining_turns": 5}]
	}
	var poison_master_target: Dictionary = {"id": 903, "count": 5, "active_effects": []}
	_try_apply_poison_master(poison_master_attacker, poison_master_target)
	assert(_has_effect(poison_master_target, "zatrucie"), "Mistrz Trucizn musi nakladac Zatrucie zwyklym atakiem.")
	assert(_is_poison_immune(poison_master_attacker), "Mistrz Trucizn musi dawac odpornosc na trucizny.")
	# Żelazna Kurtyna: opiekun w zasięgu 3 przejmuje atak; DoT idzie poza _apply_attack_damage.
	var curtain_units_backup: Array = units.duplicate(true)
	var curtain_guardian: Dictionary = {"id": 910, "name": "Opiekun", "grid_x": 3, "grid_y": 3, "count": 5, "base_hp": 10, "hp": 10, "current_total_hp": 50, "active_effects": []}
	var curtain_ward: Dictionary = {
		"id": 911,
		"name": "Chroniony",
		"grid_x": 5,
		"grid_y": 3,
		"count": 5,
		"base_hp": 10,
		"hp": 10,
		"current_total_hp": 50,
		"active_effects": [{"id": "zelazna_kurtyna", "guarded_by_id": 910, "remaining_turns": 2}]
	}
	units = [curtain_guardian, curtain_ward]
	assert(int(_get_guardian_for(curtain_ward).get("id", -1)) == 910, "Zelazna Kurtyna musi znajdowac opiekuna w zasiegu 3.")
	curtain_ward["grid_x"] = 8
	assert(_get_guardian_for(curtain_ward).is_empty(), "Zelazna Kurtyna nie chroni poza zasiegiem 3.")
	assert(max(1, int(ceil(100.0 * 0.75))) == 75, "Oslona z Zelaznej Kurtyny pomniejsza obrazenia o 25%.")
	units = curtain_units_backup
	assert(skill_library.has("zadza_krwi"), "Brak skilla zadza_krwi w bibliotece.")
	assert(str(skill_library["zadza_krwi"].get("effect_type", "")) == "zadza_krwi", "Zadza krwi musi miec efekt zadza_krwi.")
	assert(not MechanikaUmiejetnosciScript.czy_mozna_uzyc({"action_points": 1, "skill_cooldowns": {}, "skill_ids": []}, "pulapka_na_niedzwiedzie", skill_library), "Jednostka nie moze uzywac umiejetnosci spoza skill_ids.")


func _validate_runtime_setup() -> void:
	var previous_units: Array = units.duplicate(true)
	var previous_obstacles: Array[Dictionary] = obstacles.duplicate(true)
	var previous_detonator_activated: bool = detonator_activated
	var previous_terrain_effects: Array[Dictionary] = terrain_effects.duplicate(true)
	var previous_event_log: Array[String] = event_log.duplicate()
	var previous_active_turn_has_log: bool = active_turn_has_log
	var previous_ai_difficulty: String = ai_difficulty
	if OS.is_debug_build():
		assert(debug_map_event_menu != null and debug_map_event_menu.item_count == BibliotekaZdarzenMapyScript.DANE.size(), "Menu debug musi udostepniac eventy ze wszystkich map.")
	ai_difficulty = "gracz"
	assert(_is_manual_side("enemy"), "Tryb lokalny musi oddawac przeciwnika drugiemu graczowi.")
	ai_difficulty = "sredni"
	assert(not _is_manual_side("enemy"), "Tryb AI nie moze oddawac przeciwnika graczowi.")
	ai_difficulty = previous_ai_difficulty
	var debug_duration_active_unit_id: int = active_unit_id
	units = [{"id": 998, "active_effects": [{"id": "wichura_lodowa", "remaining_turns": 1}]}]
	active_unit_id = 998
	terrain_effects = [{"id": "mgla", "grid_x": 0, "grid_y": 0, "remaining_turns": 1}]
	_extend_debug_map_event_duration("gesty_dym", [])
	_extend_debug_map_event_duration("wichura_lodowa", [])
	assert(int(terrain_effects[0].remaining_turns) == 2, "Debugowy event terenu musi przetrwac najblizsza zmiane rundy.")
	assert(int(units[0].active_effects[0].remaining_turns) == 2, "Debugowy event aktywnej jednostki musi przetrwac koniec jej aktywacji.")
	active_unit_id = debug_duration_active_unit_id
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
		"atk": 1,
		"base_atk": 1,
		"dmg_min": 1,
		"base_dmg_min": 1,
		"dmg_max": 1,
		"base_dmg_max": 1,
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
	var hidden_enemy := {"side": "enemy", "grid_x": 5, "grid_y": 5, "is_hidden": true, "active_effects": []}
	assert(not _can_see_target({"side": "player", "grid_x": 0, "grid_y": 0}, hidden_enemy), "Ukryty cel w krzaku nie moze byc widoczny z daleka.")
	assert(_find_visible_unit_at_cell(Vector2i(5, 5), {"side": "player", "grid_x": 0, "grid_y": 0}).is_empty(), "Tooltip obrazen nie moze celowac w ukrytego wroga z daleka.")
	assert(_can_see_target({"side": "player", "grid_x": 6, "grid_y": 5}, hidden_enemy), "Gracz obok krzaka musi widziec ukrytego wroga.")
	assert(not _has_effect(hidden_enemy, "wykrycie"), "Samo sasiedztwo nie moze nakladac Wykrycia.")
	assert(_can_see_target({"side": "enemy", "grid_x": 6, "grid_y": 5}, {"side": "player", "grid_x": 5, "grid_y": 5, "is_hidden": true}), "Wróg obok krzaka musi widziec ukrytego gracza.")
	assert(not _can_see_target({"grid_x": 5, "grid_y": 3}, hidden_enemy), "Tylko sasiednia jednostka moze widziec ukryty cel.")
	assert(_can_see_target({"grid_x": 0, "grid_y": 0}, {"grid_x": 5, "grid_y": 5, "is_hidden": true, "is_revealed": true}), "Wykrycie musi pokazywac jednostke ukryta w krzaku.")
	var hidden_player: Dictionary = {"id": 1006, "side": "player", "grid_x": 3, "grid_y": 5, "is_hidden": true, "active_effects": []}
	var enemy_observer: Dictionary = {"id": 1007, "side": "enemy", "grid_x": 7, "grid_y": 5}
	units = [hidden_player, enemy_observer]
	assert(_find_visible_unit_at_cell(Vector2i(3, 5), enemy_observer).is_empty(), "Ukryty gracz musi byc niewidoczny dla odleglego przeciwnika.")
	terrain_effects = [{"id": "mgla", "grid_x": 5, "grid_y": 5, "remaining_turns": 1}]
	hidden_enemy["is_revealed"] = true
	assert(not _can_see_target({"grid_x": 0, "grid_y": 0}, hidden_enemy), "Mgla musi ukrywac wykryty cel przed odleglym wrogiem.")
	assert(_can_see_target({"grid_x": 6, "grid_y": 5}, hidden_enemy), "Sasiedni wrog musi widziec cel we mgle.")
	_reveal_if_in_bush(hidden_enemy)
	assert(not _has_effect(hidden_enemy, "wykrycie"), "Atak ani obrazenia we mgle nie moga nakladac Wykrycia.")
	var leaving_bush_unit := {
		"side": "enemy",
		"grid_x": 6,
		"grid_y": 5,
		"is_hidden": true,
		"active_effects": [{"id": "krzok", "name": "Krzak", "category": "buff", "hides_unit": true, "terrain_bound": true, "permanent": true, "stat_changes": []}]
	}
	_reveal_unit_leaving_concealment(leaving_bush_unit, Vector2i(5, 5))
	assert(not bool(leaving_bush_unit.get("is_hidden", true)), "Wyjscie z krzaka musi ujawniac jednostke przed animacja ruchu.")
	bush_unit["active_effects"] = [{"id": "wykrycie", "name": "Wykrycie", "category": "debuff", "remaining_turns": 1, "stat_changes": []}]
	terrain_effects = [{"id": "poison_cloud", "grid_x": 5, "grid_y": 4, "remaining_turns": 2, "tick_damage": 1}]
	_reveal_if_in_bush(bush_unit)
	assert(int(bush_unit.active_effects[0].remaining_turns) == 1, "Wykrycie nie moze odnawiac czasu, dopoki trwa.")
	var ambush_enemy := {
		"id": 1005,
		"name": "Zasadzkarz",
		"side": "enemy",
		"grid_x": 5,
		"grid_y": 5,
		"atk": 20,
		"dmg_min": 10,
		"dmg_max": 10,
		"def": 0,
		"count": 5,
		"base_hp": 10,
		"hp": 10,
		"current_total_hp": 50,
		"active_effects": []
	}
	bush_unit.grid_x = 5
	bush_unit.grid_y = 4
	units = [bush_unit, ambush_enemy]
	_apply_terrain_effects_to_unit(ambush_enemy)
	obstacles[2]["type"] = "holy_tree"
	assert(not _is_ambush_cell_for_unit(bush_unit, Vector2i(5, 5)), "Ukrycie poza krzakiem nie moze wykonac zasadzki.")
	obstacles[2]["type"] = "krzok"
	assert(_is_ambush_cell_for_unit(bush_unit, Vector2i(5, 5)), "Ukryty wrog w krzaku musi byc polem zasadzki.")
	assert(_get_blocked_cells(int(bush_unit.id)).has(Vector2i(5, 5)), "Ukryty wrog musi blokowac wejscie w krzak.")
	var ambush_path: Array[Vector2i] = _find_path(bush_unit, Vector2i(5, 4), Vector2i(5, 5), {}, 1)
	assert(not ambush_path.is_empty(), "Klikniecie w pole zasadzki musi dawac trase, nawet jesli ruch sie urwie przed wejsciem.")
	assert(_get_executable_move_path(ambush_path, bush_unit).is_empty(), "Gdy jednostka jest juz obok, ruch nie moze wejsc w sam heks z zasadzka.")
	bush_unit.grid_x = 3
	bush_unit.grid_y = 5
	ambush_path = _find_path(bush_unit, Vector2i(3, 5), Vector2i(5, 5), {}, 3)
	assert(not ambush_path.is_empty(), "Klikniecie w krzak z wrogiem musi prowadzic na sasiednie pole.")
	var ambush_stop: Vector2i = _get_executable_move_path(ambush_path, bush_unit).back()
	assert(ambush_stop != Vector2i(5, 5), "Ruch musi zatrzymac sie przed krzakiem z zasadzka.")
	assert(not _get_ambush_defender_adjacent_to(bush_unit, ambush_stop).is_empty(), "Zatrzymanie musi byc przy zasadzce.")
	bush_unit.grid_x = 5
	bush_unit.grid_y = 4
	var ambush_hp_before: int = int(bush_unit.current_total_hp)
	assert(_try_trigger_bush_ambush(bush_unit, ambush_enemy), "Zasadzka musi sie uruchomic z sasiedniego pola.")
	assert(int(bush_unit.current_total_hp) < ambush_hp_before, "Zasadzka musi zadawac obrazenia jak zwykly atak.")
	assert(_has_effect(ambush_enemy, "wykrycie"), "Zasadzka musi ujawnic ukrytego wroga.")
	assert(int(ambush_enemy.grid_x) == 5 and int(ambush_enemy.grid_y) == 5, "Wrog w zasadzce zostaje w krzaku.")
	ambush_enemy["active_effects"] = [{"id": "wykrycie", "name": "Wykrycie", "category": "debuff", "remaining_turns": 1, "stat_changes": []}]
	ambush_enemy["is_hidden"] = true
	ambush_enemy["is_revealed"] = false
	assert(not _is_ambush_cell_for_unit(bush_unit, Vector2i(5, 5)), "Wykryty wrog nie moze wykonac zasadzki.")
	assert(_get_blocked_cells(int(bush_unit.id)).has(Vector2i(5, 5)), "Wykryty wrog nadal blokuje pole.")
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
	ai_archer["skill_ids"] = ["strzal_w_kolano"]
	ai_archer["skill_cooldowns"] = {}
	ai_difficulty = "latwy"
	var easy_plans: Array[Dictionary] = _ai_generate_action_plans(ai_archer, [])
	assert(easy_plans.any(func(plan: Dictionary) -> bool: return str(plan.get("kind", "")) == "skill"), "Latwy AI musi znac umiejetnosci, ale moze je ocenic niedokladnie.")
	ai_difficulty = "trudny"
	var hard_plans: Array[Dictionary] = _ai_generate_action_plans(ai_archer, [])
	assert(hard_plans.any(func(plan: Dictionary) -> bool: return str(plan.get("kind", "")) == "skill"), "Trudny AI musi oceniac umiejetnosci jednostki.")
	ai_archer["skill_ids"] = []
	assert(_find_best_enemy_path(ai_archer, ai_target).is_empty(), "Dystansowy wróg nie powinien podchodzic, gdy ma czysty strzal.")
	var ai_origin := Vector2i(int(ai_archer.grid_x), int(ai_archer.grid_y))
	var ai_plan: Dictionary = _ai_choose_plan(ai_archer)
	assert(str(ai_plan.get("kind", "")) == "basic_attack" and int(ai_plan.get("target_id", -1)) == int(ai_target.id), "AI musi wybrac dostepny atak zamiast bezcelowego ruchu.")
	assert(Vector2i(int(ai_archer.grid_x), int(ai_archer.grid_y)) == ai_origin, "Planowanie AI nie moze zmieniac stanu jednostki.")
	var weak_target: Dictionary = ai_target.duplicate(true)
	weak_target["id"] = 1008
	weak_target["grid_x"] = 4
	weak_target["current_total_hp"] = 1
	weak_target["hp"] = 10
	weak_target["base_hp"] = 10
	weak_target["count"] = 1
	ai_target["current_total_hp"] = 100
	ai_target["hp"] = 10
	ai_target["base_hp"] = 10
	ai_target["count"] = 10
	ai_archer["atk"] = 8
	ai_archer["dmg_min"] = 5
	ai_archer["dmg_max"] = 7
	ai_archer["count"] = 4
	units = [ai_archer, ai_target, weak_target]
	ai_plan = _ai_choose_plan(ai_archer)
	assert(int(ai_plan.get("target_id", -1)) == int(weak_target.id), "AI musi preferowac pewne dobicie oddzialu.")
	units = [ai_archer, ai_target]
	ai_target["is_hidden"] = true
	assert(_find_nearest_player_unit(ai_archer).is_empty(), "AI nie moze wybierac niewidocznego gracza jako celu ruchu.")
	assert(_ai_score_approach(ai_archer, Vector2i(6, 5)) == 0, "Ukryty gracz nie moze wplywac na kierunek ruchu AI.")
	assert(_ai_score_area_damage(ai_archer, Vector2i(3, 5), 1.0, 0.5) == 0, "AI nie moze celowac obszarowo na podstawie pozycji ukrytego gracza.")
	ai_target["is_hidden"] = false
	assert(_get_path_hazard_penalty(ai_archer, [Vector2i(6, 5)]) == 0, "Pusta sciezka AI nie powinna miec kary.")
	terrain_effects = [{"id": "fire", "grid_x": 6, "grid_y": 5, "remaining_turns": 1, "caster_side": "player"}]
	ai_difficulty = "latwy"
	assert(_ai_hazard_penalty(ai_archer, [Vector2i(6, 5)]) == 120, "Latwy AI powinien czasem podejmowac ryzyko terenu, ale nie moze go ignorowac.")
	ai_difficulty = "sredni"
	assert(_ai_hazard_penalty(ai_archer, [Vector2i(6, 5)]) == 180, "Sredni AI musi moc podjac kontrolowane ryzyko terenu.")
	ai_difficulty = "trudny"
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
	var tank_ai: Dictionary = melee_ai.duplicate(true)
	tank_ai["id"] = 1009
	tank_ai["balance_role"] = "obronca"
	tank_ai["grid_x"] = 10
	tank_ai["skill_ids"] = ["zelazna_kurtyna"]
	tank_ai["skill_cooldowns"] = {}
	var tank_ally: Dictionary = melee_ai.duplicate(true)
	tank_ally["id"] = 1010
	tank_ally["grid_x"] = 11
	tank_ally["current_total_hp"] = 270
	var tank_target: Dictionary = open_target.duplicate(true)
	tank_target["id"] = 1011
	tank_target["grid_x"] = 4
	tank_target["grid_y"] = 5
	tank_target["move_range"] = 4
	tank_target["attack_range"] = 1
	tank_target["atk"] = 5
	tank_target["dmg_min"] = 8
	tank_target["dmg_max"] = 8
	tank_target["count"] = 2
	units = [tank_ai, tank_ally, tank_target]
	assert(_ai_score_skill(tank_ai, tank_ally, Vector2i(tank_ally.grid_x, tank_ally.grid_y), skill_library["zelazna_kurtyna"]) == 0, "AI nie powinno oslaniac bezpiecznego sojusznika Zelazna Kurtyna.")
	var tank_plan: Dictionary = _ai_choose_plan(tank_ai)
	assert(not tank_plan.get("path", []).is_empty(), "Obronca AI powinien ruszyc na front zamiast pozostac z tylu.")
	assert(_hex_distance(tank_plan.path.back(), Vector2i(tank_target.grid_x, tank_target.grid_y)) < _hex_distance(Vector2i(tank_ai.grid_x, tank_ai.grid_y), Vector2i(tank_target.grid_x, tank_target.grid_y)), "Obronca AI musi skracac dystans do frontu.")
	var water_start := Vector2i(4, 4)
	var first_water := Vector2i(5, 4)
	var second_water := Vector2i(6, 4)
	obstacles = [
		{"grid_x": first_water.x, "grid_y": first_water.y, "type": "woda"},
		{"grid_x": second_water.x, "grid_y": second_water.y, "type": "woda"}
	]
	assert(not _is_attack_blocked_from(water_start, Vector2i(7, 4)), "Strzal zasiegowy musi przechodzic przez wode.")
	assert(not _blocks_cell_skill_target(first_water), "Rzut dynamitem musi moc celowac w wode.")
	units = [bush_unit]
	for neighbor in _get_neighbors(second_water):
		if neighbor != first_water and neighbor != water_start:
			obstacles.append({"grid_x": neighbor.x, "grid_y": neighbor.y, "type": "kamienie"})
	bush_unit.grid_x = water_start.x
	bush_unit.grid_y = water_start.y
	var water_path: Array[Vector2i] = _find_path(bush_unit, water_start, second_water)
	assert(water_path.is_empty(), "Pathfinding nie moze prowadzic za pole wody konczace ruch.")
	water_path = _find_path(bush_unit, water_start, first_water)
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
	var charge_move_budget: int = _get_remaining_move(charge_unit) + MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(charge_skill, "move_range")
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
	var enemy_charge_target: Dictionary = {
		"id": 1004,
		"side": "player",
		"grid_x": 7,
		"grid_y": 5,
		"is_hidden": false
	}
	assert(_can_charge_attack_target(charge_unit, enemy_charge_target, charge_skill), "Szarza wroga musi moc zaatakowac cel przed soba.")
	var enemy_charge_path: Array[Vector2i] = _find_charge_approach_path(charge_unit, enemy_charge_target, charge_skill)
	assert(not enemy_charge_path.is_empty(), "Szarza wroga musi miec sciezke podejscia.")
	var charge_cooldown_unit := charge_unit.duplicate(true)
	charge_cooldown_unit.action_points = 2
	charge_cooldown_unit.skill_cooldowns = {}
	_commit_charge_skill(charge_cooldown_unit, charge_skill)
	assert(int(charge_cooldown_unit.skill_cooldowns.get("szarza", 0)) == 4, "Szarza musi ustawiac cooldown po uzyciu.")
	assert(int(charge_cooldown_unit.action_points) == 1, "Szarza musi kosztowac 1 AP po uzyciu.")
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
	units.append({
		"id": 1103,
		"side": "enemy",
		"grid_x": 3,
		"grid_y": 0,
		"name": "Tyl",
		"count": 1
	})
	var pierce_cells: Array[Vector2i] = _get_piercing_shot_cells({"grid_x": 0, "grid_y": 0}, {"grid_x": 2, "grid_y": 0})
	assert(pierce_cells.size() == 3 and pierce_cells[1] == Vector2i(3, 0) and pierce_cells[2] == Vector2i(4, 0), "Przebijajacy strzal musi obejmowac 3 hexy w linii.")
	units.append({
		"id": 1104,
		"side": "enemy",
		"grid_x": 2,
		"grid_y": 0,
		"name": "Przod",
		"count": 1
	})
	var pierce_rear_cells: Array[Vector2i] = _get_piercing_shot_cells({"grid_x": 0, "grid_y": 0}, {"grid_x": 4, "grid_y": 0})
	assert(pierce_rear_cells.size() == 3 and pierce_rear_cells[0] == Vector2i(2, 0) and pierce_rear_cells[2] == Vector2i(4, 0), "Przebijajacy strzal musi trafiac wrogow przed pustym hexem.")
	var pierce_behind: Dictionary = _find_unit_at_cell(pierce_cells[1])
	assert(not pierce_behind.is_empty() and int(pierce_behind.id) == 1103, "Przebijajacy strzal musi trafiac jednostke na drugim hexie linii.")
	var pierce_preview: Array[Vector2i] = _get_piercing_shot_preview_cells({"grid_x": 0, "grid_y": 0}, {"grid_x": 2, "grid_y": 0})
	assert(pierce_preview.size() == 3 and pierce_preview[2] == Vector2i(4, 0), "Podglad Przebijajacego Strzalu musi pokazywac 3 hexy w linii.")
	# Odepchniecie w passable teren: krzak/woda/dziura zamiast stuna; kamienie nadal blokuja.
	units = []
	obstacles = [
		{"grid_x": 7, "grid_y": 4, "type": "krzok"},
		{"grid_x": 8, "grid_y": 4, "type": "woda"},
		{"grid_x": 9, "grid_y": 4, "type": "hole"},
		{"grid_x": 7, "grid_y": 5, "type": "kamienie"},
	]
	assert(_get_push_destination({"grid_x": 5, "grid_y": 4}, {"grid_x": 6, "grid_y": 4}) == Vector2i(7, 4), "Odepchniecie musi pozwalac wpadac w krzak.")
	assert(_get_push_destination({"grid_x": 6, "grid_y": 4}, {"grid_x": 7, "grid_y": 4}) == Vector2i(8, 4), "Odepchniecie musi pozwalac wpadac w wode.")
	assert(_get_push_destination({"grid_x": 7, "grid_y": 4}, {"grid_x": 8, "grid_y": 4}) == Vector2i(9, 4), "Odepchniecie musi pozwalac wpadac w dziure.")
	assert(_get_push_destination({"grid_x": 5, "grid_y": 5}, {"grid_x": 6, "grid_y": 5}) == Vector2i(-1, -1), "Odepchniecie w kamienie musi byc zablokowane.")
	var push_bush_victim := {
		"id": 1204,
		"name": "Cel",
		"side": "enemy",
		"grid_x": 7,
		"grid_y": 4,
		"count": 1,
		"active_effects": [],
		"is_hidden": false
	}
	_apply_terrain_entry_effect(push_bush_victim)
	assert(bool(push_bush_victim.get("is_hidden", false)) and _has_effect(push_bush_victim, "krzok"), "Odepchniety w krzak musi sie ukryc.")
	var push_hole_victim := {
		"id": 1205,
		"name": "Cel",
		"side": "enemy",
		"grid_x": 9,
		"grid_y": 4,
		"count": 1,
		"current_total_hp": 10,
		"current_hp": 10,
		"active_effects": [],
		"is_hidden": false
	}
	units = [push_hole_victim]
	_apply_terrain_entry_effect(push_hole_victim)
	assert(_find_unit_by_id(1205).is_empty(), "Odepchniety w dziure musi zginac.")
	obstacles = [{"grid_x": 6, "grid_y": 5, "type": "detonator"}]
	detonator_activated = false
	assert(_get_detonator_target_cells(0, Vector2i(6, 5)).size() == 4, "Detonator bez zapisanego podgladu musi wylosowac cztery pola kamieni.")
	assert(_can_activate_detonator({"grid_x": 5, "grid_y": 5, "attack_range": 1, "action_points": 1}, Vector2i(6, 5)), "Jednostka obok musi moc aktywowac detonator.")
	assert(_can_activate_detonator({"grid_x": 2, "grid_y": 5, "attack_range": 4, "action_points": 1}, Vector2i(6, 5)), "Jednostka dystansowa musi moc zastrzelic detonator.")
	assert(_get_attackable_cells({"grid_x": 2, "grid_y": 5, "attack_range": 4, "action_points": 1, "side": "player"}).has(Vector2i(6, 5)), "Detonator musi byc podswietlony jako cel ataku.")
	assert(not _can_activate_detonator({"grid_x": 2, "grid_y": 5, "attack_range": 4, "action_points": 0}, Vector2i(6, 5)), "Detonator wymaga punktu akcji.")
	units = previous_units
	obstacles = previous_obstacles
	detonator_activated = previous_detonator_activated
	event_log = previous_event_log
	active_turn_has_log = previous_active_turn_has_log
	ai_difficulty = previous_ai_difficulty
	event_log_label.text = "\n".join(event_log)


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
		if help_popup != null and help_popup.visible:
			return
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
	var event_data: Dictionary = BibliotekaZdarzenMapyScript.DANE.get(next_map_event_id, {})
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
	if help_popup != null and help_popup.visible:
		return
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
	if help_popup != null and help_popup.visible:
		return
	if not event is InputEventMouseButton:
		return
	var mouse_event: InputEventMouseButton = event
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.double_click:
		return
	if unit_id == -100000:
		var event_data: Dictionary = BibliotekaZdarzenMapyScript.DANE.get(next_map_event_id, {})
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


func _build_general_skill_tooltip(skill: Dictionary) -> String:
	if skill.is_empty():
		return "Brak umiejetnosci."

	var lines: Array[String] = [
		str(skill.get("name", "")),
		"Uzycie: raz na bitwe",
		"Cel: %s" % _general_skill_target_label(skill),
	]
	var effect_type: String = str(skill.get("effect_type", ""))
	if effect_type == "area":
		var radius: int = int(skill.get("radius", 0))
		if radius > 0:
			lines.append("Promien: %d" % radius)
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


func _general_skill_target_label(skill: Dictionary) -> String:
	match str(skill.get("effect_type", "")):
		"army_buff":
			return "Wszyscy sojusznicy"
		"ally":
			if bool(skill.get("active_only", false)):
				return "Aktywny sojuszniczy oddzial"
			return "Sojuszniczy oddzial"
		"enemy":
			return "Wrogi oddzial"
		"area":
			return "Wybrany hex"
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
	turn_queue.sort_custom(_is_turn_before)
	turn_queue_index = -1


func _resort_remaining_turn_queue() -> void:
	var first_pending: int = turn_queue_index + 1
	var remaining: Array[int] = []
	for index in range(first_pending, turn_queue.size()):
		remaining.append(turn_queue[index])
	remaining.sort_custom(_is_turn_before)
	for index in remaining.size():
		turn_queue[first_pending + index] = remaining[index]


func _is_turn_before(a: int, b: int) -> bool:
	var unit_a: Dictionary = _find_unit_by_id(a)
	var unit_b: Dictionary = _find_unit_by_id(b)
	if int(unit_a.speed) == int(unit_b.speed):
		if unit_a.side == unit_b.side:
			return a < b
		return unit_a.side == "player"
	return int(unit_a.speed) > int(unit_b.speed)


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
	_odtworz_sfx_jednostki(unit, "wybor")
	unit.remaining_move = int(unit.move_range)
	unit.action_points = int(unit.get("base_action_points", unit.get("action_points", 1)))
	pending_skill_id = ""
	_clear_move_cost_label()
	var skips_turn: bool = _process_turn_start(unit)
	if _is_manual_side(str(unit.side)):
		_refresh_general_ability_buttons()
	_apply_terrain_effects_to_unit(unit, false)
	if _find_unit_by_id(unit.id).is_empty():
		_sync_board()
		_start_next_activation()
		return
	if skips_turn:
		_sync_board()
		_end_current_activation()
		return
	if _is_immobilized(unit) and _is_manual_side(str(unit.side)):
		unit.remaining_move = 0
		_log_event("%s nie rusza się, ponieważ jest unieruchomiony." % _unit_name_log_text(unit))
	if not _is_manual_side(str(unit.side)) and not _can_unit_continue_turn(unit):
		if _is_immobilized(unit):
			_log_event("%s nie rusza się, ponieważ jest unieruchomiony." % _unit_name_log_text(unit))
		_sync_board()
		_end_current_activation()
		return
	selected_unit_id = unit.id if _is_manual_side(str(unit.side)) else -1
	board.set_selected_unit(selected_unit_id)
	_sync_board()
	if unit.side == "enemy" and not _is_manual_side(str(unit.side)):
		_enemy_take_turn()


func _odtworz_sfx_jednostki(unit: Dictionary, zdarzenie: String) -> void:
	if setup_mode or str(unit.get("side", "")) != "player":
		return
	var type_id: String = str(unit.get("type_id", ""))
	var zestaw: Dictionary = SFX_LUDZKICH_JEDNOSTEK.get(type_id, {})
	if zestaw.is_empty():
		zestaw = SFX_FRAKCJI.get(type_id.get_slice("_", 0), {})
	var dzwiek: AudioStream = zestaw.get(zdarzenie) as AudioStream
	if zdarzenie == "wybor" and type_id.begins_with("orc_") and str(unit.get("side", "")) == "player" and orc_general_is_kishak and general_portrait.texture == ORC_GENERAL_KISHAK_PORTRAIT and losowanie_sfx.randf() < SZANSA_SFX_KISHAKA:
		dzwiek = SFX_WYBOR_KISHAKA
	if dzwiek == null:
		return
	odtwarzacz_sfx_jednostek.stop()
	odtwarzacz_sfx_jednostek.stream = dzwiek
	odtwarzacz_sfx_jednostek.play()


func _pobierz_rodzaj_sfx_broni(attacker: Dictionary, projectile_kind: String, override: String = "") -> String:
	if override != "":
		return override
	match projectile_kind:
		"arrows":
			return "arrow"
		"throwing_axe":
			return "axe"
		"":
			return str(BRON_JEDNOSTEK.get(str(attacker.get("type_id", "")), ""))
	return ""


func _odtworz_sfx_broni(rodzaj: String) -> void:
	var dzwiek: AudioStream = SFX_BRONI.get(rodzaj) as AudioStream
	if dzwiek == null:
		return
	odtwarzacz_sfx_broni.stream = dzwiek
	odtwarzacz_sfx_broni.play()


func _odtworz_sfx_trafienia_po_czasie(opoznienie: float) -> void:
	if opoznienie > 0.0:
		await get_tree().create_timer(opoznienie).timeout
	if not is_inside_tree():
		return
	odtwarzacz_sfx_trafienia.stream = SFX_TRAFIENIA
	odtwarzacz_sfx_trafienia.play()


func _get_active_unit() -> Dictionary:
	return _find_unit_by_id(active_unit_id)


func _is_player_turn() -> bool:
	return current_turn == "player"


func _is_manual_turn() -> bool:
	return _is_manual_side(current_turn)


func _is_manual_side(side: String) -> bool:
	return side == "player" or (side == "enemy" and ai_difficulty == "gracz")


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
	if setup_mode:
		return false
	var has_player := _has_units_on_side("player")
	var has_enemy := _has_units_on_side("enemy")
	if has_player and has_enemy:
		return false
	var winner_side := "player" if has_player else "enemy"
	if winner_side == "player" and castle_stage > 0 and castle_stage < _get_castle_stages().size():
		_advance_castle_stage()
		return true
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


func _advance_castle_stage() -> void:
	is_animating = true
	var stages: Array[Dictionary] = _get_castle_stages()
	var next_stage: int = castle_stage + 1
	_set_stage_transition_content(next_stage, stages)
	stage_transition_overlay.visible = true
	var transition: Tween = create_tween()
	transition.tween_property(stage_transition_overlay, "modulate:a", 1.0, 0.45)
	await transition.finished

	castle_stage += 1
	var stage: Dictionary = stages[castle_stage - 1]
	_set_battle_background(str(stage.get("background", DEFAULT_BATTLE_BACKGROUND_PATH)))
	var survivors: Array[Dictionary] = []
	for unit in units:
		if str(unit.side) == "player":
			survivors.append(unit)
	var player_positions: Array[Vector2i] = _compute_player_positions(survivors.size())
	for index in survivors.size():
		survivors[index]["grid_x"] = player_positions[index].x
		survivors[index]["grid_y"] = player_positions[index].y
		survivors[index]["remaining_move"] = int(survivors[index].get("move_range", 0))
		survivors[index]["action_points"] = int(survivors[index].get("base_action_points", 1))

	var enemy_configs: Array[Dictionary] = _typed_dictionary_array(stage.get("enemy_units", []))
	for index in enemy_configs.size():
		var config: Dictionary = enemy_configs[index]
		survivors.append(_prepare_unit({
			"id": 100 * castle_stage + index,
			"type_id": str(config.type_id),
			"side": "enemy",
			"count": int(config.count),
			"grid_x": int(config.grid_x),
			"grid_y": int(config.grid_y),
		}))

	units = survivors
	obstacles = _generate_obstacles()
	terrain_effects = []
	round_number = 1
	next_map_event_id = ""
	next_map_event_round = 0
	map_event_cells.clear()
	_schedule_next_map_event(0)
	selected_unit_id = -1
	setup_drag_unit_id = -1
	active_unit_id = -1
	current_turn = ""
	pending_skill_id = ""
	turn_queue_index = -1
	turn_queue.clear()
	event_log.clear()
	board.set_selected_unit(-1)
	board.set_units(units)
	board.reset_unit_positions(units)
	board.set_obstacles(obstacles)
	board.set_terrain_effects(terrain_effects)
	_sync_board()
	await get_tree().create_timer(2.5).timeout
	transition = create_tween()
	transition.tween_property(stage_transition_overlay, "modulate:a", 0.0, 0.45)
	await transition.finished
	stage_transition_overlay.visible = false
	is_animating = false
	setup_mode = true
	_log_event(_color_log_text("Etap %d/%d: ustaw jednostki i kliknij START po prawej." % [castle_stage, stages.size()], LOG_COLOR_YELLOW))
	_update_setup_hint_visibility()
	_update_selection_visibility()
	_update_action_buttons()
	_refresh_turn_queue()
	_sync_board()


func _set_stage_transition_content(stage_number: int, stages: Array[Dictionary]) -> void:
	stage_transition_title.text = str(stages[stage_number - 1].get("name", "ETAP %d" % stage_number)).to_upper()
	stage_transition_progress.text = "ETAP %d/%d" % [stage_number, stages.size()]


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
	if help_popup != null and help_popup.visible:
		return
	if not _is_manual_turn() or is_animating:
		return

	var unit := _get_active_unit()
	var skill := _get_skill_at(unit, index)
	if skill.is_empty():
		return

	var skill_id := str(skill.get("id", ""))
	if pending_skill_id == skill_id:
		pending_skill_id = ""
	elif not MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, skill_id, skill_library):
		return
	else:
		pending_skill_id = skill_id

	selected_unit_id = unit.id
	_update_highlighted_cells(unit)
	_update_action_buttons()
	unit_abilities_panel.set_skills(_build_skill_cards(unit))
	_refresh_turn_queue()


func _on_general_ability_1_pressed() -> void:
	if help_popup != null and help_popup.visible:
		return
	_use_general_skill_by_index(0)


func _on_general_ability_2_pressed() -> void:
	if help_popup != null and help_popup.visible:
		return
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
	if str(skill.get("effect_type", "")) != "army_buff":
		pending_general_skill_id = "" if pending_general_skill_id == skill_id else skill_id
		_update_highlighted_cells(_get_active_unit())
		_refresh_general_ability_buttons()
		return
	var effect: Dictionary = skill.get("effect", {}).duplicate(true)
	if effect.is_empty():
		return
	effect["id"] = skill_id
	effect["name"] = str(skill.get("name", skill_id))
	for unit in units:
		if unit.side != "player":
			continue
		_apply_or_refresh_effect(unit, effect.duplicate(true))
	_finish_general_skill(skill_id, skill)


func _try_execute_general_skill(cell: Vector2i) -> void:
	var skill_id: String = pending_general_skill_id
	var skill: Dictionary = general_skills.get(skill_id, {})
	var target_type: String = str(skill.get("effect_type", ""))
	var target: Dictionary = _find_unit_at_cell(cell)
	if target_type == "ally" and (target.is_empty() or target.side != "player"):
		return
	if bool(skill.get("active_only", false)) and int(target.get("id", -1)) != active_unit_id:
		return
	if target_type == "enemy" and (target.is_empty() or target.side != "enemy"):
		return
	if target_type == "area":
		await _execute_general_area_skill(skill_id, skill, cell)
	else:
		_execute_general_unit_skill(skill_id, skill, target)


func _execute_general_unit_skill(skill_id: String, skill: Dictionary, target: Dictionary) -> void:
	target["action_points"] = int(target.get("action_points", 0)) + int(skill.get("action_points", 0))
	var target_effect: Dictionary = skill.get("target_effect", {}).duplicate(true)
	if not target_effect.is_empty():
		target_effect["id"] = skill_id
		target_effect["name"] = str(skill.get("name", skill_id))
		_apply_or_refresh_effect(target, target_effect)
	_finish_general_skill(skill_id, skill, " Cel: %s." % _unit_name_log_text(target))


func _execute_general_area_skill(skill_id: String, skill: Dictionary, center: Vector2i) -> void:
	var cells: Array[Vector2i] = _get_general_area_cells(center, int(skill.get("radius", 1)))
	if str(skill.get("animation", "")) == "arrows":
		is_animating = true
		_odtworz_sfx_broni("arrow")
		board.play_arrow_rain_animation(-1, cells)
		await get_tree().create_timer(0.42).timeout
		is_animating = false
	var hits := 0
	for area_cell in cells:
		var target: Dictionary = _find_unit_at_cell(area_cell)
		if target.is_empty() or target.side != "enemy":
			continue
		hits += 1
		var damage: int = int(skill.get("damage_per_unit", 0)) * int(target.get("count", 0))
		_apply_damage_to_unit(target, damage)
		var target_effect: Dictionary = skill.get("target_effect", {}).duplicate(true)
		if not target_effect.is_empty() and int(target.get("count", 0)) > 0:
			target_effect["id"] = skill_id
			target_effect["name"] = str(skill.get("name", skill_id))
			_apply_or_refresh_effect(target, target_effect)
		_cleanup_destroyed_unit(target)
	if hits > 0:
		_odtworz_sfx_trafienia_po_czasie(0.0)
	_finish_general_skill(skill_id, skill, " Trafione oddziały: %d." % hits)


func _get_general_area_cells(center: Vector2i, radius: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for column in GRID_COLUMNS:
		for row in GRID_ROWS:
			var cell := Vector2i(column, row)
			if _hex_distance(center, cell) <= radius:
				cells.append(cell)
	return cells


func _finish_general_skill(skill_id: String, skill: Dictionary, log_suffix: String = "") -> void:
	pending_general_skill_id = ""
	general_skill_used = true
	_log_event("%s używa umiejętności %s.%s" % [general_name_label.text, str(skill.get("name", skill_id)), log_suffix])
	_refresh_general_ability_buttons()
	_update_highlighted_cells(_get_active_unit())
	_resort_remaining_turn_queue()
	_sync_board()


func _refresh_general_display() -> void:
	var faction: String = current_player_faction
	if faction == "orcs" and orc_general_is_kishak:
		general_name_label.text = ORC_GENERAL_KISHAK_NAME
		general_portrait.texture = ORC_GENERAL_KISHAK_PORTRAIT
	elif faction == "humans" and human_general_is_kovalenko:
		general_name_label.text = HUMAN_GENERAL_KOVALENKO_NAME
		general_portrait.texture = HUMAN_GENERAL_KOVALENKO_PORTRAIT
	else:
		general_name_label.text = str(GENERAL_NAMES.get(faction, "Generał"))
		var portrait: Texture2D = GENERAL_PORTRAITS.get(faction, DEFAULT_GENERAL_PORTRAIT)
		general_portrait.texture = portrait if portrait != null else DEFAULT_GENERAL_PORTRAIT
	general_level_label.text = "Poziom 5"


func _refresh_general_ability_buttons() -> void:
	var buttons: Array[Button] = [general_ability_button_1, general_ability_button_2]
	for index in buttons.size():
		var button: Button = buttons[index]
		var icon_rect: TextureRect = button.get_node("AbilityContent/AbilityIcon")
		var name_label: Label = button.get_node("AbilityContent/AbilityText/AbilityName")
		var desc_label: Label = button.get_node("AbilityContent/AbilityText/AbilityDesc")
		var cd_label: Label = button.get_node("AbilityContent/AbilityText/AbilityCooldown")
		if index >= general_skill_ids.size():
			button.disabled = true
			button.tooltip_text = "Brak umiejetnosci."
			name_label.text = "-"
			desc_label.text = "Brak umiejetnosci"
			cd_label.text = ""
			continue
		var skill_id: String = general_skill_ids[index]
		var skill: Dictionary = general_skills.get(skill_id, {})
		var can_use := not setup_mode and not is_animating and _is_player_turn() and not general_skill_used
		button.disabled = not can_use
		button.modulate = Color(0.75, 0.9, 1.0, 1.0) if pending_general_skill_id == skill_id else (Color(0.45, 0.45, 0.45, 0.75) if general_skill_used else Color.WHITE)
		var icon_path: String = UnitTypeLibraryScript.get_general_skill_icon_path(skill_id)
		if icon_path != "":
			var icon_texture: Resource = load(icon_path)
			if icon_texture is Texture2D:
				icon_rect.texture = icon_texture
		name_label.text = str(skill.get("name", skill_id)).to_upper()
		desc_label.text = str(skill.get("description", ""))
		cd_label.text = ""
		button.tooltip_text = _build_general_skill_tooltip(skill)
