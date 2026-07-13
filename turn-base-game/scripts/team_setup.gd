extends Control

signal setup_finished(player_faction: String, enemy_faction: String)
signal setup_loaded(save_data: Dictionary)
signal custom_setup_finished(unit_configs: Array[Dictionary], player_faction: String, enemy_faction: String, background_path: String)

const UnitSelectPanelScene: PackedScene = preload("res://scenes/unit_select_panel.tscn")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const UnitSelectPanelClass = preload("res://scripts/unit_select_panel.gd")
const BATTLE_BACKGROUND: Texture2D = preload("res://assets/backgrounds/back.png")
const SCENARIOS: Array[Dictionary] = [
	{
		"id": "orcs_vs_elves_forest",
		"name": "Najazd na Swiety Gaj",
		"description": "Orkowie atakuja elfy na granicy ich lasu.",
		"player_faction": "orcs",
		"enemy_faction": "elves",
		"background": "res://assets/backgrounds/scenarios/orcs_vs_elves_forest.png",
		"player_units": [
			{"type_id": "orc_warrior", "count": 6},
			{"type_id": "orc_berserker", "count": 4},
			{"type_id": "orc_shaman", "count": 5},
			{"type_id": "orc_shieldman", "count": 4},
		],
		"enemy_units": [
			{"type_id": "elf_archer", "count": 7},
			{"type_id": "elf_swordsman", "count": 5},
			{"type_id": "elf_mage", "count": 4},
			{"type_id": "elf_arcanotechnic", "count": 5},
		],
	},
	{
		"id": "dwarves_vs_goblins_mine",
		"name": "Brama Kopalni",
		"description": "Krasnoludy odbijaja wejscie do kopalni z rak goblinow.",
		"player_faction": "dwarves",
		"enemy_faction": "goblins",
		"background": "res://assets/backgrounds/scenarios/dwarves_vs_goblins_mine.png",
		"player_units": [
			{"type_id": "dwarf_warrior", "count": 5},
			{"type_id": "dwarf_guardian", "count": 4},
			{"type_id": "dwarf_axeman", "count": 4},
			{"type_id": "dwarf_digger", "count": 5},
		],
		"enemy_units": [
			{"type_id": "goblin_thief", "count": 12},
			{"type_id": "goblin_warrior", "count": 12},
			{"type_id": "goblin_shaman", "count": 9},
			{"type_id": "goblin_trapper", "count": 10},
		],
	},
	{
		"id": "humans_vs_orcs_village",
		"name": "Spalony Brod",
		"description": "Ludzie bronia zniszczonej wioski przed orkami.",
		"player_faction": "humans",
		"enemy_faction": "orcs",
		"background": "res://assets/backgrounds/scenarios/humans_vs_orcs_village.png",
		"player_units": [
			{"type_id": "human_knights", "count": 6},
			{"type_id": "human_cavalry", "count": 3},
			{"type_id": "human_archers", "count": 8},
			{"type_id": "human_mages", "count": 5},
		],
		"enemy_units": [
			{"type_id": "orc_warrior", "count": 6},
			{"type_id": "orc_berserker", "count": 4},
			{"type_id": "orc_shaman", "count": 6},
			{"type_id": "orc_shieldman", "count": 4},
		],
	},
	{
		"id": "elves_vs_dwarves_pass",
		"name": "Mrozna Przelecz",
		"description": "Elfy i krasnoludy walcza o stary gorski posterunek.",
		"player_faction": "elves",
		"enemy_faction": "dwarves",
		"background": "res://assets/backgrounds/scenarios/elves_vs_dwarves_pass.png",
		"player_units": [
			{"type_id": "elf_archer", "count": 7},
			{"type_id": "elf_swordsman", "count": 5},
			{"type_id": "elf_mage", "count": 5},
			{"type_id": "elf_arcanotechnic", "count": 5},
		],
		"enemy_units": [
			{"type_id": "dwarf_warrior", "count": 5},
			{"type_id": "dwarf_guardian", "count": 4},
			{"type_id": "dwarf_axeman", "count": 4},
			{"type_id": "dwarf_digger", "count": 5},
		],
	},
	{
		"id": "humans_vs_goblins_desert",
		"name": "Zasadzka na Szlaku",
		"description": "Ludzka karawana przebija sie przez goblinska zasadzke na pustyni.",
		"player_faction": "humans",
		"enemy_faction": "goblins",
		"background": "res://assets/backgrounds/scenarios/humans_vs_goblins_desert.png",
		"player_units": [
			{"type_id": "human_knights", "count": 5},
			{"type_id": "human_cavalry", "count": 4},
			{"type_id": "human_archers", "count": 7},
			{"type_id": "human_mages", "count": 4},
		],
		"enemy_units": [
			{"type_id": "goblin_thief", "count": 12},
			{"type_id": "goblin_warrior", "count": 10},
			{"type_id": "goblin_shaman", "count": 8},
			{"type_id": "goblin_trapper", "count": 10},
		],
	},
]

var _player_panel: UnitSelectPanelClass
var _enemy_panel: UnitSelectPanelClass
var _start_button: Button
var _load_button: Button
var _load_dialog: FileDialog
var _rows: Array[Dictionary] = []
var _sandbox_player_faction: String = ""
var _sandbox_enemy_faction: String = ""
var _debug_background_path: String = str(SCENARIOS[0].get("background", ""))


func _ready() -> void:
	_show_mode_menu()


func _show_mode_menu() -> void:
	_clear()
	_build_background()

	var main := _make_main_container(80, 80)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 28)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(column)

	var title := Label.new()
	title.text = "WYBIERZ TRYB GRY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)

	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 24)
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(cards)

	cards.add_child(_make_mode_card("GOTOWE SCENARIUSZE", "Wybor przygotowanej bitwy.", _show_scenarios_placeholder))
	cards.add_child(_make_mode_card("SANDBOX", "Armie i liczebnosc oddzialow.", _show_sandbox_faction_select))
	cards.add_child(_make_mode_card("DEBUG", "Dowolne jednostki testowe.", _show_debug_count_config))


func _show_scenarios_placeholder() -> void:
	_clear()
	_build_background()

	var main := _make_main_container(52, 52)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(column)

	var title := Label.new()
	title.text = "GOTOWE SCENARIUSZE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)

	var scenarios_row := HBoxContainer.new()
	scenarios_row.add_theme_constant_override("separation", 18)
	scenarios_row.alignment = BoxContainer.ALIGNMENT_CENTER
	scenarios_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(scenarios_row)

	for scenario in SCENARIOS:
		scenarios_row.add_child(_make_scenario_card(scenario))

	var back_button := _make_action_button("WROC", Vector2(180, 52))
	back_button.pressed.connect(_show_mode_menu)
	column.add_child(back_button)


func _make_scenario_card(scenario: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(290, 250)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_start_scenario.bind(scenario))

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14
	box.offset_top = 14
	box.offset_right = -14
	box.offset_bottom = -14
	button.add_child(box)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(250, 116)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var preview_texture: Resource = load(str(scenario.get("background", "")))
	if preview_texture is Texture2D:
		preview.texture = preview_texture
	box.add_child(preview)

	var name_label := Label.new()
	name_label.text = str(scenario.get("name", "")).to_upper()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	box.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = str(scenario.get("description", ""))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.78, 0.75, 0.66, 1.0))
	box.add_child(desc_label)
	return button


func _start_scenario(scenario: Dictionary) -> void:
	var unit_configs: Array[Dictionary] = []
	var next_id := 1
	next_id = _append_scenario_units(unit_configs, scenario.get("player_units", []), "player", next_id)
	_append_scenario_units(unit_configs, scenario.get("enemy_units", []), "enemy", next_id)
	custom_setup_finished.emit(
		unit_configs,
		str(scenario.get("player_faction", "")),
		str(scenario.get("enemy_faction", "")),
		str(scenario.get("background", ""))
	)


func _append_scenario_units(unit_configs: Array[Dictionary], raw_units: Variant, side: String, next_id: int) -> int:
	if typeof(raw_units) != TYPE_ARRAY:
		return next_id
	for raw_unit in raw_units:
		if typeof(raw_unit) != TYPE_DICTIONARY:
			continue
		var unit_data: Dictionary = raw_unit
		unit_configs.append({
			"id": next_id,
			"type_id": str(unit_data.get("type_id", "")),
			"side": side,
			"count": int(unit_data.get("count", 1)),
		})
		next_id += 1
	return next_id


func _show_sandbox_faction_select() -> void:
	_clear()
	_build_background()

	var main := _make_main_container(40, 40)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	main.add_child(column)

	var title := Label.new()
	title.text = "SANDBOX"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Wybierz armie do bitwy"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.75, 0.72, 0.62, 1.0))
	column.add_child(subtitle)

	var panels_row := HBoxContainer.new()
	panels_row.add_theme_constant_override("separation", 80)
	panels_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panels_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panels_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(panels_row)

	var left_spacer := Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panels_row.add_child(left_spacer)

	var faction_ids: Array[String] = _get_normal_faction_ids()
	var default_faction: String = UnitTypeLibraryScript.get_default_faction()
	if default_faction == "testowa" or not faction_ids.has(default_faction):
		default_faction = faction_ids[0] if not faction_ids.is_empty() else ""

	_player_panel = UnitSelectPanelScene.instantiate()
	_player_panel.name = "PlayerPanel"
	_player_panel.custom_minimum_size = Vector2(260, 0)
	_player_panel.randomize_requested.connect(_on_randomize_requested)
	panels_row.add_child(_player_panel)

	var center_spacer := Control.new()
	center_spacer.custom_minimum_size = Vector2(60, 0)
	panels_row.add_child(center_spacer)

	_enemy_panel = UnitSelectPanelScene.instantiate()
	_enemy_panel.name = "EnemyPanel"
	_enemy_panel.custom_minimum_size = Vector2(260, 0)
	_enemy_panel.randomize_requested.connect(_on_randomize_requested)
	panels_row.add_child(_enemy_panel)

	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panels_row.add_child(right_spacer)

	_player_panel.setup("player", faction_ids, default_faction)
	_enemy_panel.setup("enemy", faction_ids, _random_faction())

	var actions_row := HBoxContainer.new()
	actions_row.add_theme_constant_override("separation", 16)
	actions_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(actions_row)

	var back_button := _make_action_button("WROC", Vector2(160, 60))
	back_button.pressed.connect(_show_mode_menu)
	actions_row.add_child(back_button)

	_load_button = _make_action_button("WCZYTAJ ZAPIS", Vector2(220, 60))
	_load_button.pressed.connect(_on_load_pressed)
	actions_row.add_child(_load_button)

	_start_button = _make_action_button("DALEJ", Vector2(220, 60))
	_start_button.add_theme_font_size_override("font_size", 28)
	_start_button.pressed.connect(_show_sandbox_count_config)
	actions_row.add_child(_start_button)

	_load_dialog = FileDialog.new()
	_load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_load_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_load_dialog.filters = PackedStringArray(["*.json ; Zapis armii"])
	_load_dialog.file_selected.connect(_on_load_file_selected)
	add_child(_load_dialog)


func _show_sandbox_count_config() -> void:
	_sandbox_player_faction = _player_panel.get_selected_faction()
	_sandbox_enemy_faction = _enemy_panel.get_selected_faction()
	var units: Array[Dictionary] = []
	for unit in UnitTypeLibraryScript.get_faction_units(_sandbox_player_faction):
		var copy: Dictionary = unit.duplicate(true)
		copy["side"] = "player"
		units.append(copy)
	for unit in UnitTypeLibraryScript.get_faction_units(_sandbox_enemy_faction):
		var copy: Dictionary = unit.duplicate(true)
		copy["side"] = "enemy"
		units.append(copy)
	_show_count_config("SANDBOX - LICZEBNOSC", units, _show_sandbox_faction_select, _on_start_sandbox_pressed)


func _show_debug_count_config() -> void:
	_show_count_config("DEBUG", _get_all_unit_types_for_debug(), _show_mode_menu, _on_start_debug_pressed, true)


func _show_count_config(title_text: String, unit_types: Array[Dictionary], back_callback: Callable, start_callback: Callable, show_map_select: bool = false) -> void:
	_clear()
	_rows.clear()
	_build_background()

	var main := _make_main_container(40, 34)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	main.add_child(column)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)
	if show_map_select:
		var map_select := OptionButton.new()
		map_select.custom_minimum_size = Vector2(320, 42)
		for scenario in SCENARIOS:
			map_select.add_item(str(scenario.get("name", "")))
			map_select.set_item_metadata(map_select.item_count - 1, str(scenario.get("background", "")))
			if str(scenario.get("background", "")) == _debug_background_path:
				map_select.select(map_select.item_count - 1)
		map_select.item_selected.connect(func(index: int) -> void: _debug_background_path = str(map_select.get_item_metadata(index)))
		column.add_child(map_select)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)

	var sides := HBoxContainer.new()
	sides.add_theme_constant_override("separation", 28)
	sides.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(sides)

	var player_column := _make_side_column("GRACZ")
	var enemy_column := _make_side_column("PRZECIWNIK")
	sides.add_child(player_column)
	sides.add_child(enemy_column)

	for unit in unit_types:
		var side := str(unit.get("side", ""))
		var parent: VBoxContainer = player_column if side == "player" else enemy_column
		var spin: SpinBox = _add_unit_count_row(parent, unit, int(unit.get("count", 1)))
		_rows.append({"unit": unit, "side": side, "count_spin": spin})

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 16)
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(actions)

	var back_button := _make_action_button("WROC", Vector2(180, 52))
	back_button.pressed.connect(back_callback)
	actions.add_child(back_button)

	var start_button := _make_action_button("START", Vector2(220, 52))
	start_button.pressed.connect(start_callback)
	actions.add_child(start_button)


func _on_start_sandbox_pressed() -> void:
	_emit_custom_setup(_sandbox_player_faction, _sandbox_enemy_faction)


func _on_start_debug_pressed() -> void:
	_emit_custom_setup("testowa", "testowa", _debug_background_path)


func _emit_custom_setup(player_faction: String, enemy_faction: String, background_path: String = "") -> void:
	var unit_configs: Array[Dictionary] = []
	var next_id := 1
	var player_count := 0
	var enemy_count := 0
	for row in _rows:
		var count_spin: SpinBox = row["count_spin"]
		var count: int = int(count_spin.value)
		if count <= 0:
			continue
		var side := str(row["side"])
		if side == "player":
			player_count += 1
		else:
			enemy_count += 1
		var unit: Dictionary = row["unit"]
		unit_configs.append({
			"id": next_id,
			"type_id": str(unit.get("id", "")),
			"side": side,
			"count": count,
		})
		next_id += 1
	if player_count == 0 or enemy_count == 0:
		return
	custom_setup_finished.emit(unit_configs, player_faction, enemy_faction, background_path)


func _build_background() -> void:
	var background := TextureRect.new()
	background.name = "Background"
	background.texture = BATTLE_BACKGROUND
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(background)

	var overlay := ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.02, 0.04, 0.78)
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	add_child(overlay)


func _make_main_container(margin_x: int, margin_y: int) -> MarginContainer:
	var main := MarginContainer.new()
	main.name = "Main"
	main.anchor_right = 1.0
	main.anchor_bottom = 1.0
	main.add_theme_constant_override("margin_left", margin_x)
	main.add_theme_constant_override("margin_top", margin_y)
	main.add_theme_constant_override("margin_right", margin_x)
	main.add_theme_constant_override("margin_bottom", margin_y)
	add_child(main)
	return main


func _make_mode_card(title: String, subtitle: String, callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(300, 220)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(callback)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 18
	box.offset_top = 18
	box.offset_right = -18
	box.offset_bottom = -18
	button.add_child(box)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	box.add_child(title_label)

	var subtitle_label := Label.new()
	subtitle_label.text = subtitle
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 15)
	subtitle_label.add_theme_color_override("font_color", Color(0.78, 0.75, 0.66, 1.0))
	box.add_child(subtitle_label)
	return button


func _make_action_button(text: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 22)
	return button


func _make_side_column(title_text: String) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)
	return column


func _add_unit_count_row(parent: VBoxContainer, unit: Dictionary, count: int) -> SpinBox:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var name_label := Label.new()
	name_label.text = str(unit.get("name", unit.get("id", "")))
	name_label.custom_minimum_size = Vector2(260, 0)
	name_label.add_theme_font_size_override("font_size", 16)
	row.add_child(name_label)

	var count_spin := SpinBox.new()
	count_spin.min_value = 0
	count_spin.max_value = 999
	count_spin.step = 1
	count_spin.value = count
	count_spin.custom_minimum_size = Vector2(110, 36)
	row.add_child(count_spin)
	return count_spin


func _get_all_unit_types_for_debug() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	var unit_index: int = 0
	for faction in UnitTypeLibraryScript.get_factions():
		for unit in faction.get("units", []):
			var type_id := str(unit.get("id", ""))
			if type_id == "" or seen.has(type_id):
				continue
			seen[type_id] = true
			var player_unit: Dictionary = unit.duplicate(true)
			player_unit["side"] = "player"
			player_unit["count"] = int(unit.get("count", 1)) if unit_index == 0 else 0
			result.append(player_unit)
			var enemy_unit: Dictionary = unit.duplicate(true)
			enemy_unit["side"] = "enemy"
			enemy_unit["count"] = int(unit.get("count", 1)) if unit_index == 1 else 0
			result.append(enemy_unit)
			unit_index += 1
	return result


func _random_faction() -> String:
	var faction_ids: Array[String] = _get_normal_faction_ids()
	if faction_ids.is_empty():
		return ""
	return faction_ids[randi() % faction_ids.size()]


func _get_normal_faction_ids() -> Array[String]:
	var result: Array[String] = []
	for faction_id in UnitTypeLibraryScript.get_faction_ids():
		if faction_id != "testowa":
			result.append(faction_id)
	return result


func _on_randomize_requested(side: String) -> void:
	if side == "player":
		_player_panel.randomize_faction()
	else:
		_enemy_panel.randomize_faction()


func _on_start_pressed() -> void:
	setup_finished.emit(_player_panel.get_selected_faction(), _enemy_panel.get_selected_faction())


func _on_load_pressed() -> void:
	_load_dialog.popup_centered(Vector2i(900, 600))


func _on_load_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	setup_loaded.emit(data)


func _clear() -> void:
	for child in get_children():
		child.queue_free()
