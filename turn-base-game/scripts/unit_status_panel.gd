extends HBoxContainer

const HEADER_COLOR := Color(0.86, 0.72, 0.34, 1.0)
const TEXT_COLOR := Color(0.9, 0.87, 0.78, 1.0)
const MUTED_COLOR := Color(0.55, 0.52, 0.48, 1.0)
const EFFECT_ICON_SIZE := Vector2(28, 28)
const EFFECT_TURNS_FONT_SIZE := 12
const EFFECT_ITEM_SEPARATION := 8
const EFFECT_ROW_SEPARATION := 2
const EFFECT_ENTRY_SEPARATION := 1
const EFFECTS_PER_ROW := 6
const EFFECT_PLACEHOLDER_ICON: Texture2D = preload("res://assets/ui/fire.png")
const EFFECT_BUFF_FALLBACK_ICON: Texture2D = preload("res://assets/ui/buffs.png")
const EFFECT_DEBUFF_FALLBACK_ICON: Texture2D = preload("res://assets/ui/debuffs.png")
const PANEL_TEXTURE: Texture2D = preload("res://assets/ui/panel.png")
const NINE_PATCH_PANEL_SCRIPT: Script = preload("res://scripts/nine_patch_panel.gd")
const PANEL_PATCH_MARGIN := 8
const EFFECT_PANEL_MARGIN_H := 4
const EFFECT_PANEL_MARGIN_V := 6
const BUFF_ICON_TINT := Color(0.35, 0.72, 0.32, 1.0)
const DEFAULT_DEBUFF_ICON_TINT := Color(0.55, 0.32, 0.72, 1.0)
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")

var _buffs_list: VBoxContainer
var _debuffs_list: VBoxContainer
var _effect_icon_cache: Dictionary = {}


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

	var buffs_section := _make_effects_section(content, "BUFFY")
	_buffs_list = buffs_section.list

	var debuffs_section := _make_effects_section(content, "DEBUFFY")
	_debuffs_list = debuffs_section.list


func _make_effects_section(parent: VBoxContainer, title: String) -> Dictionary:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 4)
	section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.size_flags_stretch_ratio = 1.0
	parent.add_child(section)

	section.add_child(_make_section_title(title))

	var list := _add_effects_box(section)
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return {"list": list}


func _make_section_title(text: String) -> Label:
	var title := Label.new()
	title.text = text
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.add_theme_font_size_override("font_size", 15)
	return title


func _add_effects_box(parent: VBoxContainer) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", EFFECT_ROW_SEPARATION)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(list)
	return list


func set_unit(unit_data: Dictionary) -> void:
	_rebuild_effects_list(_buffs_list, unit_data.get("active_effects", []), "buff")
	_rebuild_effects_list(_debuffs_list, unit_data.get("active_effects", []), "debuff")


func clear() -> void:
	_clear_effects_list(_buffs_list)
	_clear_effects_list(_debuffs_list)


func _rebuild_effects_list(list: VBoxContainer, effects: Array, category: String) -> void:
	_clear_effects_list(list)
	var matched: Array = []
	for effect in effects:
		if str(effect.get("category", "")) == category:
			matched.append(effect)
	if matched.is_empty():
		list.add_child(_make_empty_label())
		return

	list.add_child(_make_effects_row(matched.slice(0, mini(EFFECTS_PER_ROW, matched.size()))))
	if matched.size() > EFFECTS_PER_ROW:
		list.add_child(_make_effects_row(matched.slice(EFFECTS_PER_ROW)))


func _make_effects_row(effects: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", EFFECT_ITEM_SEPARATION)
	for effect in effects:
		row.add_child(_make_effect_entry(effect))
	return row


func _clear_effects_list(list: VBoxContainer) -> void:
	for child in list.get_children():
		child.queue_free()


func _make_empty_label() -> Label:
	var label := Label.new()
	label.text = "Brak"
	label.add_theme_color_override("font_color", MUTED_COLOR)
	label.add_theme_font_size_override("font_size", 12)
	return label


func _make_effect_entry(effect: Dictionary) -> Control:
	var icon_tint: Color = _resolve_effect_tint(effect)
	var effect_icon: Texture2D = _resolve_effect_icon(effect)

	var tooltip := _build_effect_tooltip(effect)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", EFFECT_ENTRY_SEPARATION)
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.tooltip_text = tooltip
	column.mouse_filter = Control.MOUSE_FILTER_STOP

	var icon := TextureRect.new()
	icon.texture = effect_icon
	icon.modulate = icon_tint
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = EFFECT_ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.tooltip_text = tooltip
	column.add_child(icon)

	var turns_label := Label.new()
	turns_label.text = str(int(effect.get("remaining_turns", 0)))
	turns_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turns_label.add_theme_color_override("font_color", TEXT_COLOR)
	turns_label.add_theme_font_size_override("font_size", EFFECT_TURNS_FONT_SIZE)
	turns_label.tooltip_text = tooltip
	column.add_child(turns_label)

	return _wrap_in_panel(column, tooltip)


func _resolve_effect_tint(effect: Dictionary) -> Color:
	var meta: Dictionary = UnitTypeLibraryScript.get_status_effect(str(effect.get("id", "")))
	var color_hex: String = str(meta.get("color", ""))
	if color_hex != "":
		return Color.from_string(color_hex, DEFAULT_DEBUFF_ICON_TINT)
	var category := str(effect.get("category", ""))
	return BUFF_ICON_TINT if category == "buff" else DEFAULT_DEBUFF_ICON_TINT


func _resolve_effect_icon(effect: Dictionary) -> Texture2D:
	var meta: Dictionary = UnitTypeLibraryScript.get_status_effect(str(effect.get("id", "")))
	var icon_path: String = str(meta.get("icon", ""))
	if icon_path != "":
		if _effect_icon_cache.has(icon_path):
			var cached: Variant = _effect_icon_cache[icon_path]
			if cached is Texture2D:
				return cached
		var loaded_icon: Variant = load(icon_path)
		if loaded_icon is Texture2D:
			_effect_icon_cache[icon_path] = loaded_icon
			return loaded_icon
	var category := str(effect.get("category", ""))
	if category == "buff":
		return EFFECT_BUFF_FALLBACK_ICON
	if category == "debuff":
		return EFFECT_DEBUFF_FALLBACK_ICON
	return EFFECT_PLACEHOLDER_ICON


func _wrap_in_panel(content: Control, tooltip: String) -> NinePatchRect:
	var panel := NinePatchRect.new()
	panel.texture = PANEL_TEXTURE
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.patch_margin_left = PANEL_PATCH_MARGIN
	panel.patch_margin_top = PANEL_PATCH_MARGIN
	panel.patch_margin_right = PANEL_PATCH_MARGIN
	panel.patch_margin_bottom = PANEL_PATCH_MARGIN
	panel.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	panel.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	panel.set_script(NINE_PATCH_PANEL_SCRIPT)
	panel.tooltip_text = tooltip
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", EFFECT_PANEL_MARGIN_H)
	margin.add_theme_constant_override("margin_top", EFFECT_PANEL_MARGIN_V)
	margin.add_theme_constant_override("margin_right", EFFECT_PANEL_MARGIN_H)
	margin.add_theme_constant_override("margin_bottom", EFFECT_PANEL_MARGIN_V)
	panel.add_child(margin)
	margin.add_child(content)
	return panel


func _build_effect_tooltip(effect: Dictionary) -> String:
	var meta: Dictionary = UnitTypeLibraryScript.get_status_effect(str(effect.get("id", "")))
	var effect_name: String = str(meta.get("name", effect.get("name", "")))
	var lines: Array[String] = [effect_name.to_upper()]

	var description := str(meta.get("description", ""))
	if description != "":
		lines.append(description)

	lines.append("Pozostale tury: %d" % int(effect.get("remaining_turns", 0)))
	return "\n".join(lines)


