class_name UnitSelectPanel
extends VBoxContainer

signal selection_changed(side: String, faction: String)
signal randomize_requested(side: String)

const EMPTY_PORTRAIT: Texture2D = preload("res://assets/ui/unit1.png")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")

var _side: String = "player"
var _faction_options: Array[String] = []
var _current_faction: String = ""
var _faction_button: OptionButton
var _main_portrait: TextureRect
var _class_icons: Array[TextureRect] = []
var _classes_container: HBoxContainer
var _random_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()


func setup(side: String, faction_options: Array[String], initial_faction: String) -> void:
	_side = side
	_faction_options = faction_options
	_set_faction(initial_faction)


func get_side() -> String:
	return _side


func get_selected_faction() -> String:
	return _current_faction


func set_faction(faction: String) -> void:
	_set_faction(faction)


func randomize_faction() -> void:
	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	if faction_ids.is_empty():
		return
	var faction: String = faction_ids[randi() % faction_ids.size()]
	_set_faction(faction)


func _build_ui() -> void:
	add_theme_constant_override("separation", 16)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var panel := Panel.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.16, 1.0)
	style.border_color = Color(0.45, 0.38, 0.24, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.content_margin_left = 20.0
	style.content_margin_top = 20.0
	style.content_margin_right = 20.0
	style.content_margin_bottom = 20.0
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var title := Label.new()
	title.text = "ARMIA GRACZA" if _side == "player" else "ARMIA KOMPUTERA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	add_child(title)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(header)

	_faction_button = OptionButton.new()
	_faction_button.custom_minimum_size = Vector2(180, 40)
	_faction_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_faction_button.item_selected.connect(_on_faction_changed)
	header.add_child(_faction_button)

	_random_button = Button.new()
	_random_button.text = "LOSOWO"
	_random_button.custom_minimum_size = Vector2(100, 40)
	_random_button.pressed.connect(_on_randomize_pressed)
	header.add_child(_random_button)

	_main_portrait = TextureRect.new()
	_main_portrait.name = "MainPortrait"
	_main_portrait.custom_minimum_size = Vector2(260, 260)
	_main_portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_main_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_main_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_main_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var portrait_border := Panel.new()
	portrait_border.custom_minimum_size = Vector2(260, 260)
	portrait_border.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var border_style := StyleBoxFlat.new()
	border_style.bg_color = Color(0.08, 0.08, 0.1, 1.0)
	border_style.border_color = Color(0.55, 0.48, 0.3, 1.0)
	border_style.border_width_left = 2
	border_style.border_width_top = 2
	border_style.border_width_right = 2
	border_style.border_width_bottom = 2
	border_style.corner_radius_top_left = 6
	border_style.corner_radius_top_right = 6
	border_style.corner_radius_bottom_left = 6
	border_style.corner_radius_bottom_right = 6
	portrait_border.add_theme_stylebox_override("panel", border_style)
	portrait_border.add_child(_main_portrait)
	add_child(portrait_border)

	var classes_label := Label.new()
	classes_label.text = "Jednostki armii:"
	classes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	classes_label.add_theme_color_override("font_color", Color(0.85, 0.82, 0.72, 1.0))
	add_child(classes_label)

	_classes_container = HBoxContainer.new()
	_classes_container.add_theme_constant_override("separation", 10)
	_classes_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_classes_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(_classes_container)


func _set_faction(faction: String) -> void:
	if _faction_button == null:
		return
	_current_faction = faction
	_faction_button.clear()
	for index in _faction_options.size():
		_faction_button.add_item(_faction_display_name(_faction_options[index]))
		if _faction_options[index] == faction:
			_faction_button.select(index)
	_refresh_view()


func _refresh_view() -> void:
	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(_current_faction)

	if units.is_empty():
		_main_portrait.texture = EMPTY_PORTRAIT
	else:
		var random_unit: Dictionary = units[randi() % units.size()]
		var tex: Texture2D = _load_texture(str(random_unit.get("portrait", "")))
		_main_portrait.texture = tex if tex != null else EMPTY_PORTRAIT

	for icon_border in _classes_container.get_children():
		icon_border.queue_free()
	_class_icons.clear()

	for unit in units:
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(80, 80)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var tex: Texture2D = _load_texture(str(unit.get("portrait", "")))
		icon.texture = tex if tex != null else EMPTY_PORTRAIT
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var icon_border := Panel.new()
		icon_border.custom_minimum_size = Vector2(80, 80)
		icon_border.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var icon_style := StyleBoxFlat.new()
		icon_style.bg_color = Color(0.08, 0.08, 0.1, 1.0)
		icon_style.border_color = Color(0.4, 0.35, 0.22, 1.0)
		icon_style.border_width_left = 2
		icon_style.border_width_top = 2
		icon_style.border_width_right = 2
		icon_style.border_width_bottom = 2
		icon_style.corner_radius_top_left = 4
		icon_style.corner_radius_top_right = 4
		icon_style.corner_radius_bottom_left = 4
		icon_style.corner_radius_bottom_right = 4
		icon_border.add_theme_stylebox_override("panel", icon_style)
		icon_border.add_child(icon)
		_classes_container.add_child(icon_border)
		_class_icons.append(icon)

	selection_changed.emit(_side, _current_faction)


func _on_faction_changed(_index: int) -> void:
	var selected: int = _faction_button.selected
	if selected < 0 or selected >= _faction_options.size():
		return
	var faction: String = _faction_options[selected]
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
		"dwarves": "Krasnoludy"
	}
	return str(names.get(faction, faction))
