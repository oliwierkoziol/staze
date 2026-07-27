extends CanvasLayer

signal resume_requested
signal save_requested
signal load_requested
signal restart_requested
signal mode_menu_requested
signal settings_requested
signal settings_close_requested
signal retreat_requested

var _resume_button: Button
var _save_button: Button
var _load_button: Button
var _restart_button: Button
var _mode_menu_button: Button
var _retreat_button: Button
var _action_confirmation: ConfirmationDialog
var _pending_action := ""
var settings_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 2
	visible = false
	_build_ui()


func _build_ui() -> void:
	var blocker := ColorRect.new()
	blocker.name = "PauseBlocker"
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.color = Color(0.02, 0.02, 0.04, 0.78)
	add_child(blocker)

	var panel := NinePatchRect.new()
	panel.name = "PausePanel"
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.custom_minimum_size = Vector2(360, 0)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -180
	panel.offset_top = -250
	panel.offset_right = 180
	panel.offset_bottom = 250
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.texture = preload("res://turn-base-game/assets/ui/panel.png")
	panel.patch_margin_left = 8
	panel.patch_margin_top = 8
	panel.patch_margin_right = 8
	panel.patch_margin_bottom = 8
	panel.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	panel.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	var title := Label.new()
	title.text = "MENU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.86, 0.72, 0.34, 1.0))
	column.add_child(title)

	var divider := TextureRect.new()
	divider.texture = preload("res://turn-base-game/assets/ui/divider.png")
	divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	divider.stretch_mode = TextureRect.STRETCH_SCALE
	divider.custom_minimum_size = Vector2(0, 2)
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(divider)

	_resume_button = _make_button("WZNÓW WALKĘ")
	_resume_button.pressed.connect(func() -> void: resume_requested.emit())
	column.add_child(_resume_button)

	_restart_button = _make_button("RESETUJ WALKĘ")
	_restart_button.pressed.connect(_request_action.bind("restart"))
	column.add_child(_restart_button)

	_retreat_button = _make_button("WYCOFAJ SIĘ")
	_retreat_button.pressed.connect(_request_action.bind("retreat"))
	column.add_child(_retreat_button)

	var settings_button := _make_button("USTAWIENIA")
	settings_button.pressed.connect(func() -> void: settings_requested.emit())
	column.add_child(settings_button)

	_save_button = _make_button("ZAPISZ STAN")
	_save_button.pressed.connect(func() -> void: save_requested.emit())
	column.add_child(_save_button)

	_load_button = _make_button("WCZYTAJ STAN")
	_load_button.pressed.connect(func() -> void: load_requested.emit())
	column.add_child(_load_button)

	_mode_menu_button = _make_button("WRÓĆ DO MENU")
	_mode_menu_button.pressed.connect(_request_action.bind("mode_menu"))
	column.add_child(_mode_menu_button)

	_action_confirmation = ConfirmationDialog.new()
	_action_confirmation.cancel_button_text = "WRÓĆ"
	_action_confirmation.confirmed.connect(_confirm_action)
	add_child(_action_confirmation)
	set_campaign_mode(false)

func _make_button(text: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = text
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78, 1.0))
	return button


func _request_action(action: String) -> void:
	_pending_action = action
	match action:
		"restart":
			_action_confirmation.title = "Reset walki"
			_action_confirmation.dialog_text = "Zresetować bieżącą walkę? Scenariusz i armie zostaną zachowane."
			_action_confirmation.ok_button_text = "RESETUJ WALKĘ"
		"mode_menu":
			_action_confirmation.title = "Powrót do menu"
			_action_confirmation.dialog_text = "Bieżąca walka zostanie utracona. Kontynuować?"
			_action_confirmation.ok_button_text = "WRÓĆ DO MENU"
		"retreat":
			_action_confirmation.title = "Wycofanie z walki"
			_action_confirmation.dialog_text = (
				"Wycofanie zachowa straty z bitwy, usunie dodatkowo 20% ocalałych "
				+ "i zakończy ruch generała. Kontynuować?"
			)
			_action_confirmation.ok_button_text = "WYCOFAJ SIĘ"
	_action_confirmation.popup_centered(Vector2i(520, 220))


func _confirm_action() -> void:
	match _pending_action:
		"restart":
			restart_requested.emit()
		"mode_menu":
			mode_menu_requested.emit()
		"retreat":
			retreat_requested.emit()
	_pending_action = ""


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ESCAPE:
		if settings_open:
			settings_close_requested.emit()
		else:
			resume_requested.emit()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible and _resume_button != null:
		_resume_button.grab_focus()


func close_menu() -> void:
	visible = false
	get_tree().paused = false


func set_campaign_mode(enabled: bool) -> void:
	if _save_button != null:
		_save_button.visible = not enabled
	if _load_button != null:
		_load_button.visible = not enabled
	if _restart_button != null:
		_restart_button.visible = not enabled
	if _mode_menu_button != null:
		_mode_menu_button.visible = not enabled
	if _retreat_button != null:
		_retreat_button.visible = enabled
