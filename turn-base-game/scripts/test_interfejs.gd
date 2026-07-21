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
	var gra: Control = load("res://gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	var build_info: Label = gra.get_node("TeamSetup/BuildInfo")
	_sprawdz(build_info.text == "BUILD 0.1.0 • 2026-07-21", "Menu pokazuje numer buildu i datę")
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
	gra._show_move_cost_label(1, 3)
	gra._on_board_cell_hovered(Vector2i(4, 4))
	_sprawdz(not gra.move_cost_label.visible, "Pole aktywnej jednostki nie pokazuje komunikatu Za daleko")
	print("UI_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
