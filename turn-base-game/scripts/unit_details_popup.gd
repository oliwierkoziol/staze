extends PopupPanel

const PANEL_TEXTURE: Texture2D = preload("res://assets/ui/panel.png")
const GOLD := Color(0.86, 0.72, 0.34)
const TEXT := Color(0.9, 0.87, 0.78)
const MUTED := Color(0.62, 0.58, 0.5)
const BUFF_COLOR := "#72D572"
const DEBUFF_COLOR := "#F07878"
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")

var _portrait: TextureRect
var _name_label: Label
var _role_label: Label
var _tabs: TabContainer
var _object_description: RichTextLabel


func _ready() -> void:
	title = "Podgląd jednostki"
	exclusive = true
	min_size = Vector2i(920, 620)
	_build_ui()
	assert(_tabs.get_tab_count() == 3, "Podgląd jednostki musi mieć trzy zakładki.")
	assert(_portrait != null, "Podgląd jednostki musi zawsze zawierać portret.")
	assert(_resistance_text({"resistance": "Brak", "active_effects": [{"id": "mistrz_trucizn"}]}) == "Trucizna")


func show_unit(unit: Dictionary, skills: Dictionary, portrait: Texture2D) -> void:
	_name_label.text = str(unit.get("name", "JEDNOSTKA")).to_upper()
	_role_label.text = str(unit.get("role", ""))
	_portrait.texture = portrait
	_tabs.visible = true
	_object_description.visible = false
	_fill_general_tab(_tabs.get_child(0), unit)
	_fill_stats_tab(_tabs.get_child(1), unit)
	_fill_skills_tab(_tabs.get_child(2), unit, skills)
	_tabs.current_tab = 0
	popup_centered(Vector2i(920, 620))


func show_map_object(object_name: String, description: String, portrait: Texture2D) -> void:
	_name_label.text = object_name.to_upper()
	_role_label.text = "Element mapy"
	_portrait.texture = portrait
	_tabs.visible = false
	_object_description.text = _format_effects_bbcode(description)
	_object_description.visible = true
	popup_centered(Vector2i(760, 500))


func _build_ui() -> void:
	var panel := NinePatchRect.new()
	panel.texture = PANEL_TEXTURE
	panel.set_patch_margin(SIDE_LEFT, 18)
	panel.set_patch_margin(SIDE_TOP, 18)
	panel.set_patch_margin(SIDE_RIGHT, 18)
	panel.set_patch_margin(SIDE_BOTTOM, 18)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)
	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)
	_name_label = _label("", 26, GOLD)
	title_box.add_child(_name_label)
	_role_label = _label("", 15, MUTED)
	title_box.add_child(_role_label)
	var close_button := Button.new()
	close_button.text = "ZAMKNIJ  ×"
	close_button.pressed.connect(hide)
	header.add_child(close_button)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 22)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(310, 470)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	body.add_child(_portrait)

	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_tabs)
	_object_description = _rich_description("")
	_object_description.custom_minimum_size = Vector2(360, 0)
	_object_description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_object_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_object_description)
	for tab_name in ["OGÓLNE", "STATYSTYKI", "UMIEJĘTNOŚCI"]:
		var scroll := ScrollContainer.new()
		scroll.name = tab_name
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var tab_margin := MarginContainer.new()
		tab_margin.add_theme_constant_override("margin_left", 14)
		tab_margin.add_theme_constant_override("margin_top", 14)
		tab_margin.add_theme_constant_override("margin_right", 14)
		tab_margin.add_theme_constant_override("margin_bottom", 14)
		tab_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 14)
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_margin.add_child(content)
		scroll.add_child(tab_margin)
		_tabs.add_child(scroll)


func _fill_general_tab(scroll: ScrollContainer, unit: Dictionary) -> void:
	var content: VBoxContainer = scroll.get_child(0).get_child(0)
	_clear(content)
	content.add_child(_section("OPIS JEDNOSTKI"))
	var role: String = str(unit.get("role", "Jednostka bojowa"))
	content.add_child(_rich_description("%s. Walczy po stronie %s i dowodzi oddziałem liczącym obecnie %d wojowników." % [role, _side_name(str(unit.get("side", ""))), int(unit.get("count", 0))]))
	content.add_child(_section("INFORMACJE OGÓLNE"))
	_add_row(content, "Nazwa", str(unit.get("name", "-")))
	_add_row(content, "Rola", role)
	_add_row(content, "Strona", _side_name(str(unit.get("side", ""))))
	_add_row(content, "Odporność", _resistance_text(unit))


func _fill_stats_tab(scroll: ScrollContainer, unit: Dictionary) -> void:
	var content: VBoxContainer = scroll.get_child(0).get_child(0)
	_clear(content)
	content.add_child(_section("DOKŁADNE STATYSTYKI"))
	_add_row(content, "Punkty życia oddziału", "%d / %d" % [int(unit.get("current_total_hp", 0)), int(unit.get("max_total_hp", 0))])
	_add_row(content, "Punkty życia jednostki", "%d / %d" % [int(unit.get("current_hp", unit.get("hp", 0))), int(unit.get("max_hp", unit.get("hp", 0)))])
	_add_row(content, "Obrażenia", str(unit.get("dmg", 0)))
	_add_row(content, "Obrona", str(unit.get("def", 0)))
	_add_row(content, "Szybkość", str(unit.get("speed", 0)))
	_add_row(content, "Zasięg ruchu", str(unit.get("move_range", 0)))
	_add_row(content, "Zasięg ataku", str(unit.get("attack_range", 0)))
	_add_row(content, "Punkty akcji", str(unit.get("action_points", 0)))
	_add_row(content, "Liczebność", str(unit.get("count", 0)))
	content.add_child(_section("AKTYWNE BUFFY I DEBUFFY"))
	var effects: Array = unit.get("active_effects", [])
	if effects.is_empty():
		content.add_child(_label("Brak aktywnych efektów.", 14, MUTED))
	for effect in effects:
		var meta: Dictionary = UnitTypeLibraryScript.get_status_effect(str(effect.get("id", "")))
		var category: String = "BUFF" if str(effect.get("category", "")) == "buff" else "DEBUFF"
		var description: String = str(meta.get("description", effect.get("description", "")))
		_add_row(content, "%s: %s" % [category, str(meta.get("name", effect.get("name", "Efekt")))], "%s  •  pozostałe tury: %d" % [description, int(effect.get("remaining_turns", 0))])


func _fill_skills_tab(scroll: ScrollContainer, unit: Dictionary, skills: Dictionary) -> void:
	var content: VBoxContainer = scroll.get_child(0).get_child(0)
	_clear(content)
	content.add_child(_section("ATAK PODSTAWOWY"))
	content.add_child(_rich_description("Zadaje %d obrażeń jednemu celowi w zasięgu %d hexów. Zużywa 1 punkt akcji." % [int(unit.get("dmg", 0)), int(unit.get("attack_range", 1))]))
	for skill_id in unit.get("skill_ids", []):
		var skill: Dictionary = skills.get(str(skill_id), {})
		if skill.is_empty():
			continue
		content.add_child(_section(str(skill.get("name", skill_id)).to_upper()))
		content.add_child(_rich_description(str(skill.get("description", "Brak opisu."))))
		_add_row(content, "Koszt", "%d PA" % int(skill.get("ap_cost", 0)))
		_add_row(content, "Zasięg", "%d hex" % int(skill.get("range", 0)))
		_add_row(content, "Cooldown", "%d tur" % int(skill.get("cooldown", 0)))


func _add_row(parent: VBoxContainer, key: String, value: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var key_label := _label(key, 14, GOLD)
	key_label.custom_minimum_size.x = 175
	row.add_child(key_label)
	var value_label := _wrapped_label(value)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)
	parent.add_child(row)


func _section(text: String) -> Label:
	var label := _label(text, 17, GOLD)
	label.add_theme_constant_override("outline_size", 2)
	return label


func _wrapped_label(text: String) -> Label:
	var label := _label(text, 14, TEXT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _rich_description(text: String) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.add_theme_font_size_override("normal_font_size", 14)
	label.text = _format_effects_bbcode(text)
	return label


func _format_effects_bbcode(text: String) -> String:
	var result: String = text
	var replacements: Array[String] = []
	for effect in UnitTypeLibraryScript.get_status_effects().values():
		var effect_name: String = str(effect.get("name", ""))
		if effect_name == "":
			continue
		var regex := RegEx.new()
		regex.compile("(?i)\\b%s\\b" % effect_name)
		if regex.search(result) == null:
			continue
		var token: String = "@@STATUS_%d@@" % replacements.size()
		result = regex.sub(result, token, true)
		var category: String = "BUFF" if str(effect.get("category", "")) == "buff" else "DEBUFF"
		var color: String = BUFF_COLOR if category == "BUFF" else DEBUFF_COLOR
		var hint: String = "%s — %s" % [category, str(effect.get("description", "Brak opisu efektu."))]
		replacements.append("[hint=\"%s\"][color=%s][u]%s[/u][/color][/hint]" % [hint.replace("\"", "'"), color, effect_name])
	for index in replacements.size():
		result = result.replace("@@STATUS_%d@@" % index, replacements[index])
	return result


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _clear(parent: Control) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func _side_name(side: String) -> String:
	return "gracza" if side == "player" else "przeciwnika"


func _resistance_text(unit: Dictionary) -> String:
	var resistance: String = str(unit.get("resistance", "Brak"))
	var has_poison_immunity := false
	for effect in unit.get("active_effects", []):
		if str(effect.get("id", "")) == "mistrz_trucizn":
			has_poison_immunity = true
			break
	if not has_poison_immunity:
		has_poison_immunity = str(unit.get("resistance", "")).to_lower().contains("truciz")
	if has_poison_immunity:
		return "Trucizna" if resistance == "" or resistance == "Brak" else "%s, Trucizna" % resistance
	return resistance if resistance != "" else "Brak"
