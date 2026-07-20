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
	gra.help_mode_tutorial = true
	gra.tutorial_page = 0
	gra._help_rebuild_content()
	await process_frame
	_sprawdz(gra.help_popup_content.get_child_count() == TrescPomocyScript.STRONY_TUTORIALA[0].size(), "Pierwsza strona tutoriala buduje wszystkie etykiety")
	gra.help_mode_tutorial = false
	gra._help_rebuild_content()
	await process_frame
	_sprawdz(gra.help_popup_content.get_child_count() == TrescPomocyScript.SEKCJE_POMOCY.size(), "Widok pomocy buduje wszystkie sekcje")
	print("UI_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
