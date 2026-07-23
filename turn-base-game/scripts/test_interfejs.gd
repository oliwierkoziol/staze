extends SceneTree


const TrescPomocyScript = preload("res://scripts/tresc_pomocy.gd")

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
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA[0].has("Przycisk WCZYTAJ w menu lub prawym panelu przywraca zapisaną bitwę."), "Tutorial opisuje wczytywanie zapisu")
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA[2].any(func(line: String) -> bool: return "Niebieskie pola" in line), "Tutorial wyjaśnia kolory pól")
	_sprawdz(TrescPomocyScript.STRONY_TUTORIALA[3].any(func(line: String) -> bool: return "wydarzenie mapy" in line), "Tutorial opisuje wydarzenia mapy")
	var gra: Control = load("res://gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	var build_info: Label = gra.get_node("TeamSetup/BuildInfo")
	_sprawdz(build_info.text == "BUILD 0.1.0 • 2026-07-21", "Menu pokazuje numer buildu i datę")
	gra._build_setup_controls()
	_sprawdz(gra.pause_menu != null, "Menu pauzy istnieje")
	_sprawdz(gra.pause_save_button.text == "ZAPISZ" and gra.pause_load_button.text == "WCZYTAJ" and gra.pause_reset_button.text == "RESET" and gra.pause_resume_button.text == "POWRÓT" and gra.pause_exit_button.text == "WYJDŹ", "Menu pauzy ma wszystkie wymagane przyciski")
	_sprawdz(gra.setup_controls.visible == false, "Stary kontener przycisków jest niewidoczny")
	gra.hud.visible = true
	gra._toggle_pause_menu()
	_sprawdz(gra.pause_menu.visible, "ESC otwiera menu pauzy")
	_sprawdz(gra.get_tree().paused, "Menu pauzy wstrzymuje drzewo sceny")
	gra._on_pause_resume_pressed()
	_sprawdz(not gra.pause_menu.visible, "Przycisk POWRÓT zamyka menu pauzy")
	_sprawdz(not gra.get_tree().paused, "Powrót wznawia drzewo sceny")
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
	print("UI_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
