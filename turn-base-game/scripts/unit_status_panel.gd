extends HBoxContainer

const HEADER_COLOR := Color(0.86, 0.72, 0.34, 1.0)
const TEXT_COLOR := Color(0.9, 0.87, 0.78, 1.0)
const MUTED_COLOR := Color(0.55, 0.52, 0.48, 1.0)
const ICON_SIZE := Vector2(18, 18)
const RESISTANCE_ICON_SIZE := Vector2(24, 24)
const BUFF_ICON_COLOR := Color(0.35, 0.72, 0.32, 1.0)
const DEBUFF_ICON_COLOR := Color(0.55, 0.32, 0.72, 1.0)

const RESISTANCE_TYPES: Array[Dictionary] = [
	{"id": "fire", "label": "OGIEŃ", "icon": preload("res://assets/ui/fire.png"), "tint": Color(0.98, 0.52, 0.18, 1.0)},
	{"id": "lightning", "label": "BŁYSKAWICE", "icon": preload("res://assets/ui/electricity.png"), "tint": Color(0.98, 0.88, 0.22, 1.0)},
	{"id": "poison", "label": "TRUCIZNA", "icon": preload("res://assets/ui/poison.png"), "tint": Color(0.42, 0.82, 0.32, 1.0)},
	{"id": "cold", "label": "ZIMNO", "icon": preload("res://assets/ui/frost.png"), "tint": Color(0.48, 0.78, 0.98, 1.0)},
]

const STAT_LABELS := {
	"dmg": "DMG",
	"def": "DEF",
	"hp": "HP",
	"speed": "Szybkosc",
	"move_range": "Zasieg ruchu",
	"attack_range": "Zasieg ataku",
}

var _divider_tex: Texture2D = preload("res://assets/ui/divider.png")
var _resistance_value_labels: Dictionary = {}
var _buffs_list: VBoxContainer
var _debuffs_list: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_layout()


func _build_layout() -> void:
	var resistances_column := _build_resistances_column()
	resistances_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resistances_column.size_flags_stretch_ratio = 1.1
	add_child(resistances_column)

	add_child(_make_vertical_divider())

	var effects_column := VBoxContainer.new()
	effects_column.add_theme_constant_override("separation", 10)
	effects_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	effects_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	effects_column.size_flags_stretch_ratio = 1.4
	add_child(effects_column)

	effects_column.add_child(_make_section_title("BUFFY"))
	_buffs_list = _add_effects_box(effects_column)

	effects_column.add_child(_make_section_title("DEBUFFY"))
	_debuffs_list = _add_effects_box(effects_column)


func _build_resistances_column() -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	column.add_child(_make_section_title("ODPORNOŚCI"))

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 0)
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(list)

	for resistance_type in RESISTANCE_TYPES:
		var id := str(resistance_type.id)
		list.add_child(_make_divider())
		list.add_child(_make_resistance_row(
			id,
			str(resistance_type.label),
			resistance_type.icon,
			resistance_type.tint
		))

	return column


func _make_section_title(text: String) -> Label:
	var title := Label.new()
	title.text = text
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.add_theme_font_size_override("font_size", 15)
	return title


func _make_vertical_divider() -> ColorRect:
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(1, 0)
	divider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	divider.color = Color(0.45, 0.38, 0.2, 0.65)
	return divider


func _make_divider() -> TextureRect:
	var divider := TextureRect.new()
	divider.texture = _divider_tex
	divider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	divider.stretch_mode = TextureRect.STRETCH_SCALE
	divider.custom_minimum_size = Vector2(0, 2)
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return divider


func _make_resistance_row(id: String, label_text: String, icon_tex: Texture2D, tint: Color) -> MarginContainer:
	var row := MarginContainer.new()
	row.add_theme_constant_override("margin_top", 7)
	row.add_theme_constant_override("margin_bottom", 7)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(hbox)

	hbox.add_child(_make_texture_icon(icon_tex, RESISTANCE_ICON_SIZE, tint))

	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	name_label.add_theme_font_size_override("font_size", 13)
	hbox.add_child(name_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var value_label := Label.new()
	value_label.text = "0%"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", TEXT_COLOR)
	value_label.add_theme_font_size_override("font_size", 13)
	hbox.add_child(value_label)

	_resistance_value_labels[id] = value_label
	return row


func _make_texture_icon(icon_tex: Texture2D, size: Vector2 = ICON_SIZE, tint: Color = Color.WHITE) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = icon_tex
	icon.modulate = tint
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return icon


func _add_effects_box(parent: VBoxContainer) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_inner_box_style())

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	panel.add_child(list)
	parent.add_child(panel)
	return list


func _make_inner_box_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.07, 0.92)
	style.border_color = Color(0.45, 0.38, 0.2, 0.75)
	style.set_border_width_all(1)
	style.set_content_margin_all(10)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


func set_unit(unit_data: Dictionary) -> void:
	var resistances: Dictionary = unit_data.get("resistances", {})
	for id in _resistance_value_labels:
		var value_label: Label = _resistance_value_labels[id]
		var amount := int(resistances.get(id, 0))
		value_label.text = "%d%%" % amount

	_rebuild_effects_list(_buffs_list, unit_data.get("active_effects", []), "buff", BUFF_ICON_COLOR)
	_rebuild_effects_list(_debuffs_list, unit_data.get("active_effects", []), "debuff", DEBUFF_ICON_COLOR)


func clear() -> void:
	for id in _resistance_value_labels:
		_resistance_value_labels[id].text = "0%"
	_clear_effects_list(_buffs_list)
	_clear_effects_list(_debuffs_list)


func _rebuild_effects_list(list: VBoxContainer, effects: Array, category: String, icon_color: Color) -> void:
	_clear_effects_list(list)
	var has_items := false
	for effect in effects:
		if str(effect.get("category", "")) != category:
			continue
		has_items = true
		list.add_child(_make_effect_row(str(effect.get("name", "")), _format_effect_description(effect), icon_color))
	if not has_items:
		list.add_child(_make_empty_label())


func _clear_effects_list(list: VBoxContainer) -> void:
	for child in list.get_children():
		child.queue_free()


func _make_empty_label() -> Label:
	var label := Label.new()
	label.text = "Brak"
	label.add_theme_color_override("font_color", MUTED_COLOR)
	label.add_theme_font_size_override("font_size", 12)
	return label


func _make_effect_row(title: String, description: String, icon_color: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	row.add_child(_make_effect_icon(icon_color))

	var text_column := VBoxContainer.new()
	text_column.add_theme_constant_override("separation", 2)
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_column)

	var title_label := Label.new()
	title_label.text = title.to_upper()
	title_label.add_theme_color_override("font_color", TEXT_COLOR)
	title_label.add_theme_font_size_override("font_size", 13)
	text_column.add_child(title_label)

	if description != "":
		var desc_label := Label.new()
		desc_label.text = description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_color_override("font_color", MUTED_COLOR)
		desc_label.add_theme_font_size_override("font_size", 12)
		text_column.add_child(desc_label)

	return row


func _make_effect_icon(color: Color) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(24, 24)

	var icon := ColorRect.new()
	icon.color = color
	icon.custom_minimum_size = Vector2(24, 24)
	icon.set_anchors_preset(Control.PRESET_CENTER)
	icon.offset_left = -12.0
	icon.offset_top = -12.0
	icon.offset_right = 12.0
	icon.offset_bottom = 12.0
	wrapper.add_child(icon)

	return wrapper


func _format_effect_description(effect: Dictionary) -> String:
	var parts: Array[String] = []
	for change in effect.get("stat_changes", []):
		var formatted := _format_stat_change(change)
		if formatted != "":
			parts.append(formatted)

	var tick_damage := int(effect.get("tick_damage", 0))
	if tick_damage > 0:
		parts.append("-%d HP co ture" % tick_damage)

	return ", ".join(parts)


func _format_stat_change(change: Dictionary) -> String:
	var stat_name := str(change.get("stat", ""))
	var mode := str(change.get("mode", "flat"))
	var value := int(change.get("value", 0))
	var stat_label: String = STAT_LABELS.get(stat_name, stat_name.to_upper())

	match mode:
		"flat":
			return "%+d %s" % [value, stat_label]
		"percent":
			return "%+d%% %s" % [value, stat_label]
		"set":
			return "%s = %d" % [stat_label, value]
	return ""
