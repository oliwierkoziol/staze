class_name TurnQueueCard

const CARD_SIZE := Vector2(128.0, 56.0)
const PORTRAIT_SIZE := Vector2(42.0, 50.0)
const SELECTED_FONT_COLOR := Color(0.99, 0.95, 0.84, 1.0)


static func create(unit: Dictionary, selected_unit_id: int, active_unit_id: int, disabled: bool, portrait_texture: Texture2D, fallback_portrait: Texture2D, pressed_callback: Callable, gui_input_callback: Callable) -> Button:
	var is_selected: bool = int(unit.id) == selected_unit_id
	var is_active: bool = int(unit.id) == active_unit_id
	var button := Button.new()
	button.text = ""
	button.custom_minimum_size = CARD_SIZE
	button.clip_contents = true
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _make_card_style(unit, is_selected, false, is_active))
	button.add_theme_stylebox_override("hover", _make_card_style(unit, is_selected, true, is_active))
	button.add_theme_stylebox_override("pressed", _make_card_style(unit, true, true, is_active))
	button.add_theme_stylebox_override("disabled", _make_card_style(unit, is_selected, false, is_active))
	button.pressed.connect(pressed_callback.bind(unit.id))
	button.gui_input.connect(gui_input_callback.bind(unit.id))

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 0)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)

	_add_portrait(row, unit, portrait_texture, fallback_portrait)
	_add_divider(row, unit, is_selected, is_active)
	_add_name(row, unit, is_selected)
	return button


static func _add_portrait(row: HBoxContainer, unit: Dictionary, portrait_texture: Texture2D, fallback_portrait: Texture2D) -> void:
	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size = PORTRAIT_SIZE
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_theme_stylebox_override("panel", _make_portrait_frame_style(unit))
	row.add_child(portrait_frame)

	var portrait := TextureRect.new()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = portrait_texture if portrait_texture != null else fallback_portrait
	portrait_frame.add_child(portrait)


static func _add_divider(row: HBoxContainer, unit: Dictionary, selected: bool, active: bool) -> void:
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(_border_width(), 0)
	divider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	divider.color = _border_color(unit, selected, active)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(divider)


static func _add_name(row: HBoxContainer, unit: Dictionary, selected: bool) -> void:
	var text_wrap := MarginContainer.new()
	text_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_wrap.add_theme_constant_override("margin_left", 6)
	text_wrap.add_theme_constant_override("margin_right", 2)
	text_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_wrap)

	var name_label := Label.new()
	name_label.text = str(unit.name)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.max_lines_visible = 2
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", SELECTED_FONT_COLOR if selected else Color(0.95, 0.93, 0.88, 1.0))
	text_wrap.add_child(name_label)


static func _border_color(unit: Dictionary, selected: bool, active: bool) -> Color:
	var player_border := Color(0.35, 0.65, 0.95, 0.95)
	var enemy_border := Color(0.92, 0.35, 0.30, 0.95)
	var selected_border := Color(0.90, 0.77, 0.34, 1.0)
	if selected:
		return selected_border
	return player_border if unit.side == "player" else enemy_border


static func _border_width() -> int:
	return 1


static func _make_card_style(unit: Dictionary, selected: bool, hovered := false, active := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var player_bg := Color(0.09, 0.16, 0.26, 0.96)
	var enemy_bg := Color(0.24, 0.10, 0.10, 0.96)
	var selected_bg := Color(0.23, 0.19, 0.08, 0.98)
	var active_player_bg := Color(0.12, 0.20, 0.32, 0.98)
	var active_enemy_bg := Color(0.30, 0.12, 0.12, 0.98)

	if selected:
		style.bg_color = selected_bg
	elif active:
		style.bg_color = active_player_bg if unit.side == "player" else active_enemy_bg
	else:
		style.bg_color = player_bg if unit.side == "player" else enemy_bg

	style.border_color = _border_color(unit, selected, active)
	if hovered and not selected:
		style.bg_color = style.bg_color.lightened(0.08)
		style.border_color = style.border_color.lightened(0.08)

	var border_width: int = _border_width()
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.shadow_size = 0
	style.shadow_offset = Vector2.ZERO
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	style.content_margin_left = 8.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	return style


static func _make_portrait_frame_style(unit: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var player_tint := Color(0.06, 0.10, 0.16, 0.92)
	var enemy_tint := Color(0.16, 0.06, 0.06, 0.92)
	style.bg_color = player_tint if unit.side == "player" else enemy_tint
	style.border_color = Color(0.0, 0.0, 0.0, 0.35)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = 2.0
	style.content_margin_top = 2.0
	style.content_margin_right = 2.0
	style.content_margin_bottom = 2.0
	return style
