class_name WorkshopMenu
extends RefCounted

var hud: Control
var workshop_window: PanelContainer
var status_label: Label
var heal_button: Button
var _current_tile_pos: Vector2 = Vector2.ZERO

func _init(_hud: Control):
	hud = _hud

func setup_workshop_window():
	workshop_window = PanelContainer.new()
	workshop_window.visible = false
	workshop_window.custom_minimum_size = Vector2(420, 0)

	workshop_window.add_theme_stylebox_override("panel", hud._panel_style(20))

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	workshop_window.add_child(main_vbox)

	# HEADER
	var header_hbox = HBoxContainer.new()
	var title_label = Label.new()
	title_label.text = "🔧 Warsztat — Uzdrawianie"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.tooltip_text = "Zamknij"
	close_btn.custom_minimum_size = Vector2(30, 30)
	close_btn.pressed.connect(func(): workshop_window.visible = false)
	hud._style_df_button(close_btn)
	header_hbox.add_child(title_label)
	header_hbox.add_child(close_btn)
	main_vbox.add_child(header_hbox)

	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", hud.DF_GOLD)
	main_vbox.add_child(sep)

	# OPIS
	var desc_label = Label.new()
	desc_label.text = "Warsztat może uleczyć Twoją armię, jeśli generał wraz z oddziałem stoi dokładnie na tym polu."
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", hud.DF_TEXT)
	main_vbox.add_child(desc_label)

	# STATUS
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", hud.DF_GOLD_TEXT)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(status_label)

	# PRZYCISK LECZENIA
	heal_button = Button.new()
	heal_button.text = "✚ Lecz jednostki"
	heal_button.custom_minimum_size = Vector2(0, 46)
	hud._style_df_button(heal_button)
	heal_button.pressed.connect(_on_heal_pressed)
	main_vbox.add_child(heal_button)

	hud.add_child(workshop_window)

func _general_with_army_on_tile() -> bool:
	if not hud.world_ref or not hud.world_ref.get("character"):
		return false
	var gen = hud.world_ref.character
	if not gen or not gen.has_method("has_army") or not gen.has_army():
		return false
	var gen_tile = hud.world_ref.world_to_nearest_cell(gen.global_position)
	return gen_tile == _current_tile_pos

func _on_heal_pressed() -> void:
	if not _general_with_army_on_tile() or not _has_wounded_units():
		return
	EconomyManager.heal_army_units()
	if AudioManager: AudioManager.play_heal()
	_refresh_status()

func _refresh_status() -> void:
	var general_present := _general_with_army_on_tile()
	var has_wounded := _has_wounded_units()
	var can_heal := general_present and has_wounded
	if can_heal:
		status_label.text = "✅ Generał z armią stoi na tym polu — możesz leczyć jednostki."
		status_label.add_theme_color_override("font_color", Color(0.55, 0.85, 0.55))
	elif general_present:
		status_label.text = "Armia nie ma rannych jednostek."
		status_label.add_theme_color_override("font_color", Color(0.75, 0.72, 0.62))
	else:
		status_label.text = "⚠️ Aby leczyć, generał z przypisaną armią musi stać dokładnie na tym polu."
		status_label.add_theme_color_override("font_color", Color(0.85, 0.55, 0.4))

	heal_button.disabled = not can_heal
	heal_button.modulate.a = 1.0 if can_heal else 0.5


func _has_wounded_units() -> bool:
	for unit in EconomyManager.player_army:
		if int(unit.get("current_hp", unit.get("hp", 0))) < int(unit.get("hp", 0)):
			return true
	return false

func show_workshop_menu(tile_pos: Vector2) -> void:
	_current_tile_pos = tile_pos
	workshop_window.visible = true
	var viewport_size = hud.get_viewport_rect().size
	workshop_window.reset_size()
	_refresh_status()
	workshop_window.position = ((viewport_size - workshop_window.size) / 2.0).round()
