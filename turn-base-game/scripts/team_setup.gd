extends Control

signal setup_finished(player_types: Array[String], enemy_types: Array[String])

const UnitSelectPanelScene: PackedScene = preload("res://scenes/unit_select_panel.tscn")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const UnitSelectPanelClass = preload("res://scripts/unit_select_panel.gd")

var _player_panel: UnitSelectPanelClass
var _enemy_panel: UnitSelectPanelClass
var _start_button: Button
var _back_button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchors_preset = Control.PRESET_FULL_RECT
	_set_background()
	_build_ui()
	_randomize_side("player")
	_randomize_side("enemy")


func _set_background() -> void:
	var bg := TextureRect.new()
	bg.name = "Background"
	bg.layout_mode = 1
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.grow_horizontal = 2
	bg.grow_vertical = 2
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = load("res://assets/backgrounds/back.png")
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)


func _build_ui() -> void:
	var main := MarginContainer.new()
	main.name = "Main"
	main.layout_mode = 1
	main.anchors_preset = Control.PRESET_FULL_RECT
	main.anchor_right = 1.0
	main.anchor_bottom = 1.0
	main.grow_horizontal = 2
	main.grow_vertical = 2
	main.add_theme_constant_override("margin_left", 60)
	main.add_theme_constant_override("margin_top", 60)
	main.add_theme_constant_override("margin_right", 60)
	main.add_theme_constant_override("margin_bottom", 60)
	add_child(main)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 24)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(column)

	var title := Label.new()
	title.text = "WYBIERZ SWOJA DRUZYNE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)

	var panels_row := HBoxContainer.new()
	panels_row.add_theme_constant_override("separation", 40)
	panels_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panels_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(panels_row)

	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	var default_faction: String = UnitTypeLibraryScript.get_default_faction()

	_player_panel = UnitSelectPanelScene.instantiate()
	_player_panel.name = "PlayerPanel"
	_player_panel.setup("player", faction_ids, default_faction, _empty_slots())
	_player_panel.selection_changed.connect(_on_selection_changed)
	_player_panel.randomize_requested.connect(_on_randomize_requested)
	panels_row.add_child(_player_panel)

	_enemy_panel = UnitSelectPanelScene.instantiate()
	_enemy_panel.name = "EnemyPanel"
	_enemy_panel.setup("enemy", faction_ids, default_faction, _empty_slots())
	_enemy_panel.selection_changed.connect(_on_selection_changed)
	_enemy_panel.randomize_requested.connect(_on_randomize_requested)
	panels_row.add_child(_enemy_panel)

	var buttons_row := HBoxContainer.new()
	buttons_row.add_theme_constant_override("separation", 16)
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons_row)

	_back_button = Button.new()
	_back_button.text = "WSTECZ"
	_back_button.custom_minimum_size = Vector2(160, 50)
	_back_button.pressed.connect(_on_back_pressed)
	buttons_row.add_child(_back_button)

	_start_button = Button.new()
	_start_button.text = "ROZPOCZNIJ BITWE"
	_start_button.custom_minimum_size = Vector2(240, 50)
	_start_button.pressed.connect(_on_start_pressed)
	buttons_row.add_child(_start_button)


func _empty_slots() -> Array[Dictionary]:
	return [
		{"type_id": ""},
		{"type_id": ""},
		{"type_id": ""},
		{"type_id": ""},
	]


func _on_selection_changed(_side: String, _slot: int, _type_id: String) -> void:
	pass


func _on_randomize_requested(side: String) -> void:
	_randomize_side(side)


func _randomize_side(side: String) -> void:
	var panel: UnitSelectPanelClass = _player_panel if side == "player" else _enemy_panel
	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	if faction_ids.is_empty():
		return
	var faction: String = faction_ids[randi() % faction_ids.size()]
	panel.setup(side, faction_ids, faction, _empty_slots())
	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(faction)
	if units.is_empty():
		return
	for index in 4:
		var type_id: String = str(units[randi() % units.size()].get("id", ""))
		panel.set_slot(index, type_id)


func _on_back_pressed() -> void:
	get_tree().reload_current_scene()


func _on_start_pressed() -> void:
	var player_types := _collect_types(_player_panel)
	var enemy_types := _collect_types(_enemy_panel)
	if player_types.is_empty() or enemy_types.is_empty():
		push_warning("Wybrane druzyny nie moga byc puste.")
		return
	setup_finished.emit(player_types, enemy_types)


func _collect_types(panel: UnitSelectPanelClass) -> Array[String]:
	var result: Array[String] = []
	for slot in panel.get_slots():
		var type_id: String = str(slot.get("type_id", ""))
		if type_id != "":
			result.append(type_id)
	return result
