class_name UnitSelectPanel
extends VBoxContainer

signal selection_changed(side: String, slot: int, type_id: String)
signal randomize_requested(side: String)

const EMPTY_PORTRAIT: Texture2D = preload("res://assets/ui/unit1.png")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")

var _side: String = "player"
var _faction_options: Array[String] = []
var _current_faction: String = ""
var _current_type_id: String = ""
var _faction_button: OptionButton
var _main_portrait: TextureRect
var _class_buttons: Array[Button] = []
var _classes_container: HBoxContainer
var _random_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()


func setup(side: String, faction_options: Array[String], initial_faction: String, initial_type_id: String) -> void:
	_side = side
	_faction_options = faction_options
	_set_faction(initial_faction)
	_set_type(initial_type_id)


func get_side() -> String:
	return _side


func get_selected_faction() -> String:
	return _current_faction


func get_selected_type_id() -> String:
	return _current_type_id


func set_type(type_id: String) -> void:
	_set_type(type_id)


func randomize_type() -> void:
	var faction_ids: Array[String] = UnitTypeLibraryScript.get_faction_ids()
	if faction_ids.is_empty():
		return
	var faction: String = faction_ids[randi() % faction_ids.size()]
	_set_faction(faction)
	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(faction)
	if units.is_empty():
		return
	var unit: Dictionary = units[randi() % units.size()]
	_set_type(str(unit.get("id", "")))


func _build_ui() -> void:
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
	_main_portrait.custom_minimum_size = Vector2(220, 220)
	_main_portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_main_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_main_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_main_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_main_portrait)

	var classes_label := Label.new()
	classes_label.text = "Wybierz klasę:"
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
	_faction_button.clear()
	for index in _faction_options.size():
		_faction_button.add_item(_faction_display_name(_faction_options[index]))
		if _faction_options[index] == faction:
			_faction_button.select(index)
	_current_faction = faction
	_rebuild_class_buttons()


func _set_type(type_id: String) -> void:
	_current_type_id = type_id
	var type_data: Dictionary = _find_type_data(type_id)
	if type_data.is_empty():
		_main_portrait.texture = EMPTY_PORTRAIT
	else:
		var tex: Texture2D = _load_texture(str(type_data.get("portrait", "")))
		_main_portrait.texture = tex if tex != null else EMPTY_PORTRAIT
	_rebuild_class_buttons()
	selection_changed.emit(_side, 0, _current_type_id)


func _rebuild_class_buttons() -> void:
	for button in _class_buttons:
		button.queue_free()
	_class_buttons.clear()

	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(_current_faction)
	for index in units.size():
		var unit: Dictionary = units[index]
		var button := _create_class_button(unit)
		_classes_container.add_child(button)
		_class_buttons.append(button)


func _create_class_button(unit: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(72, 72)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.flat = true

	var tex: Texture2D = _load_texture(str(unit.get("portrait", "")))
	var icon: TextureRect = TextureRect.new()
	icon.name = "Icon"
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.offset_left = 4.0
	icon.offset_top = 4.0
	icon.offset_right = -4.0
	icon.offset_bottom = -4.0
	icon.grow_horizontal = 2
	icon.grow_vertical = 2
	icon.texture = tex if tex != null else EMPTY_PORTRAIT
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var type_id: String = str(unit.get("id", ""))
	button.pressed.connect(_on_class_pressed.bind(type_id))
	return button


func _on_faction_changed(_index: int) -> void:
	var selected: int = _faction_button.selected
	if selected < 0 or selected >= _faction_options.size():
		return
	var faction: String = _faction_options[selected]
	if faction == _current_faction:
		return
	_current_faction = faction
	var units: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(faction)
	var first_type: String = ""
	if not units.is_empty():
		first_type = str(units[0].get("id", ""))
	_set_type(first_type)


func _on_class_pressed(type_id: String) -> void:
	_set_type(type_id)


func _on_randomize_pressed() -> void:
	randomize_requested.emit(_side)


func _find_type_data(type_id: String) -> Dictionary:
	if type_id == "":
		return {}
	return UnitTypeLibraryScript.lookup(type_id)


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
