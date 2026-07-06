extends Control

signal setup_finished(player_type_id: String, enemy_type_id: String)

const UnitSelectPanelScene: PackedScene = preload("res://scenes/unit_select_panel.tscn")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const UnitSelectPanelClass = preload("res://scripts/unit_select_panel.gd")

var _player_panel: UnitSelectPanelClass
var _enemy_panel: UnitSelectPanelClass
var _start_button: Button


func _ready() -> void:
	_randomize()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.08, 0.08, 0.1, 1.0)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)

	var main := MarginContainer.new()
	main.name = "Main"
	main.anchor_right = 1.0
	main.anchor_bottom = 1.0
	main.add_theme_constant_override("margin_left", 40)
	main.add_theme_constant_override("margin_top", 40)
	main.add_theme_constant_override("margin_right", 40)
	main.add_theme_constant_override("margin_bottom", 40)
	add_child(main)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 24)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	main.add_child(column)

	var title := Label.new()
	title.text = "WYBÓR ARMII"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)

	var panels_row := HBoxContainer.new()
	panels_row.add_theme_constant_override("separation", 60)
	panels_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panels_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panels_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(panels_row)

	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	var default_faction: String = UnitTypeLibraryScript.get_default_faction()

	_player_panel = UnitSelectPanelScene.instantiate()
	_player_panel.name = "PlayerPanel"
	_player_panel.randomize_requested.connect(_on_randomize_requested)
	panels_row.add_child(_player_panel)

	_enemy_panel = UnitSelectPanelScene.instantiate()
	_enemy_panel.name = "EnemyPanel"
	_enemy_panel.randomize_requested.connect(_on_randomize_requested)
	panels_row.add_child(_enemy_panel)

	_player_panel.setup("player", faction_ids, default_faction, _random_type_for_faction(default_faction))
	_enemy_panel.setup("enemy", faction_ids, _random_faction(), _random_type_for_faction(default_faction))

	_start_button = Button.new()
	_start_button.text = "START"
	_start_button.custom_minimum_size = Vector2(220, 60)
	_start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_start_button.add_theme_font_size_override("font_size", 28)
	_start_button.pressed.connect(_on_start_pressed)
	column.add_child(_start_button)


func _random_faction() -> String:
	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	if faction_ids.is_empty():
		return ""
	return faction_ids[randi() % faction_ids.size()]


func _random_type_for_faction(faction: String) -> String:
	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(faction)
	if units.is_empty():
		return ""
	return str(units[randi() % units.size()].get("id", ""))


func _randomize() -> void:
	_build_ui()


func _on_randomize_requested(side: String) -> void:
	if side == "player":
		_player_panel.randomize_type()
	else:
		_enemy_panel.randomize_type()


func _on_start_pressed() -> void:
	setup_finished.emit(_player_panel.get_selected_type_id(), _enemy_panel.get_selected_type_id())
