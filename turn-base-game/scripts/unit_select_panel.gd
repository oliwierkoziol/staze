class_name UnitSelectPanel
extends VBoxContainer

signal selection_changed(side: String, slot: int, type_id: String)
signal randomize_requested(side: String)

const PANEL_BG: Texture2D = preload("res://assets/ui/panel.png")
const EMPTY_PORTRAIT: Texture2D = preload("res://assets/ui/unit1.png")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const FACTION_ICONS: Dictionary = {
	"humans": preload("res://assets/ui/unit1.png"),
	"orcs": preload("res://assets/ui/unit1.png"),
	"goblins": preload("res://assets/ui/unit1.png"),
	"elves": preload("res://assets/ui/unit1.png"),
	"dwarves": preload("res://assets/ui/unit1.png"),
}

var _side: String = "player"
var _slots: Array[Dictionary] = []
var _faction_options: Array[String] = []
var _faction_button: OptionButton
var _slots_container: HBoxContainer
var _slot_buttons: Array[Button] = []
var _random_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_header()
	_build_slots()


func setup(side: String, faction_options: Array[String], initial_faction: String, slots: Array[Dictionary]) -> void:
	_side = side
	_faction_options = faction_options
	if _faction_button == null:
		return
	_faction_button.clear()
	for faction in faction_options:
		_faction_button.add_item(_faction_display_name(faction))
	_set_faction(initial_faction)
	_set_slots(slots)


func get_side() -> String:
	return _side


func get_selected_faction() -> String:
	if _faction_options.is_empty():
		return ""
	var index: int = _faction_button.selected
	if index < 0 or index >= _faction_options.size():
		return _faction_options[0]
	return _faction_options[index]


func get_slots() -> Array[Dictionary]:
	return _slots.duplicate(true)


func set_slot(slot_index: int, type_id: String) -> void:
	if slot_index < 0 or slot_index >= _slots.size():
		return
	_slots[slot_index]["type_id"] = type_id
	_refresh_slot(slot_index)


func _build_header() -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(header)

	var title := Label.new()
	title.text = "WYBIERZ FRakcje" if _side == "player" else "PRZECIWNIK"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_faction_button = OptionButton.new()
	_faction_button.custom_minimum_size = Vector2(180, 40)
	_faction_button.item_selected.connect(_on_faction_changed)
	header.add_child(_faction_button)

	_random_button = Button.new()
	_random_button.text = "LOSOWO"
	_random_button.custom_minimum_size = Vector2(100, 40)
	_random_button.pressed.connect(_on_randomize_pressed)
	header.add_child(_random_button)


func _build_slots() -> void:
	_slots_container = HBoxContainer.new()
	_slots_container.add_theme_constant_override("separation", 10)
	_slots_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slots_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_slots_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(_slots_container)


func _set_faction(faction: String) -> void:
	for index in _faction_options.size():
		if _faction_options[index] == faction:
			_faction_button.select(index)
			return
	if not _faction_options.is_empty():
		_faction_button.select(0)


func _set_slots(slots: Array[Dictionary]) -> void:
	for child in _slots_container.get_children():
		child.queue_free()
	_slot_buttons.clear()
	_slots = slots.duplicate(true)
	for index in _slots.size():
		var button := _create_slot_button(index)
		_slots_container.add_child(button)
		_slot_buttons.append(button)
		_refresh_slot(index)


func _create_slot_button(index: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(120, 160)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.flat = true

	var panel := NinePatchRect.new()
	panel.name = "Panel"
	panel.texture = PANEL_BG
	panel.patch_margin_left = 8
	panel.patch_margin_top = 8
	panel.patch_margin_right = 8
	panel.patch_margin_bottom = 8
	panel.layout_mode = 1
	panel.anchors_preset = 15
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_horizontal = 2
	panel.grow_vertical = 2
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(panel)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.layout_mode = 1
	margin.anchors_preset = 15
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.grow_horizontal = 2
	margin.grow_vertical = 2
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)

	var column := VBoxContainer.new()
	column.name = "Column"
	column.layout_mode = 1
	column.anchors_preset = 15
	column.anchor_right = 1.0
	column.anchor_bottom = 1.0
	column.grow_horizontal = 2
	column.grow_vertical = 2
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.layout_mode = 1
	portrait.anchors_preset = 15
	portrait.anchor_right = 1.0
	portrait.anchor_bottom = 1.0
	portrait.grow_horizontal = 2
	portrait.grow_vertical = 2
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.custom_minimum_size = Vector2(80, 100)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(portrait)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.layout_mode = 1
	name_label.anchors_preset = 12
	name_label.anchor_top = 1.0
	name_label.anchor_right = 1.0
	name_label.anchor_bottom = 1.0
	name_label.offset_top = -20.0
	name_label.grow_horizontal = 2
	name_label.grow_vertical = 0
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 1.0))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(name_label)

	button.pressed.connect(_on_slot_pressed.bind(index))
	return button


func _refresh_slot(index: int) -> void:
	if index < 0 or index >= _slot_buttons.size():
		return
	var button: Button = _slot_buttons[index]
	var margin: MarginContainer = button.get_node("Margin")
	var column: VBoxContainer = margin.get_node("Column")
	var portrait: TextureRect = column.get_node("Portrait")
	var name_label: Label = column.get_node("NameLabel")
	var type_id: String = str(_slots[index].get("type_id", ""))
	var type_data: Dictionary = _find_type_data(type_id)
	if type_data.is_empty():
		portrait.texture = EMPTY_PORTRAIT
		name_label.text = "Pusty"
	else:
		var tex: Texture2D = _load_texture(str(type_data.get("portrait", "")))
		portrait.texture = tex if tex != null else EMPTY_PORTRAIT
		name_label.text = str(type_data.get("short_name", type_data.get("name", "")))


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


func _on_faction_changed(_index: int) -> void:
	selection_changed.emit(_side, -1, "")


func _on_slot_pressed(index: int) -> void:
	var faction: String = get_selected_faction()
	var available: Array[Dictionary] = UnitTypeLibraryScript.get_faction_units(faction)
	if available.is_empty():
		return
	var current_id: String = str(_slots[index].get("type_id", ""))
	var next_index := 0
	for type_index in available.size():
		if str(available[type_index].get("id", "")) == current_id:
			next_index = (type_index + 1) % available.size()
			break
	var next_id: String = str(available[next_index].get("id", ""))
	set_slot(index, next_id)
	selection_changed.emit(_side, index, next_id)


func _on_randomize_pressed() -> void:
	randomize_requested.emit(_side)


func _faction_display_name(faction: String) -> String:
	var names: Dictionary = {
		"humans": "Ludzie",
		"orcs": "Orkowie",
		"goblins": "Gobliny",
		"elves": "Elfy",
		"dwarves": "Krasnoludy"
	}
	return str(names.get(faction, faction))
