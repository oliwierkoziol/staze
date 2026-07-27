class_name SettingsMenu
extends RefCounted

var hud: Control
var settings_window: PanelContainer
var settings_seed_value_label: Label
var settings_copy_button: Button
var save_button: Button
var load_button: Button
var save_dialog: FileDialog
var load_dialog: FileDialog
var reset_confirmation: ConfirmationDialog

func _init(_hud: Control):
	hud = _hud

func setup_settings_window():
	settings_window = PanelContainer.new()
	settings_window.visible = false
	settings_window.custom_minimum_size = Vector2(480, 0)

	settings_window.add_theme_stylebox_override("panel", hud._panel_style(20))
	_setup_file_dialogs()
	SaveManager.external_load_finished.connect(_on_external_load_finished)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 16)
	settings_window.add_child(main_vbox)

	# HEADER
	var header_hbox = HBoxContainer.new()
	var title_label = Label.new()
	title_label.text = "⚙️ Menu gry"
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.tooltip_text = "Zamknij"
	close_btn.custom_minimum_size = Vector2(30, 30)
	close_btn.pressed.connect(func():
		settings_window.visible = false
		if AudioManager: AudioManager.resume_bg_music()
	)
	hud._style_df_button(close_btn)
	header_hbox.add_child(title_label)
	header_hbox.add_child(close_btn)
	main_vbox.add_child(header_hbox)

	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("separator", hud.DF_GOLD)
	main_vbox.add_child(sep1)

	# SEED SECTION
	var seed_section = VBoxContainer.new()
	seed_section.add_theme_constant_override("separation", 8)
	var seed_title = Label.new()
	seed_title.text = "Seed świata"
	seed_title.add_theme_font_size_override("font_size", 16)
	seed_title.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	seed_section.add_child(seed_title)

	var seed_row = HBoxContainer.new()
	seed_row.add_theme_constant_override("separation", 10)
	settings_seed_value_label = Label.new()
	settings_seed_value_label.add_theme_font_size_override("font_size", 14)
	settings_seed_value_label.add_theme_color_override("font_color", hud.DF_TEXT)
	settings_seed_value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_seed_value_label.clip_text = true

	settings_copy_button = Button.new()
	settings_copy_button.text = "📋 Kopiuj seed"
	settings_copy_button.custom_minimum_size = Vector2(140, 36)
	hud._style_df_button(settings_copy_button)
	settings_copy_button.pressed.connect(_on_copy_seed_pressed)

	seed_row.add_child(settings_seed_value_label)
	seed_row.add_child(settings_copy_button)
	seed_section.add_child(seed_row)
	main_vbox.add_child(seed_section)

	var sep2 = HSeparator.new()
	sep2.add_theme_color_override("separator", hud.DF_GOLD)
	main_vbox.add_child(sep2)

	# DŹWIĘK SECTION
	var sound_section = VBoxContainer.new()
	sound_section.add_theme_constant_override("separation", 8)
	var sound_title = Label.new()
	sound_title.text = "Głośność"
	sound_title.add_theme_font_size_override("font_size", 16)
	sound_title.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	sound_section.add_child(sound_title)

	_add_volume_slider(sound_section, "Głośność główna (wszystko)", &"Master")
	_add_volume_slider(sound_section, "Efekty", &"Effects")
	_add_volume_slider(sound_section, "Dialogi", &"Dialogue")
	_add_volume_slider(sound_section, "Muzyka", &"Music")
	main_vbox.add_child(sound_section)

	var sep3 = HSeparator.new()
	sep3.add_theme_color_override("separator", hud.DF_GOLD)
	main_vbox.add_child(sep3)

	# ACTION BUTTONS
	var resume_btn = Button.new()
	resume_btn.text = "▶️ Wróć do gry"
	resume_btn.custom_minimum_size = Vector2(0, 42)
	hud._style_df_button(resume_btn)
	resume_btn.pressed.connect(func():
		settings_window.visible = false
		if AudioManager: AudioManager.resume_bg_music()
	)
	main_vbox.add_child(resume_btn)

	save_button = Button.new()
	save_button.text = "Zapis"
	save_button.custom_minimum_size = Vector2(0, 42)
	hud._style_df_button(save_button)
	save_button.pressed.connect(_on_save_game_pressed)
	main_vbox.add_child(save_button)

	load_button = Button.new()
	load_button.text = "Wczytaj"
	load_button.custom_minimum_size = Vector2(0, 42)
	hud._style_df_button(load_button)
	load_button.pressed.connect(_on_load_game_pressed)
	main_vbox.add_child(load_button)

	var reset_btn = Button.new()
	reset_btn.text = "🔄 Zresetuj Grę (Ten sam seed)"
	reset_btn.custom_minimum_size = Vector2(0, 42)
	hud._style_df_button(reset_btn)
	reset_btn.pressed.connect(func() -> void: reset_confirmation.popup_centered(Vector2i(560, 230)))
	main_vbox.add_child(reset_btn)

	reset_confirmation = ConfirmationDialog.new()
	reset_confirmation.title = "Reset kampanii"
	reset_confirmation.dialog_text = "Usunąć bieżący zapis i rozpocząć tę kampanię od początku z tym samym seedem?"
	reset_confirmation.ok_button_text = "USUŃ ZAPIS I ZRESETUJ"
	reset_confirmation.cancel_button_text = "ANULUJ"
	reset_confirmation.confirmed.connect(_reset_campaign)
	if hud.has_method("_style_alert_dialog"):
		hud._style_alert_dialog(reset_confirmation)
	hud.add_child(reset_confirmation)

	var menu_btn = Button.new()
	menu_btn.text = "🏠 Wróć do menu głównego"
	menu_btn.custom_minimum_size = Vector2(0, 42)
	hud._style_df_button(menu_btn)
	menu_btn.pressed.connect(func():
		if AudioManager: AudioManager.stop_bg_music()
		SceneTransition.change_scene("res://ui/main_menu.tscn", "POWRÓT DO MENU")
	)
	main_vbox.add_child(menu_btn)

	var quit_btn = Button.new()
	quit_btn.text = "❌ Wyjdź z gry"
	quit_btn.custom_minimum_size = Vector2(0, 42)
	var quit_style = StyleBoxFlat.new()
	quit_style.bg_color = hud.DF_BLOOD
	quit_style.set_corner_radius_all(6)
	quit_style.set_border_width_all(1)
	quit_style.border_color = hud.DF_GOLD
	quit_style.set_content_margin_all(8)
	var quit_hover = quit_style.duplicate() as StyleBoxFlat
	quit_hover.bg_color = hud.DF_BLOOD_BRIGHT
	quit_btn.add_theme_stylebox_override("normal", quit_style)
	quit_btn.add_theme_stylebox_override("hover", quit_hover)
	quit_btn.add_theme_color_override("font_color", hud.DF_TEXT)
	quit_btn.pressed.connect(func(): hud.get_tree().quit())
	quit_btn.visible = not OS.has_feature("web")
	main_vbox.add_child(quit_btn)

	hud.add_child(settings_window)


func _reset_campaign() -> void:
	SaveManager.delete_save(GameSettings.current_seed)
	EconomyManager.reset()
	SceneTransition.change_scene("res://scenes/game_world.tscn", "TWORZENIE ŚWIATA")

func _setup_file_dialogs() -> void:
	save_dialog = FileDialog.new()
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.filters = PackedStringArray(["*.json ; Zapis gry JSON"])
	save_dialog.file_selected.connect(_on_save_file_selected)
	hud.add_child(save_dialog)
	load_dialog = FileDialog.new()
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_dialog.filters = PackedStringArray(["*.json ; Zapis gry JSON"])
	load_dialog.file_selected.connect(_on_load_file_selected)
	hud.add_child(load_dialog)

func _on_save_game_pressed() -> void:
	if OS.has_feature("web"):
		_show_file_result(
			save_button,
			SaveManager.export_game("", GameSettings.current_seed, hud.world_ref),
			"Zapis pobrany",
			"Zapis nieudany",
			"Zapis"
		)
		return
	save_dialog.current_file = "zapis_gry_%s.json" % GameSettings.current_seed
	save_dialog.popup_centered(Vector2i(900, 600))

func _on_save_file_selected(path: String) -> void:
	_show_file_result(
		save_button,
		SaveManager.export_game(path, GameSettings.current_seed, hud.world_ref),
		"Zapisano",
		"Zapis nieudany",
		"Zapis"
	)

func _on_load_game_pressed() -> void:
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
		settings_window.visible = false
		SceneTransition.change_scene("res://scenes/game_world.tscn", "WCZYTYWANIE KAMPANII")
		return
	_show_file_result(
		load_button,
		false,
		"",
		message if message != "" else "Wczytanie nieudane",
		"Wczytaj"
	)

func _show_file_result(button: Button, success: bool, success_text: String, error_text: String, default_text: String) -> void:
	button.text = success_text if success else error_text
	hud.get_tree().create_timer(1.8).timeout.connect(func() -> void:
		if is_instance_valid(button):
			button.text = default_text
	)

func _add_volume_slider(parent: VBoxContainer, label_text: String, bus_name: StringName) -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 2)
	parent.add_child(group)

	var header := HBoxContainer.new()
	group.add_child(header)

	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", hud.DF_TEXT)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(label)

	var value_label := Label.new()
	var current_value: float = GameSettings.get_audio_volume(bus_name)
	value_label.text = "%d%%" % int(current_value)
	value_label.custom_minimum_size = Vector2(52, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = current_value
	slider.custom_minimum_size = Vector2(0, 24)
	slider.value_changed.connect(func(value: float) -> void:
		value_label.text = "%d%%" % int(value)
		GameSettings.set_audio_volume(bus_name, value)
	)
	group.add_child(slider)

func _on_copy_seed_pressed() -> void:
	var seed_str = str(GameSettings.current_seed) if GameSettings.use_custom_seed else "Losowy"
	DisplayServer.clipboard_set(seed_str)
	settings_copy_button.text = "✅ Skopiowano!"
	hud.get_tree().create_timer(1.2).timeout.connect(func():
		if is_instance_valid(settings_copy_button):
			settings_copy_button.text = "📋 Kopiuj seed"
	)

func show_settings_menu():
	if settings_seed_value_label:
		if GameSettings.use_custom_seed:
			settings_seed_value_label.text = "Seed: " + str(GameSettings.current_seed)
		else:
			settings_seed_value_label.text = "Seed: Losowy"
	settings_window.visible = true
	var viewport_size = hud.get_viewport_rect().size
	settings_window.reset_size()
	settings_window.position = ((viewport_size - settings_window.size) / 2.0).round()
