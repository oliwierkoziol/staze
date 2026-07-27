extends Control

@onready var background: ColorRect = $Background
@onready var menu_panel: PanelContainer = $CenterContainer/MenuPanel
@onready var vbox: VBoxContainer = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer
@onready var title_label: Label = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/Title
@onready var subtitle_label: Label = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/Subtitle
@onready var continue_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/ContinueButton
@onready var continue_separator: HSeparator = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/ContinueSeparator
@onready var new_game_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/NewGameButton
@onready var skirmish_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/SkirmishButton
@onready var load_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/FileLoadButton
@onready var settings_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton
@onready var campaign_difficulty_label: Label = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/CampaignDifficultyLabel
@onready var campaign_difficulty: OptionButton = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/CampaignDifficulty
@onready var seed_toggle: CheckButton = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/SeedToggle
@onready var seed_input: LineEdit = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/SeedInput
@onready var debug_checkbox: CheckButton = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/DebugCheck
@onready var status_label: Label = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var build_info: Label = $BuildInfo

const DF_BG: Color = Color(0.04, 0.035, 0.025, 1.0)
const DF_BG_LIGHT: Color = Color(0.105, 0.065, 0.025, 0.98)
const DF_GOLD: Color = Color(0.65, 0.52, 0.2, 0.9)
const DF_GOLD_BRIGHT: Color = Color(0.88, 0.75, 0.34, 1.0)
const DF_GOLD_TEXT: Color = Color(0.86, 0.72, 0.34, 1.0)
const DF_TEXT: Color = Color(0.92, 0.88, 0.78, 1.0)
const PANEL_TEXTURE: Texture2D = preload("res://turn-base-game/assets/ui/panel.png")

var load_dialog: FileDialog
var overwrite_dialog: ConfirmationDialog
var settings_overlay: Control
var latest_save_seed: int = -1
var pending_new_seed: int = 0
var selected_campaign_difficulty := "sredni"


func _ready() -> void:
	_apply_emoji_fallback()
	_setup_connections()
	_setup_file_dialog()
	_setup_overwrite_dialog()
	_build_settings_overlay()
	_setup_campaign_difficulty()
	_apply_dark_fantasy_style()
	_refresh_continue_button()
	debug_checkbox.visible = OS.is_debug_build()
	debug_checkbox.button_pressed = GameSettings.debug_mode and OS.is_debug_build()
	quit_button.visible = not OS.has_feature("web")
	build_info.text = "WERSJA %s" % ProjectSettings.get_setting("application/config/version", "0.1.0")
	new_game_button.grab_focus()


func _setup_connections() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	skirmish_button.pressed.connect(_on_skirmish_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_open_settings)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	seed_toggle.toggled.connect(func(enabled: bool) -> void:
		seed_input.visible = enabled
		if enabled:
			seed_input.grab_focus()
	)
	debug_checkbox.toggled.connect(func(enabled: bool) -> void:
		GameSettings.debug_mode = enabled and OS.is_debug_build()
	)


func _setup_file_dialog() -> void:
	load_dialog = FileDialog.new()
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_dialog.filters = PackedStringArray(["*.json ; Zapis gry JSON"])
	load_dialog.file_selected.connect(_on_load_file_selected)
	add_child(load_dialog)
	SaveManager.external_load_finished.connect(_on_external_load_finished)


func _setup_overwrite_dialog() -> void:
	overwrite_dialog = ConfirmationDialog.new()
	overwrite_dialog.title = "Nadpisanie kampanii"
	overwrite_dialog.dialog_text = "Kampania z tym seedem już istnieje. Rozpoczęcie nowej gry usunie jej zapis."
	overwrite_dialog.ok_button_text = "USUŃ ZAPIS I ROZPOCZNIJ"
	overwrite_dialog.cancel_button_text = "ANULUJ"
	overwrite_dialog.confirmed.connect(func() -> void:
		SaveManager.delete_save(pending_new_seed)
		_start_new_campaign(pending_new_seed)
	)
	add_child(overwrite_dialog)


func _setup_campaign_difficulty() -> void:
	selected_campaign_difficulty = GameSettings.campaign_ai_difficulty
	for difficulty in [
		{"id": "latwy", "label": "ŁATWY — MNIEJ PRZEWIDUJĄCE AI"},
		{"id": "sredni", "label": "ŚREDNI — STANDARDOWE AI"},
		{"id": "trudny", "label": "TRUDNY — TAKTYCZNE AI"},
	]:
		campaign_difficulty.add_item(str(difficulty.label))
		campaign_difficulty.set_item_metadata(campaign_difficulty.item_count - 1, str(difficulty.id))
		if str(difficulty.id) == selected_campaign_difficulty:
			campaign_difficulty.select(campaign_difficulty.item_count - 1)
	campaign_difficulty.item_selected.connect(func(index: int) -> void:
		selected_campaign_difficulty = str(campaign_difficulty.get_item_metadata(index))
	)


func _build_settings_overlay() -> void:
	settings_overlay = Control.new()
	settings_overlay.visible = false
	settings_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(settings_overlay)

	var blocker := ColorRect.new()
	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocker.color = Color(0.02, 0.02, 0.04, 0.82)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_overlay.add_child(blocker)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 0)
	center.add_child(panel)
	panel.add_theme_stylebox_override("panel", _panel_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	var title := Label.new()
	title.text = "USTAWIENIA DŹWIĘKU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", DF_GOLD_TEXT)
	column.add_child(title)

	_add_volume_slider(column, "Głośność główna (wszystko)", &"Master")
	_add_volume_slider(column, "Efekty", &"Effects")
	_add_volume_slider(column, "Dialogi", &"Dialogue")
	_add_volume_slider(column, "Muzyka", &"Music")

	var close_button := Button.new()
	close_button.text = "WRÓĆ"
	close_button.custom_minimum_size = Vector2(0, 46)
	close_button.pressed.connect(_close_settings)
	_style_button(close_button, false)
	column.add_child(close_button)


func _add_volume_slider(parent: VBoxContainer, label_text: String, bus_name: StringName) -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 3)
	parent.add_child(group)

	var header := HBoxContainer.new()
	group.add_child(header)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", DF_TEXT)
	header.add_child(label)

	var value_label := Label.new()
	var current_value: float = GameSettings.get_audio_volume(bus_name)
	value_label.text = "%d%%" % int(current_value)
	value_label.custom_minimum_size = Vector2(56, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", DF_TEXT)
	header.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = current_value
	slider.custom_minimum_size = Vector2(0, 28)
	slider.value_changed.connect(func(value: float) -> void:
		value_label.text = "%d%%" % int(value)
		GameSettings.set_audio_volume(bus_name, value)
	)
	group.add_child(slider)


func _refresh_continue_button() -> void:
	latest_save_seed = _find_latest_save_seed()
	var has_continue := latest_save_seed != -1
	continue_button.visible = has_continue
	continue_separator.visible = has_continue
	if has_continue:
		continue_button.text = "KONTYNUUJ KAMPANIĘ  •  SEED %d" % latest_save_seed


func _find_latest_save_seed() -> int:
	var directory := DirAccess.open("user://saves")
	if directory == null:
		return -1
	var newest_seed := -1
	var newest_time := 0
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.begins_with("seed_") and file_name.ends_with(".json"):
			var seed_text := file_name.trim_prefix("seed_").trim_suffix(".json")
			if seed_text.is_valid_int():
				var modified := int(FileAccess.get_modified_time("user://saves/%s" % file_name))
				if newest_seed == -1 or modified > newest_time:
					newest_seed = seed_text.to_int()
					newest_time = modified
		file_name = directory.get_next()
	directory.list_dir_end()
	return newest_seed


func _on_continue_pressed() -> void:
	if latest_save_seed == -1 or not SaveManager.load_game(latest_save_seed):
		_show_status("Nie udało się wczytać ostatniej kampanii.", true)
		_refresh_continue_button()
		return
	SceneTransition.change_scene("res://scenes/game_world.tscn", "WCZYTYWANIE KAMPANII")


func _on_new_game_pressed() -> void:
	var seed_value: Variant = _new_campaign_seed()
	if seed_value == null:
		return
	pending_new_seed = int(seed_value)
	if SaveManager.has_save(pending_new_seed):
		overwrite_dialog.dialog_text = (
			"Kampania dla seeda %d już istnieje.\n"
			+ "Rozpoczęcie nowej gry bezpowrotnie usunie ten zapis."
		) % pending_new_seed
		overwrite_dialog.popup_centered(Vector2i(560, 230))
		return
	_start_new_campaign(pending_new_seed)


func _new_campaign_seed() -> Variant:
	if not seed_toggle.button_pressed:
		randomize()
		return randi()
	var text := seed_input.text.strip_edges()
	if text == "":
		_show_status("Wpisz seed świata albo wyłącz opcję „Własny seed”.", true)
		seed_input.grab_focus()
		return null
	return text.to_int() if text.is_valid_int() else text.hash()


func _start_new_campaign(seed_value: int) -> void:
	GameSettings.current_seed = seed_value
	GameSettings.use_custom_seed = true
	GameSettings.debug_mode = debug_checkbox.button_pressed and OS.is_debug_build()
	GameSettings.campaign_ai_difficulty = selected_campaign_difficulty
	EconomyManager.reset()
	SaveManager.pending_battle.clear()
	SceneTransition.change_scene("res://scenes/game_world.tscn", "TWORZENIE ŚWIATA")


func _on_skirmish_pressed() -> void:
	SaveManager.pending_battle.clear()
	SceneTransition.change_scene("res://turn-base-game/gra.tscn", "OTWIERANIE POTYCZKI")


func _on_load_pressed() -> void:
	if OS.has_feature("web"):
		SaveManager.open_web_load_dialog()
	else:
		load_dialog.popup_centered(Vector2i(900, 600))


func _on_load_file_selected(path: String) -> void:
	_finish_external_load(SaveManager.import_game(path), SaveManager.last_error)


func _on_external_load_finished(success: bool, message: String) -> void:
	_finish_external_load(success, message)


func _finish_external_load(success: bool, message: String) -> void:
	if success:
		SceneTransition.change_scene("res://scenes/game_world.tscn", "WCZYTYWANIE KAMPANII")
		return
	_show_status(message if message != "" else "Nie udało się wczytać zapisu.", true)


func _open_settings() -> void:
	settings_overlay.visible = true
	var sliders := settings_overlay.find_children("*", "HSlider", true, false)
	if not sliders.is_empty():
		(sliders[0] as HSlider).grab_focus()


func _close_settings() -> void:
	settings_overlay.visible = false
	settings_button.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if settings_overlay.visible:
			_close_settings()
			get_viewport().set_input_as_handled()


func _show_status(text: String, is_error: bool) -> void:
	status_label.text = text
	status_label.visible = true
	status_label.add_theme_color_override("font_color", Color(0.95, 0.38, 0.32) if is_error else DF_GOLD_TEXT)


func _apply_emoji_fallback() -> void:
	var ui_font := GameSettings.get_ui_font()
	if ui_font == null:
		return
	if theme == null:
		theme = Theme.new()
	theme.default_font = ui_font


func _apply_dark_fantasy_style() -> void:
	background.color = DF_BG
	menu_panel.add_theme_stylebox_override("panel", _panel_style())
	title_label.add_theme_color_override("font_color", DF_GOLD_TEXT)
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	subtitle_label.add_theme_color_override("font_color", Color(DF_TEXT.r, DF_TEXT.g, DF_TEXT.b, 0.72))
	build_info.add_theme_color_override("font_color", Color(DF_TEXT.r, DF_TEXT.g, DF_TEXT.b, 0.55))
	campaign_difficulty_label.add_theme_color_override("font_color", DF_GOLD_TEXT)
	seed_toggle.add_theme_color_override("font_color", DF_TEXT)
	debug_checkbox.add_theme_color_override("font_color", DF_TEXT)
	status_label.add_theme_color_override("font_color", DF_GOLD_TEXT)

	var input_style := StyleBoxFlat.new()
	input_style.bg_color = DF_BG_LIGHT
	input_style.set_border_width_all(2)
	input_style.border_color = DF_GOLD
	input_style.set_corner_radius_all(6)
	input_style.set_content_margin_all(8)
	var input_focus := input_style.duplicate() as StyleBoxFlat
	input_focus.border_color = DF_GOLD_BRIGHT
	seed_input.add_theme_stylebox_override("normal", input_style)
	seed_input.add_theme_stylebox_override("focus", input_focus)
	seed_input.add_theme_color_override("font_color", DF_TEXT)
	seed_input.add_theme_color_override("font_placeholder_color", Color(DF_TEXT.r, DF_TEXT.g, DF_TEXT.b, 0.45))

	_style_button(continue_button, true)
	_style_button(new_game_button, true)
	_style_button(skirmish_button, false)
	_style_button(load_button, false)
	_style_button(settings_button, false)
	_style_button(quit_button, false)
	_style_button(campaign_difficulty, false)


func _panel_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = PANEL_TEXTURE
	style.texture_margin_left = 8
	style.texture_margin_top = 8
	style.texture_margin_right = 8
	style.texture_margin_bottom = 8
	style.axis_stretch_horizontal = 2
	style.axis_stretch_vertical = 2
	return style


func _style_button(button: Button, _accent: bool) -> void:
	# domyślny chrome Godota + Georgia/krem
	button.custom_minimum_size = Vector2(0, 48)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.remove_theme_stylebox_override(state)
	button.remove_theme_color_override("font_hover_color")
	button.add_theme_color_override("font_color", DF_TEXT)
	button.add_theme_font_size_override("font_size", 20)
