class_name CultureTreeMenu
extends RefCounted

var hud: Control
var culture_tree_button: Button
var culture_tree_window: Panel
var culture_tree_map: Control
var insufficient_points_dialog: AcceptDialog
var tree_status_label: Label

const X_SPACING: float = 300.0
const Y_SPACING: float = 125.0
const OFFSET_POS: Vector2 = Vector2(80, 30)

func _init(_hud: Control):
	hud = _hud

func setup_culture_tree_ui():
	culture_tree_window = hud.get_node("CultureTreeWindow")
	culture_tree_map = hud.get_node("CultureTreeWindow/ScrollContainer/CultureTreeMap")

	if culture_tree_window:
		culture_tree_window.visible = false
		culture_tree_window.z_index = 10
		culture_tree_window.anchor_left = 0.05
		culture_tree_window.anchor_top = 0.08
		culture_tree_window.anchor_right = 0.95
		culture_tree_window.anchor_bottom = 0.92
		culture_tree_window.offset_left = 0
		culture_tree_window.offset_top = 0
		culture_tree_window.offset_right = 0
		culture_tree_window.offset_bottom = 0
		culture_tree_window.add_theme_stylebox_override("panel", hud._panel_style())
		var close_btn = culture_tree_window.get_node_or_null("CloseButton")
		if close_btn:
			close_btn.pressed.connect(func(): culture_tree_window.visible = false)
			close_btn.text = "X"
			close_btn.tooltip_text = "Zamknij"
			close_btn.custom_minimum_size = Vector2(40, 40)
			close_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			close_btn.offset_left = -50
			close_btn.offset_top = 10
			close_btn.offset_right = -10
			close_btn.offset_bottom = 50
			if hud.has_method("_style_df_button"):
				hud._style_df_button(close_btn)
			
			# Przesunięcie na koniec drzewa, by ScrollContainer nie blokował kliknięć
			close_btn.get_parent().move_child(close_btn, -1)
		var scroll = culture_tree_window.get_node_or_null("ScrollContainer")
		if scroll:
			scroll.offset_left = 14
			scroll.offset_top = 58
			scroll.offset_right = -14
			scroll.offset_bottom = -14
			hud.bind_tree_panning(scroll, culture_tree_map)
		tree_status_label = Label.new()
		tree_status_label.anchor_right = 1.0
		tree_status_label.offset_left = 22
		tree_status_label.offset_top = 14
		tree_status_label.offset_right = -60
		tree_status_label.offset_bottom = 44
		tree_status_label.add_theme_font_size_override("font_size", 13)
		tree_status_label.add_theme_color_override("font_color", hud.DF_TEXT)
		tree_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		culture_tree_window.add_child(tree_status_label)

	if culture_tree_map:
		culture_tree_map.draw.connect(_draw_culture_connections)

	# Dialog pokazywany, gdy kliknięcie węzła kultury nie mogło rozpocząć
	# badania (np. za mało punktów Kultury) — wcześniej takie kliknięcie
	# nie dawało żadnej reakcji, co wyglądało jak zepsuty przycisk.
	insufficient_points_dialog = AcceptDialog.new()
	insufficient_points_dialog.title = "Za mało punktów"
	insufficient_points_dialog.dialog_text = "Nie masz wystarczającej liczby punktów Kultury, aby rozpocząć to badanie."
	insufficient_points_dialog.ok_button_text = "Zrozumiałem"
	if hud.has_method("_style_alert_dialog"):
		hud._style_alert_dialog(insufficient_points_dialog)
	hud.add_child(insufficient_points_dialog)

	# Zamiast nadpisywać przycisk, używamy tego z hud.culture_tree_button
	# culture_tree_button = hud.culture_tree_button
	if hud.culture_tree_button:
		hud.culture_tree_button.pressed.connect(func():
			hud.hide_all_menus()
			if culture_tree_window:
				culture_tree_window.move_to_front()
				culture_tree_window.visible = true
				refresh_culture_tree_view()
		)

func _get_tech_node_position(grid_coords: Vector2) -> Vector2:
	return Vector2(
		grid_coords.x * X_SPACING + OFFSET_POS.x,
		grid_coords.y * Y_SPACING + OFFSET_POS.y
	)

func _draw_culture_connections():
	for tech_name in EconomyManager.culture_tree:
		var tech = EconomyManager.culture_tree[tech_name]
		var start_pos = _get_tech_node_position(tech["grid_coords"]) + Vector2(235, 55)
		for req_name in tech["req"]:
			if EconomyManager.culture_tree.has(req_name):
				var req_tech = EconomyManager.culture_tree[req_name]
				var end_pos = _get_tech_node_position(req_tech["grid_coords"]) + Vector2(0, 55)
				var line_color = Color(0.25, 0.22, 0.18, 1.0)
				var line_width = 2.5
				if req_tech["unlocked"] and tech["unlocked"]:
					line_color = Color(0.75, 0.35, 1.0, 0.9)
					line_width = 3.5
				elif req_tech["unlocked"] and EconomyManager.current_culture_research == tech_name:
					line_color = Color(0.85, 0.45, 1.0, 0.8)
				var mid_x = start_pos.x + (end_pos.x - start_pos.x) / 2.0
				culture_tree_map.draw_line(start_pos, Vector2(mid_x, start_pos.y), line_color, line_width)
				culture_tree_map.draw_line(Vector2(mid_x, start_pos.y), Vector2(mid_x, end_pos.y), line_color, line_width)
				culture_tree_map.draw_line(Vector2(mid_x, end_pos.y), end_pos, line_color, line_width)

func refresh_culture_tree_view():
	if not culture_tree_map: return
	if tree_status_label:
		tree_status_label.text = (
			"DRZEWO KULTURY  •  rozwój: %s  •  pozostało %d tur" % [EconomyManager.current_culture_research, EconomyManager.culture_turns_left]
			if EconomyManager.current_culture_research != ""
			else "DRZEWO KULTURY  •  fioletowy: odkryty  •  złoty: w trakcie  •  jasny: dostępny  •  przygaszony: zablokowany"
		)
	for child in culture_tree_map.get_children(): child.queue_free()
	culture_tree_map.queue_redraw()
	var max_size := Vector2.ZERO
	for tech_name in EconomyManager.culture_tree:
		var tech = EconomyManager.culture_tree[tech_name]
		var node_pos = _get_tech_node_position(tech["grid_coords"])
		var node_end = node_pos + Vector2(300, 150)
		max_size.x = max(max_size.x, node_end.x)
		max_size.y = max(max_size.y, node_end.y)
		var node_panel = PanelContainer.new()
		node_panel.position = node_pos
		node_panel.custom_minimum_size = Vector2(235, 110)
		var node_style = StyleBoxFlat.new()
		node_style.bg_color = Color(0.18, 0.16, 0.14)
		node_style.set_corner_radius_all(32)  
		node_style.set_border_width_all(2)
		node_style.border_color = Color(0.45, 0.25, 0.70)
		node_style.set_content_margin_all(6)
		node_panel.add_theme_stylebox_override("panel", node_style)
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		node_panel.add_child(hbox)
		var icon_panel = PanelContainer.new()
		icon_panel.custom_minimum_size = Vector2(46, 46)
		var icon_style = StyleBoxFlat.new()
		icon_style.bg_color = Color(0.24, 0.22, 0.18)
		icon_style.set_corner_radius_all(23) 
		icon_style.set_border_width_all(1)
		icon_style.border_color = Color(0.65, 0.45, 0.85)
		icon_panel.add_theme_stylebox_override("panel", icon_style)
		var resource_icon: Texture2D = hud._resource_icon_texture(str(tech["icon"]))
		if resource_icon:
			var icon_rect := TextureRect.new()
			icon_rect.texture = resource_icon
			icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_panel.add_child(icon_rect)
		else:
			var icon_label := Label.new()
			icon_label.text = tech["icon"]
			icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			icon_label.add_theme_font_size_override("font_size", 18)
			icon_panel.add_child(icon_label)
		hbox.add_child(icon_panel)
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(vbox)
		var lbl_title = Label.new()
		lbl_title.text = tech_name
		lbl_title.add_theme_font_size_override("font_size", 14)
		lbl_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
		vbox.add_child(lbl_title)
		var lbl_desc := RichTextLabel.new()
		lbl_desc.bbcode_enabled = true
		lbl_desc.fit_content = true
		lbl_desc.scroll_active = false
		lbl_desc.text = "%s\n%s Koszt: %d pkt" % [tech["desc"], hud._resource_icon_bbcode("Kultura"), tech["research_cost"]]
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_desc.add_theme_font_size_override("normal_font_size", 11)
		lbl_desc.add_theme_color_override("default_color", Color(0.75, 0.65, 0.85))
		vbox.add_child(lbl_desc)

		var invisible_button = Button.new()
		invisible_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		invisible_button.flat = true
		node_panel.add_child(invisible_button)
		
		var reqs_ok = true
		for r in tech["req"]:
			if not EconomyManager.culture_tree[r]["unlocked"]: reqs_ok = false
				
		if tech["unlocked"]:
			node_style.border_color = Color(0.55, 0.35, 0.9) 
			node_style.bg_color = Color(0.22, 0.15, 0.35)
			invisible_button.disabled = true
			invisible_button.tooltip_text = "Nurt kultury odkryty."
		elif EconomyManager.current_culture_research == tech_name:
			node_style.border_color = Color(0.85, 0.45, 1.0) 
			node_style.bg_color = Color(0.3, 0.2, 0.4)
			var current_culture = EconomyManager.resources["Kultura"]
			var progress = tech["research_cost"] - EconomyManager.resources["Kultura"]
			progress = clamp(progress, 0, tech["research_cost"])
			lbl_title.text = "%s (%d tur)" % [tech_name, EconomyManager.culture_turns_left]
			invisible_button.disabled = true
			invisible_button.tooltip_text = "Rozwój w toku. Pozostało %d tur." % EconomyManager.culture_turns_left
		elif not reqs_ok:
			node_panel.modulate.a = 0.35 
			invisible_button.disabled = true
			var missing_requirements: Array[String] = []
			for requirement in tech["req"]:
				if not EconomyManager.culture_tree[requirement]["unlocked"]:
					missing_requirements.append(str(requirement))
			invisible_button.tooltip_text = "Wymagane: %s" % ", ".join(missing_requirements)
		else:
			lbl_desc.text += "\nBADAJ"
			invisible_button.tooltip_text = "Rozpocznij rozwój za %d punktów Kultury." % int(tech["research_cost"])
			invisible_button.pressed.connect(func():
				if EconomyManager.current_culture_research != "":
					insufficient_points_dialog.title = "Trwają badania"
					insufficient_points_dialog.dialog_text = "Nie możesz rozpocząć nowego badania, dopóki obecne się nie zakończy."
					insufficient_points_dialog.popup_centered()
				elif EconomyManager.start_culture_research(tech_name):
					refresh_culture_tree_view()
				else:
					insufficient_points_dialog.title = "Za mało punktów"
					insufficient_points_dialog.dialog_text = "Nie masz wystarczającej liczby punktów Kultury, aby rozpocząć to badanie."
					insufficient_points_dialog.popup_centered()
			)
		culture_tree_map.add_child(node_panel)
	culture_tree_map.custom_minimum_size = max_size
