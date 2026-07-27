class_name TempleMenu
extends RefCounted

var hud: Control
var temple_window: PanelContainer
var status_label: Label
var desc_label: Label
var activate_button: Button

func _init(_hud: Control):
	hud = _hud

func setup_temple_window():
	temple_window = PanelContainer.new()
	temple_window.visible = false
	temple_window.custom_minimum_size = Vector2(420, 0)

	temple_window.add_theme_stylebox_override("panel", hud._panel_style(20))

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	temple_window.add_child(main_vbox)

	# HEADER
	var header_hbox = HBoxContainer.new()
	var title_label = Label.new()
	title_label.text = "⛩️ Świątynia — Błogosławieństwo"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.tooltip_text = "Zamknij"
	close_btn.custom_minimum_size = Vector2(30, 30)
	close_btn.pressed.connect(func(): temple_window.visible = false)
	hud._style_df_button(close_btn)
	header_hbox.add_child(title_label)
	header_hbox.add_child(close_btn)
	main_vbox.add_child(header_hbox)

	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", hud.DF_GOLD)
	main_vbox.add_child(sep)

	# OPIS
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size = Vector2(370, 0)
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", hud.DF_TEXT)
	main_vbox.add_child(desc_label)

	# STATUS
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	status_label.custom_minimum_size = Vector2(370, 0)
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(status_label)

	# PRZYCISK AKTYWACJI
	activate_button = Button.new()
	activate_button.text = "🙏 Aktywuj Błogosławieństwo"
	activate_button.custom_minimum_size = Vector2(0, 46)
	hud._style_df_button(activate_button)
	activate_button.pressed.connect(_on_activate_pressed)
	main_vbox.add_child(activate_button)

	hud.add_child(temple_window)

func _on_activate_pressed() -> void:
	if EconomyManager.activate_temple_blessing():
		if AudioManager: AudioManager.play_temple()
		_refresh_status()

# Aktualny bonus (%) zależy od poziomu najlepiej rozwiniętej Świątyni gracza —
# im wyższy poziom, tym silniejsze błogosławieństwo (patrz
# EconomyManager.get_temple_blessing_bonus_percent).
func _get_current_bonus_percent() -> int:
	if hud.world_ref and hud.world_ref.has_method("get_active_buildings_list"):
		return EconomyManager.get_temple_blessing_bonus_percent(hud.world_ref.get_active_buildings_list())
	return 10

func _refresh_status() -> void:
	var bonus_percent = _get_current_bonus_percent()

	desc_label.text = "Aktywuj błogosławieństwo, aby zwiększyć produkcję wszystkich surowców o %d%% przez %d tur.\nOdnowienie (cooldown): %d tur od aktywacji.\nUlepszanie Świątyni zwiększa siłę błogosławieństwa (+10%% za poziom)." % [bonus_percent, EconomyManager.TEMPLE_BLESSING_DURATION, EconomyManager.TEMPLE_BLESSING_COOLDOWN]

	if EconomyManager.temple_blessing_turns_left > 0:
		status_label.text = "✅ Błogosławieństwo aktywne (+%d%%) jeszcze przez %d tur." % [bonus_percent, EconomyManager.temple_blessing_turns_left]
		status_label.add_theme_color_override("font_color", Color(0.55, 0.85, 0.55))
	elif EconomyManager.temple_blessing_cooldown_left > 0:
		status_label.text = "⏳ Odnowienie za %d tur." % EconomyManager.temple_blessing_cooldown_left
		status_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.4))
	else:
		status_label.text = "Błogosławieństwo gotowe do aktywacji (+%d%%)." % bonus_percent
		status_label.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)

	activate_button.disabled = not EconomyManager.can_activate_temple_blessing()
	activate_button.modulate.a = 1.0 if not activate_button.disabled else 0.5

func show_temple_menu() -> void:
	temple_window.visible = true
	var viewport_size = hud.get_viewport_rect().size
	temple_window.reset_size()
	_refresh_status()
	temple_window.reset_size()
	temple_window.position = ((viewport_size - temple_window.size) / 2.0).round()
