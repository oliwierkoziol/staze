extends HBoxContainer

const HEADER_COLOR := Color(0.86, 0.72, 0.34, 1.0)
const TEXT_COLOR := Color(0.9, 0.87, 0.78, 1.0)
const MUTED_COLOR := Color(0.55, 0.52, 0.48, 1.0)
const EFFECT_ICON_SIZE := Vector2(24, 24)
const EFFECT_PLACEHOLDER_ICON: Texture2D = preload("res://assets/ui/fire.png")
const BUFF_ICON_TINT := Color(0.35, 0.72, 0.32, 1.0)
const DEFAULT_DEBUFF_ICON_TINT := Color(0.55, 0.32, 0.72, 1.0)
const DEBUFF_ICON_TINT_BY_ID := {
	"immobilize": Color(0.44, 0.7, 0.95, 1.0),
	"toksyna": Color(0.42, 0.82, 0.32, 1.0),
	"ogluszenie": Color(0.92, 0.82, 0.28, 1.0),
}

const STAT_LABELS := {
	"dmg": "DMG",
	"def": "DEF",
	"hp": "HP",
	"speed": "Szybkosc",
	"move_range": "Zasieg ruchu",
	"attack_range": "Zasieg ataku",
}

var _buffs_list: HBoxContainer
var _debuffs_list: HBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 10)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_layout()


func _build_layout() -> void:
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(content)

	content.add_child(_make_section_title("BUFFY"))
	_buffs_list = _add_effects_box(content)

	content.add_child(_make_section_title("DEBUFFY"))
	_debuffs_list = _add_effects_box(content)


func _make_section_title(text: String) -> Label:
	var title := Label.new()
	title.text = text
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.add_theme_font_size_override("font_size", 15)
	return title


func _add_effects_box(parent: VBoxContainer) -> HBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_inner_box_style())

	var list := HBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_rebuild_effects_list(_buffs_list, unit_data.get("active_effects", []), "buff")
	_rebuild_effects_list(_debuffs_list, unit_data.get("active_effects", []), "debuff")


func clear() -> void:
	_clear_effects_list(_buffs_list)
	_clear_effects_list(_debuffs_list)


func _rebuild_effects_list(list: HBoxContainer, effects: Array, category: String) -> void:
	_clear_effects_list(list)
	var has_items := false
	for effect in effects:
		if str(effect.get("category", "")) != category:
			continue
		has_items = true
		list.add_child(_make_effect_entry(effect))
	if not has_items:
		list.add_child(_make_empty_label())


func _clear_effects_list(list: HBoxContainer) -> void:
	for child in list.get_children():
		child.queue_free()


func _make_empty_label() -> Label:
	var label := Label.new()
	label.text = "Brak"
	label.add_theme_color_override("font_color", MUTED_COLOR)
	label.add_theme_font_size_override("font_size", 12)
	return label


func _make_effect_entry(effect: Dictionary) -> Control:
	var category := str(effect.get("category", ""))
	var icon_tint: Color = BUFF_ICON_TINT if category == "buff" else DEFAULT_DEBUFF_ICON_TINT
	if category == "debuff":
		icon_tint = DEBUFF_ICON_TINT_BY_ID.get(str(effect.get("id", "")), DEFAULT_DEBUFF_ICON_TINT)

	var tooltip := _build_effect_tooltip(effect)

	var icon := TextureRect.new()
	icon.texture = EFFECT_PLACEHOLDER_ICON
	icon.modulate = icon_tint
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = EFFECT_ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.tooltip_text = tooltip

	if category != "debuff":
		return icon

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.tooltip_text = tooltip
	row.add_child(icon)

	var title := Label.new()
	title.text = str(effect.get("name", "")).to_upper()
	title.add_theme_color_override("font_color", TEXT_COLOR)
	title.add_theme_font_size_override("font_size", 12)
	title.tooltip_text = tooltip
	row.add_child(title)

	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	return row


func _build_effect_tooltip(effect: Dictionary) -> String:
	var lines: Array[String] = [str(effect.get("name", "")).to_upper()]
	lines.append("Pozostale tury: %s" % str(effect.get("remaining_turns", 0)))

	var description := _format_effect_description(effect)
	if description != "":
		lines.append(description)
	return "\n".join(lines)


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
