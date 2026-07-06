extends Control

signal setup_finished(player_faction: String, enemy_faction: String)

const UnitSelectPanelScene: PackedScene = preload("res://scenes/unit_select_panel.tscn")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const UnitSelectPanelClass = preload("res://scripts/unit_select_panel.gd")
const BATTLE_BACKGROUND: Texture2D = preload("res://assets/backgrounds/back.png")

var _player_panel: UnitSelectPanelClass
var _enemy_panel: UnitSelectPanelClass
var _start_button: Button


func _ready() -> void:
	_randomize()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

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
	title.text = "GRACZ  vs  KOMPUTER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Wybierz armie gracza i przeciwnika"
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

	_player_panel.setup("player", faction_ids, default_faction)
	_enemy_panel.setup("enemy", faction_ids, _random_fiction())

	_start_button = Button.new()
	_start_button.text = "START"
	_start_button.custom_minimum_size = Vector2(220, 60)
	_start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_start_button.add_theme_font_size_override("font_size", 28)
	_start_button.pressed.connect(_on_start_pressed)
	column.add_child(_start_button)


func _random_fiction() -> String:
	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	if faction_ids.is_empty():
		return ""
	return faction_ids[randi() % faction_ids.size()]


func _randomize() -> void:
	_build_ui()


func _on_randomize_requested(side: String) -> void:
	if side == "player":
		_player_panel.randomize_faction()
	else:
		_enemy_panel.randomize_faction()


func _on_start_pressed() -> void:
	setup_finished.emit(_player_panel.get_selected_faction(), _enemy_panel.get_selected_faction())
