class_name UnitSelectPanel
extends VBoxContainer

signal selection_changed(side: String, faction: String)
signal randomize_requested(side: String)

const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")

const SQUARE_SIZE := 120
const INNER_PADDING := 18
const TEXT_GAP := 12
const ROW_H_SEPARATION := 20
const ROW_V_SEPARATION := 18
const BUTTON_SIZE := SQUARE_SIZE + INNER_PADDING * 2

var _side: String = "player"
var _faction_options: Array[String] = []
var _current_faction: String = ""
var _faction_portraits: Dictionary = {}
var _faction_buttons: Array[Button] = []
var _rows_container: VBoxContainer
var _title_label: Label
var _subtitle_label: Label
var _random_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()


func setup(side: String, faction_options: Array[String], initial_faction: String) -> void:
	_side = side
	_faction_options = faction_options
	_ensure_portraits_for_factions()
	_set_faction(initial_faction)
	if _title_label != null:
		_title_label.text = "ARMIA GRACZA" if _side == "player" else "ARMIA KOMPUTER"
	if _subtitle_label != null:
		_subtitle_label.text = "(wybierasz ty)" if _side == "player" else "(przeciwnik sterowany przez komputer)"


func get_side() -> String:
	return _side


func get_selected_faction() -> String:
	return _current_faction


func set_faction(faction: String) -> void:
	_set_faction(faction)


func randomize_faction() -> void:
	if _faction_options.is_empty():
		return
	var faction: String = _faction_options[randi() % _faction_options.size()]
	_set_faction(faction)


func _build_ui() -> void:
	_title_label = Label.new()
	_title_label.text = "ARMIA GRACZA" if _side == "player" else "ARMIA KOMPUTER"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 28)
	_title_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = "(wybierasz ty)" if _side == "player" else "(przeciwnik sterowany przez komputer)"
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_size_override("font_size", 14)
	_subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.72, 0.62, 1.0))
	add_child(_subtitle_label)

	_rows_container = VBoxContainer.new()
	_rows_container.name = "RowsContainer"
	_rows_container.add_theme_constant_override("separation", ROW_V_SEPARATION)
	_rows_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_rows_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_rows_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(_rows_container)

	_random_button = Button.new()
	_random_button.text = "LOSOWO"
	_random_button.custom_minimum_size = Vector2(140, 44)
	_random_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_random_button.add_theme_font_size_override("font_size", 18)
	_random_button.pressed.connect(_on_randomize_pressed)
	add_child(_random_button)


func _ensure_portraits_for_factions() -> void:
	for faction in _faction_options:
		if not _faction_portraits.has(faction):
			_faction_portraits[faction] = _pick_random_portrait(faction)


func _pick_random_portrait(faction: String) -> Texture2D:
	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(faction)
	if units.is_empty():
		return null
	var random_unit: Dictionary = units[randi() % units.size()]
	var tex: Texture2D = _load_texture(str(random_unit.get("portrait", "")))
	return tex


func _rebuild_rows() -> void:
	for child in _rows_container.get_children():
		child.queue_free()
	_faction_buttons.clear()

	var row1 := HBoxContainer.new()
	row1.name = "Row1"
	row1.add_theme_constant_override("separation", ROW_H_SEPARATION)
	row1.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	_rows_container.add_child(row1)

	var row2 := HBoxContainer.new()
	row2.name = "Row2"
	row2.add_theme_constant_override("separation", ROW_H_SEPARATION)
	row2.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	_rows_container.add_child(row2)

	for index in _faction_options.size():
		var faction: String = _faction_options[index]
		var button := _make_faction_button(faction)
		_faction_buttons.append(button)
		if index < 2:
			row1.add_child(button)
		elif index < 4:
			row2.add_child(button)
		else:
			var row3 := HBoxContainer.new()
			row3.name = "Row3"
			row3.add_theme_constant_override("separation", ROW_H_SEPARATION)
			row3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row3.alignment = BoxContainer.ALIGNMENT_CENTER
			_rows_container.add_child(row3)
			row3.add_child(button)

	_update_selection_visuals()


func _make_faction_button(faction: String) -> Button:
	var button := Button.new()
	button.name = "FactionButton_%s" % faction
	button.custom_minimum_size = Vector2(BUTTON_SIZE, BUTTON_SIZE)
	button.toggle_mode = true
	button.pressed.connect(_on_faction_button_pressed.bind(faction))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color(0.12, 0.12, 0.16, 1.0)
	style_normal.border_color = Color(0.45, 0.38, 0.24, 1.0)
	style_normal.border_width_left = 3
	style_normal.border_width_top = 3
	style_normal.border_width_right = 3
	style_normal.border_width_bottom = 3
	style_normal.content_margin_left = INNER_PADDING
	style_normal.content_margin_top = INNER_PADDING
	style_normal.content_margin_right = INNER_PADDING
	style_normal.content_margin_bottom = INNER_PADDING
	style_normal.corner_radius_top_left = 8
	style_normal.corner_radius_top_right = 8
	style_normal.corner_radius_bottom_left = 8
	style_normal.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style_normal)

	var style_hover := style_normal.duplicate()
	style_hover.bg_color = Color(0.18, 0.17, 0.22, 1.0)
	button.add_theme_stylebox_override("hover", style_hover)

	var style_pressed := style_normal.duplicate()
	style_pressed.bg_color = Color(0.22, 0.20, 0.28, 1.0)
	style_pressed.border_color = Color(0.88, 0.75, 0.34, 1.0)
	button.add_theme_stylebox_override("pressed", style_pressed)

	var container := CenterContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.add_child(container)

	var inner := VBoxContainer.new()
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_theme_constant_override("separation", TEXT_GAP)
	container.add_child(inner)

	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(SQUARE_SIZE, SQUARE_SIZE)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = _faction_portraits.get(faction, null)
	inner.add_child(portrait)

	var name_label := Label.new()
	name_label.name = "FactionName"
	name_label.text = _faction_display_name(faction)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	inner.add_child(name_label)

	return button


func _set_faction(faction: String) -> void:
	if _faction_options.is_empty():
		_current_faction = faction
		return
	_current_faction = faction
	_ensure_portraits_for_factions()
	if _rows_container == null:
		return
	if _faction_buttons.is_empty() or _faction_buttons.size() != _faction_options.size():
		_rebuild_rows()
	_update_selection_visuals()
	selection_changed.emit(_side, _current_faction)


func _update_selection_visuals() -> void:
	for index in _faction_buttons.size():
		var button: Button = _faction_buttons[index]
		button.button_pressed = _faction_options[index] == _current_faction


func _on_faction_button_pressed(faction: String) -> void:
	if faction == _current_faction:
		return
	_set_faction(faction)


func _on_randomize_pressed() -> void:
	randomize_requested.emit(_side)


func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	var res: Resource = load(path)
	if res is Texture2D:
		return res
	return null


func _faction_display_name(faction: String) -> String:
	var names: Dictionary = {
		"humans": "Ludzie",
		"orcs": "Orkowie",
		"goblins": "Gobliny",
		"elves": "Elfy",
		"dwarves": "Krasnoludy",
		"testowa": "Frakcja testowa"
	}
	return str(names.get(faction, faction))
