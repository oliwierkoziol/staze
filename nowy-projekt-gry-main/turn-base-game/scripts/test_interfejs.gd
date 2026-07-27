extends SceneTree


const TrescPomocyScript = preload("res://turn-base-game/scripts/tresc_pomocy.gd")

var bledy: Array[String] = []


func _initialize() -> void:
	call_deferred("_uruchom")


func _sprawdz(warunek: bool, opis: String) -> void:
	if warunek:
		print("PASS: ", opis)
	else:
		bledy.append(opis)
		print("FAIL: ", opis)


func _uruchom() -> void:
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA.size() == 5, "Tutorial zachowuje 5 stron")
	_sprawdz(TrescPomocyScript.SEKCJE_POMOCY.size() == 3, "Pomoc zachowuje 3 sekcje")
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA[0].has("Przycisk WCZYTAJ STAN WALKI w menu Potyczki przywraca zapisaną bitwę."), "Tutorial opisuje wczytywanie stanu Potyczki")
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA[2].any(func(line: String) -> bool: return "Niebieskie pola" in line), "Tutorial wyjaśnia kolory pól")
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA[3].any(func(line: String) -> bool: return "wydarzenie mapy" in line), "Tutorial opisuje wydarzenia mapy")
	var main_menu: Control = load("res://ui/main_menu.tscn").instantiate()
	root.add_child(main_menu)
	await process_frame
	var main_buttons: Array[String] = []
	for button in main_menu.find_children("*", "Button", true, false):
		main_buttons.append((button as Button).text)
	_sprawdz(
		main_buttons.has("NOWA KAMPANIA")
		and main_buttons.has("POTYCZKA")
		and main_buttons.has("WCZYTAJ ZAPIS Z PLIKU")
		and main_buttons.has("USTAWIENIA")
		and main_buttons.has("WYJDŹ Z GRY"),
		"Menu główne udostępnia komplet podstawowych akcji"
	)
	_sprawdz(
		main_menu.settings_overlay.find_children("*", "HSlider", true, false).size() == 4,
		"Ustawienia dźwięku są dostępne w menu głównym"
	)
	_sprawdz(
		main_menu.campaign_difficulty.item_count == 3
		and main_menu.campaign_difficulty.get_item_metadata(0) == "latwy"
		and main_menu.campaign_difficulty.get_item_metadata(2) == "trudny",
		"Nowa kampania pozwala wybrać trzy profile AI"
	)
	main_menu.campaign_difficulty.select(2)
	main_menu.campaign_difficulty.item_selected.emit(2)
	_sprawdz(main_menu.selected_campaign_difficulty == "trudny", "Wybór trudności aktualizuje profil AI kampanii")
	main_menu.queue_free()
	await process_frame
	var campaign_world = load("res://scenes/game_world.tscn").instantiate()
	campaign_world.set_script(null)
	root.add_child(campaign_world)
	for _frame in range(3):
		await process_frame
	var campaign_hud = campaign_world.get_node("CanvasLayer/UI")
	campaign_hud.hide_all_menus()
	var command_buttons = campaign_hud.quick_actions_panel.get_node("CommandColumn/CommandButtons")
	var command_labels: Array[String] = []
	for button in command_buttons.find_children("*", "Button", true, false):
		command_labels.append((button as Button).text)
	_sprawdz(
		command_buttons is VBoxContainer
		and campaign_hud.quick_actions_panel.anchor_left == 0.0
		and campaign_hud.points_panel.anchor_left == 1.0
		and not command_labels.has("+")
		and not command_labels.has("−")
		and campaign_hud.quick_army_button.get_theme_stylebox("normal") is StyleBoxEmpty,
		"HUD kampanii ma lewy dock i prawy panel rozwoju"
	)
	campaign_hud._align_right_column()
	_sprawdz(
		is_equal_approx(campaign_hud.points_panel.size.x, campaign_hud.tile_info_menu.size.x)
		and campaign_hud.tile_info_menu.position.y >= campaign_hud.points_panel.position.y + campaign_hud.points_panel.size.y,
		"Panel terenu ma szerokość panelu rozwoju i znajduje się pod nim"
	)
	var build_scroll = campaign_hud.menu_budowania.get_node("VBoxContainer/BuildScroll")
	_sprawdz(
		build_scroll is ScrollContainer
		and campaign_hud.menu_budowania.custom_minimum_size.y == 420
		and campaign_hud.menu_budowania.offset_left == campaign_hud.turn_button.offset_left
		and campaign_hud.menu_budowania.offset_right == campaign_hud.skip_button.offset_right,
		"Menu budowy ma stałą wysokość, scroll i leży nad akcjami tury"
	)
	var tech_window: Panel = campaign_hud.tech_tree_menu.tech_tree_window
	var tech_scroll: ScrollContainer = tech_window.get_node("ScrollContainer")
	_sprawdz(
		is_equal_approx(tech_window.anchor_left, 0.05)
		and is_equal_approx(tech_window.anchor_right, 0.95)
		and tech_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		and tech_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS,
		"Drzewko technologii jest responsywnym przewijanym overlayem"
	)
	tech_window.visible = true
	campaign_hud.tech_tree_menu.refresh_technology_tree_view()
	await process_frame
	tech_scroll.scroll_horizontal = 0
	var previous_scroll := tech_scroll.scroll_horizontal
	campaign_hud._apply_tree_pan(tech_scroll, Vector2(-40, 0))
	_sprawdz(tech_scroll.scroll_horizontal > previous_scroll, "Przeciąganie przesuwa zawartość drzewka")
	campaign_world.queue_free()
	await process_frame
	var gra: Control = load("res://turn-base-game/gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	var skirmish_buttons: Array[String] = []
	for button in gra.get_node("TeamSetup").find_children("*", "Button", true, false):
		skirmish_buttons.append((button as Button).text)
	_sprawdz(
		skirmish_buttons.has("MENU GŁÓWNE") and not skirmish_buttons.has("USTAWIENIA"),
		"Menu Potyczki ma wyjście i nie dubluje ustawień z menu głównego"
	)
	var build_info: Label = gra.get_node("TeamSetup/BuildInfo")
	var expected_build_info := "WERSJA %s" % ProjectSettings.get_setting("application/config/version", "0.1.0")
	_sprawdz(build_info.text == expected_build_info, "Menu Potyczki pokazuje wersję gry")
	gra._build_save_load_dialogs()
	_sprawdz(gra.pause_menu != null, "Menu pauzy istnieje")
	gra.pause_menu.set_campaign_mode(false)
	_sprawdz(
		gra.pause_menu._save_button.text == "ZAPISZ STAN"
		and gra.pause_menu._load_button.text == "WCZYTAJ STAN"
		and gra.pause_menu._restart_button.text == "RESETUJ WALKĘ"
		and gra.pause_menu._mode_menu_button.text == "WRÓĆ DO MENU"
		and gra.pause_menu._resume_button.text == "WZNÓW WALKĘ",
		"Menu Potyczki ma kontekstowe akcje"
	)
	_sprawdz(
		gra.pause_menu._save_button.visible
		and gra.pause_menu._restart_button.visible
		and gra.pause_menu._mode_menu_button.visible
		and not gra.pause_menu._retreat_button.visible,
		"Potyczka ukrywa kampanijne wycofanie"
	)
	gra.pause_menu.set_campaign_mode(true)
	_sprawdz(
		not gra.pause_menu._save_button.visible
		and not gra.pause_menu._load_button.visible
		and not gra.pause_menu._restart_button.visible
		and not gra.pause_menu._mode_menu_button.visible
		and gra.pause_menu._retreat_button.visible,
		"Kampania pokazuje tylko właściwe akcje"
	)
	gra.pause_menu.set_campaign_mode(false)
	var volume_labels: Array[String] = []
	for label in gra.ustawienia_layer.find_children("*", "Label", true, false):
		volume_labels.append((label as Label).text)
	_sprawdz(
		gra.ustawienia_layer.find_children("*", "HSlider", true, false).size() == 4
		and volume_labels.has("GŁOŚNOŚĆ GŁÓWNA (WSZYSTKO)")
		and volume_labels.has("EFEKTY")
		and volume_labels.has("DIALOGI")
		and volume_labels.has("MUZYKA"),
		"Ustawienia walki mają cztery osobne suwaki dźwięku"
	)
	gra.hud.visible = true
	gra._toggle_pause_menu()
	_sprawdz(gra.pause_menu.visible, "ESC otwiera menu pauzy")
	_sprawdz(gra.get_tree().paused, "Menu pauzy wstrzymuje drzewo sceny")
	gra._on_pause_resume_pressed()
	_sprawdz(not gra.pause_menu.visible, "Przycisk WZNÓW WALKĘ zamyka menu pauzy")
	_sprawdz(not gra.get_tree().paused, "Powrót wznawia drzewo sceny")
	gra.current_player_faction = "orcs"
	var reset_configs: Array[Dictionary] = [{"id": 1, "type_id": "orc_berserker", "side": "player", "count": 10, "grid_x": 1, "grid_y": 1}]
	var reset_queue: Array[int] = [1]
	gra.unit_configs = reset_configs
	gra.general_skill_used = true
	gra.detonator_activated = true
	gra.turn_queue = reset_queue
	gra._on_pause_restart_pressed()
	_sprawdz(
		gra.setup_mode
		and gra.current_player_faction == "orcs"
		and gra.unit_configs.size() == 1
		and not gra.general_skill_used
		and not gra.detonator_activated
		and gra.turn_queue.is_empty()
		and not gra.help_popup.visible,
		"Reset rozpoczyna od nowa tę samą Potyczkę i czyści stan walki"
	)
	gra._show_victory_overlay("enemy")
	_sprawdz(
		gra.victory_title_label.text == "ZWYCIĘZCA: PRZECIWNIK"
		and gra.victory_restart_button.visible
		and gra.victory_finish_button.text == "MENU POTYCZKI",
		"Wynik Potyczki wskazuje zwycięzcę i właściwe akcje"
	)
	gra.victory_overlay.visible = false
	gra.campaign_mode = true
	gra._show_victory_overlay("enemy")
	_sprawdz(
		gra.victory_title_label.text == "PORAŻKA"
		and not gra.victory_restart_button.visible
		and gra.victory_finish_button.text == "WRÓĆ DO MAPY",
		"Wynik kampanii odróżnia porażkę i prowadzi do mapy"
	)
	gra.victory_overlay.visible = false
	gra.campaign_mode = false
	gra._set_help_popup_visible(true)
	gra.pause_menu.load_requested.emit()
	await process_frame
	_sprawdz(gra.load_setup_dialog.visible, "Menu pauzy pozwala wczytać zapis podczas samouczka")
	gra.load_setup_dialog.hide()
	gra._set_help_popup_visible(false)
	gra.help_mode_tutorial = true
	gra.tutorial_page = 0
	gra._help_rebuild_content()
	await process_frame
	_sprawdz(gra.help_popup_content.get_child_count() == TrescPomocyScript.STRONY_TUTORIALA[0].size(), "Pierwsza strona tutoriala buduje wszystkie etykiety")
	gra.help_mode_tutorial = false
	gra._help_rebuild_content()
	await process_frame
	_sprawdz(gra.help_popup_content.get_child_count() == TrescPomocyScript.SEKCJE_POMOCY.size(), "Widok pomocy buduje wszystkie sekcje")
	var stages: Array[Dictionary] = [{"name": "Mury"}, {"name": "Przedmieścia"}, {"name": "Centrum"}]
	gra._set_stage_transition_content(1, stages)
	_sprawdz(gra.stage_transition_progress.text == "ETAP 1/3", "Postęp etapu nie używa brakujących glifów")
	var hover_unit: Dictionary = gra._prepare_unit({"id": 9000, "type_id": "orc_berserker", "side": "player", "grid_x": 4, "grid_y": 4})
	_sprawdz(int(hover_unit.get("level", 0)) == 1, "Nowa jednostka zaczyna na poziomie 1")
	gra._render_unit_details(hover_unit)
	_sprawdz(gra.unit_meta_label.text == "Poziom 1", "Panel jednostki pokazuje poziom z danych")
	var locked_unit: Dictionary = gra._prepare_unit({"id": 9002, "type_id": "human_knights", "side": "player", "skill_ids": ["odepchniecie_tarcza"]})
	gra._render_unit_details(locked_unit)
	await process_frame
	var ability_cards: Array[Node] = gra.unit_abilities_panel.find_children("AbilityCard", "Button", true, false)
	_sprawdz(
		ability_cards.size() == 3
		and not ability_cards[0].get_node("LockedOverlay").visible
		and ability_cards[1].get_node("LockedOverlay").visible
		and ability_cards[2].get_node("LockedOverlay").visible,
		"Panel pokazuje stale sloty i grafike zablokowanych umiejetnosci"
	)
	gra.setup_mode = false
	gra._update_action_buttons()
	_sprawdz(gra.end_turn_button.text == "Zakończ turę", "Przycisk kończy turę")
	gra._start_campaign_battle({
		"player_faction": "humans",
		"enemy_faction": "orcs",
		"ai_difficulty": "sredni",
		"units": [
			{"id": 9100, "type_id": "human_knights", "side": "player", "count": 2},
			{"id": 9101, "type_id": "orc_warrior", "side": "enemy", "count": 2},
		],
	})
	await process_frame
	var campaign_player: Dictionary = gra._find_unit_by_id(9100)
	var campaign_enemy: Dictionary = gra._find_unit_by_id(9101)
	_sprawdz(
		gra.setup_mode
		and gra.active_unit_id == -1
		and not gra._get_setup_placeable_cells(campaign_player).is_empty()
		and gra._get_setup_placeable_cells(campaign_enemy).is_empty(),
		"Kampania zaczyna sie od rozstawienia wylacznie jednostek gracza"
	)
	gra.units = [hover_unit]
	gra.setup_mode = false
	gra.current_turn = "player"
	gra.active_unit_id = 9000
	gra.selected_unit_id = 9000
	gra._load_skill_library()
	gra.pending_skill_id = "mistrz_trucizn"
	gra._update_highlighted_cells(hover_unit)
	_sprawdz(gra.board.zielone_pola_ataku.has(Vector2i(4, 4)), "Umiejetnosc na siebie podswietla cel na zielono")
	var sojusznik: Dictionary = hover_unit.duplicate(true)
	sojusznik["id"] = 9001
	sojusznik["grid_x"] = 5
	gra.units = [hover_unit, sojusznik]
	gra.pending_skill_id = "zelazna_kurtyna"
	gra._update_highlighted_cells(hover_unit)
	_sprawdz(gra.board.zielone_pola_ataku.has(Vector2i(5, 4)), "Sojusznik w zasiegu pozostaje zielony")
	_sprawdz(gra.board.highlighted_attack_cells.has(Vector2i(3, 4)) and not gra.board.zielone_pola_ataku.has(Vector2i(3, 4)), "Puste pole zasiegu umiejetnosci sojuszniczej jest zolte")
	gra.pending_skill_id = ""
	gra._show_move_cost_label(1, 3)
	gra._on_board_cell_hovered(Vector2i(4, 4))
	_sprawdz(not gra.move_cost_label.visible, "Pole aktywnej jednostki nie pokazuje komunikatu Za daleko")
	var transition: Node = root.get_node("SceneTransition")
	_sprawdz(transition.call("change_scene", "res://ui/main_menu.tscn", "TEST PRZEJŚCIA") == OK, "Loading rozpoczyna poprawne przejście")
	await scene_changed
	_sprawdz(current_scene != null and current_scene.name == "MainMenu", "Loading kończy przejście na docelowej scenie")
	print("UI_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
