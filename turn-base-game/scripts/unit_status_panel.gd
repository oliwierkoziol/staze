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
const BUFF_ICON_TINT_BY_ID := {
	"bariera_energetyczna": Color(0.34, 0.78, 0.96, 1.0),
	"berserk": Color(0.86, 0.35, 0.35, 1.0),
	"bitewny_trucht": Color(0.6, 0.9, 0.4, 1.0),
	"krwawa_ofiara": Color(0.88, 0.2, 0.2, 1.0),
	"krzok": Color(0.34, 0.78, 0.34, 1.0),
	"medytacja": Color(0.54, 0.46, 0.92, 1.0),
	"przyspieszenie": Color(0.64, 0.94, 0.35, 1.0),
	"runiczna_ochrona": Color(0.5, 0.8, 1.0, 1.0),
	"silna_motywacja": Color(0.98, 0.72, 0.28, 1.0),
	"sokole_oko": Color(0.95, 0.86, 0.36, 1.0),
	"szarza": Color(0.97, 0.62, 0.2, 1.0),
	"szybkie_manewry": Color(0.72, 0.9, 0.34, 1.0),
	"tarcza": Color(0.56, 0.74, 0.98, 1.0),
	"tarcza_bastionu": Color(0.56, 0.74, 0.98, 1.0),
	"twardy_zakaz": Color(0.4, 0.72, 0.94, 1.0),
	"wola_przetrwania": Color(0.9, 0.78, 0.38, 1.0),
	"zelazna_kurtyna": Color(0.66, 0.74, 0.82, 1.0),
	"zimna_krew": Color(0.62, 0.86, 1.0, 1.0),
	"zmasowany_atak": Color(0.96, 0.5, 0.24, 1.0),
	"krzyk_wodza": Color(0.96, 0.5, 0.24, 1.0),
}
const DEBUFF_ICON_TINT_BY_ID := {
	"immobilize": Color(0.4, 0.72, 0.96, 1.0),
	"krwawienie": Color(0.9, 0.14, 0.16, 1.0),
	"lodowe_podloze": Color(0.5, 0.84, 1.0, 1.0),
	"ogluszenie": Color(0.96, 0.84, 0.3, 1.0),
	"taunt": Color(0.98, 0.62, 0.2, 1.0),
	"toksyna": Color(0.42, 0.86, 0.3, 1.0),
	"woda": Color(0.36, 0.68, 0.98, 1.0),
	"wykrycie": Color(0.98, 0.62, 0.24, 1.0),
	"zatrucie": Color(0.32, 0.78, 0.28, 1.0),
}
const EFFECT_ICON_BY_ID := {
	"bariera_energetyczna": preload("res://assets/ui/energy_shield.png"),
	"berserk": preload("res://assets/ui/berserk.png"),
	"bitewny_trucht": preload("res://assets/ui/speed.png"),
	"immobilize": preload("res://assets/ui/root.png"),
	"krwawa_ofiara": preload("res://assets/ui/blood_offering.png"),
	"krwawienie": preload("res://assets/ui/damage.png"),
	"krzok": preload("res://assets/ui/invisibility.png"),
	"lodowe_podloze": preload("res://assets/ui/frost.png"),
	"medytacja": preload("res://assets/ui/meditation.png"),
	"ogluszenie": preload("res://assets/ui/stun.png"),
	"przyspieszenie": preload("res://assets/ui/speed.png"),
	"runiczna_ochrona": preload("res://assets/ui/aura.png"),
	"silna_motywacja": preload("res://assets/ui/focus.png"),
	"sokole_oko": preload("res://assets/ui/eagle_eye.png"),
	"szarza": preload("res://assets/ui/speed.png"),
	"szybkie_manewry": preload("res://assets/ui/speed.png"),
	"tarcza": preload("res://assets/ui/defence.png"),
	"tarcza_bastionu": preload("res://assets/ui/defence.png"),
	"toksyna": preload("res://assets/ui/poison.png"),
	"twardy_zakaz": preload("res://assets/ui/armor_break.png"),
	"woda": preload("res://assets/ui/exhaust.png"),
	"wola_przetrwania": preload("res://assets/ui/immunity.png"),
	"wykrycie": preload("res://assets/ui/reveal.png"),
	"zatrucie": preload("res://assets/ui/poison_cloud.png"),
	"zelazna_kurtyna": preload("res://assets/ui/iron_curtain.png"),
	"zimna_krew": preload("res://assets/ui/immunity.png"),
	"zmasowany_atak": preload("res://assets/ui/focus.png"),
	"krzyk_wodza": preload("res://assets/ui/focus.png"),
}
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const EFFECT_SKILL_FALLBACKS := {
	"immobilize": "strzal_w_kolano",
	"toksyna": "zatruty_sztylet",
	"ogluszenie": "potezne_uderzenie",
	"zatrucie": "chmura_toksyczna",
}
const TERRAIN_EFFECT_DESCRIPTIONS := {
	"woda": "Wejscie do wody zuzywa caly pozostaly ruch w tej turze.",
	"krzak": "Jednostka w krzaku jest niewidzialna dla wrogow poza sasiednim krzakiem.",
}

var _buffs_list: VBoxContainer
var _debuffs_list: VBoxContainer


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
	var category := str(effect.get("category", ""))
	var effect_id := _normalize_effect_visual_id(str(effect.get("id", "")))
	if category == "buff":
		return BUFF_ICON_TINT_BY_ID.get(effect_id, BUFF_ICON_TINT)
	return DEBUFF_ICON_TINT_BY_ID.get(effect_id, DEFAULT_DEBUFF_ICON_TINT)


func _resolve_effect_icon(effect: Dictionary) -> Texture2D:
	var effect_id := _normalize_effect_visual_id(str(effect.get("id", "")))
	var icon_variant: Variant = EFFECT_ICON_BY_ID.get(effect_id, null)
	if icon_variant is Texture2D:
		return icon_variant
	var category := str(effect.get("category", ""))
	if category == "buff":
		return EFFECT_BUFF_FALLBACK_ICON
	if category == "debuff":
		return EFFECT_DEBUFF_FALLBACK_ICON
	return EFFECT_PLACEHOLDER_ICON


func _normalize_effect_visual_id(effect_id: String) -> String:
	if effect_id.begins_with("taunt_"):
		return "taunt"
	return effect_id


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
	var lines: Array[String] = [str(effect.get("name", "")).to_upper()]

	var description := _lookup_effect_description(effect)
	if description != "":
		lines.append(description)

	lines.append("Pozostale tury: %d" % int(effect.get("remaining_turns", 0)))
	return "\n".join(lines)


func _lookup_effect_description(effect: Dictionary) -> String:
	var effect_id := str(effect.get("id", ""))
	var lookup_id := effect_id
	if effect_id.begins_with("taunt_"):
		lookup_id = "prowokacja"

	var skill: Dictionary = UnitTypeLibraryScript.get_skill(lookup_id)
	if not skill.is_empty() and str(skill.get("description", "")) != "":
		return str(skill.get("description", ""))

	skill = UnitTypeLibraryScript.get_general_skill(lookup_id)
	if not skill.is_empty() and str(skill.get("description", "")) != "":
		return str(skill.get("description", ""))

	var fallback_id: String = EFFECT_SKILL_FALLBACKS.get(effect_id, "")
	if fallback_id != "":
		skill = UnitTypeLibraryScript.get_skill(fallback_id)
		if not skill.is_empty() and str(skill.get("description", "")) != "":
			return str(skill.get("description", ""))

	return str(TERRAIN_EFFECT_DESCRIPTIONS.get(lookup_id, ""))
