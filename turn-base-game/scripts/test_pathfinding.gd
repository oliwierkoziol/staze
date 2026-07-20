extends SceneTree

var gra: Control
var bledy: Array[String] = []


func _initialize() -> void:
	call_deferred("_uruchom")


func _sprawdz(warunek: bool, opis: String) -> void:
	if warunek:
		print("PASS: ", opis)
	else:
		bledy.append(opis)
		print("FAIL: ", opis)


func _jednostka(pole: Vector2i, id: int = 1, strona: String = "enemy") -> Dictionary:
	return {"id": id, "side": strona, "grid_x": pole.x, "grid_y": pole.y, "active_effects": []}


func _wyczysc(jednostki: Array) -> void:
	gra.units = jednostki
	gra.obstacles.clear()
	gra.terrain_effects.clear()


func _uruchom() -> void:
	gra = load("res://gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	gra._load_skill_library()
	gra._load_general_skills()
	gra._validate_setup()
	print("PASS: Walidacja konfiguracji bitwy")
	_test_geometrii()
	_test_podstawowych_tras()
	_test_pol_konczacych_ruch()
	_test_zagrozen()
	_test_spojnosci_zasiegu()
	_test_szarzy()
	_test_map()
	_pomiar_wydajnosci()
	print("PATHFINDING_TEST_FAILURES=", bledy.size())
	quit(bledy.size())


func _test_geometrii() -> void:
	var poprawne_granice := true
	var symetryczne_sasiedztwo := true
	for y in gra.GRID_ROWS:
		for x in gra.GRID_COLUMNS:
			var pole := Vector2i(x, y)
			for sasiad in gra._get_neighbors(pole):
				poprawne_granice = poprawne_granice and sasiad.x >= 0 and sasiad.x < gra.GRID_COLUMNS and sasiad.y >= 0 and sasiad.y < gra.GRID_ROWS
				symetryczne_sasiedztwo = symetryczne_sasiedztwo and gra._get_neighbors(sasiad).has(pole)
	_sprawdz(poprawne_granice, "Sasiedzi pozostaja na planszy")
	_sprawdz(symetryczne_sasiedztwo, "Sasiedztwo heksow jest symetryczne")


func _test_podstawowych_tras() -> void:
	var jednostka := _jednostka(Vector2i(1, 4))
	_wyczysc([jednostka])
	var cel := Vector2i(8, 7)
	var trasa: Array[Vector2i] = gra._find_path(jednostka, Vector2i(1, 4), cel)
	_sprawdz(trasa.size() == gra._hex_distance(Vector2i(1, 4), cel), "Pusta plansza daje najkrotsza trase")
	gra.obstacles.assign([{"grid_x": 3, "grid_y": 4, "type": "kamienie"}, {"grid_x": 3, "grid_y": 5, "type": "kamienie"}])
	trasa = gra._find_path(jednostka, Vector2i(1, 4), Vector2i(5, 4))
	_sprawdz(not trasa.is_empty() and not trasa.has(Vector2i(3, 4)) and not trasa.has(Vector2i(3, 5)), "Trasa omija przeszkody")
	gra.units.append(_jednostka(Vector2i(2, 4), 2))
	trasa = gra._find_path(jednostka, Vector2i(1, 4), Vector2i(4, 4))
	_sprawdz(not trasa.has(Vector2i(2, 4)), "Trasa omija inne jednostki")
	_sprawdz(gra._find_path(jednostka, Vector2i(1, 4), Vector2i(-1, 4)).is_empty(), "Cel poza plansza jest odrzucany")
	_sprawdz(gra._find_path(jednostka, Vector2i(-1, 4), Vector2i(1, 4)).is_empty(), "Start poza plansza jest odrzucany")
	gra.terrain_types["test_bagno"] = {"id": "test_bagno", "movement_cost": 3, "blocks_movement": false}
	gra.obstacles.assign([{"grid_x": 2, "grid_y": 4, "type": "test_bagno"}])
	trasa = gra._find_path(jednostka, Vector2i(1, 4), Vector2i(4, 4))
	_sprawdz(not trasa.has(Vector2i(2, 4)) and gra._get_path_cost(trasa) == 4, "Trasa uwzglednia koszt terenu")


func _test_pol_konczacych_ruch() -> void:
	var jednostka := _jednostka(Vector2i(1, 5))
	_wyczysc([jednostka])
	gra.obstacles.assign([{"grid_x": 2, "grid_y": 5, "type": "woda"}])
	var wejscie: Array[Vector2i] = gra._find_path(jednostka, Vector2i(1, 5), Vector2i(2, 5), {}, 3)
	_sprawdz(gra._get_executable_move_path(wejscie) == [Vector2i(2, 5)], "Woda zatrzymuje ruch na polu wejscia")
	_sprawdz(not gra._get_reachable_cells(jednostka, 3).has(Vector2i(4, 5)), "Woda nie udostepnia pol za nia")
	gra.obstacles.assign([{"grid_x": 2, "grid_y": 5, "type": "ruchome_piaski"}])
	_sprawdz(not gra._get_reachable_cells(jednostka, 3).has(Vector2i(4, 5)), "Ruchome piaski nie udostepniaja pol za nimi")
	gra.obstacles.assign([{"grid_x": 2, "grid_y": 5, "type": "hole"}])
	var dziura: Array[Vector2i] = gra._find_path(jednostka, Vector2i(1, 5), Vector2i(4, 5), {}, 3)
	_sprawdz(dziura.is_empty(), "Trasa nie przechodzi przez dziure")
	wejscie = gra._find_path(jednostka, Vector2i(1, 5), Vector2i(2, 5), {}, 3)
	_sprawdz(gra._get_executable_move_path(wejscie) == [Vector2i(2, 5)], "Wejscie do dziury konczy wykonanie trasy")


func _test_zagrozen() -> void:
	var jednostka := _jednostka(Vector2i(1, 5))
	_wyczysc([jednostka])
	gra.terrain_effects.assign([{"id": "fire", "grid_x": 2, "grid_y": 5, "remaining_turns": 2, "caster_side": "player"}])
	var trasa: Array[Vector2i] = gra._find_path(jednostka, Vector2i(1, 5), Vector2i(4, 5), {}, 4)
	_sprawdz(not trasa.has(Vector2i(2, 5)), "Znany ogien powoduje wybor bezpiecznego objazdu")
	gra.terrain_effects.assign([{"id": "bear_trap", "grid_x": 2, "grid_y": 5, "remaining_turns": 99, "caster_side": "player"}])
	var pole_pulapki: Array[Vector2i] = [Vector2i(2, 5)]
	_sprawdz(gra._get_path_hazard_penalty(jednostka, pole_pulapki) == 0, "Ukryta pulapka nie ujawnia sie planerowi")
	trasa = gra._find_path(jednostka, Vector2i(1, 5), Vector2i(4, 5), {}, 3)
	_sprawdz(gra._get_executable_move_path(trasa).back() == Vector2i(2, 5), "Faktyczne wejscie zatrzymuje ruch na ukrytej pulapce")
	gra.terrain_effects.assign([{"id": "bear_trap", "grid_x": 2, "grid_y": 5, "remaining_turns": 99, "caster_side": "enemy"}])
	trasa = gra._find_path(jednostka, Vector2i(1, 5), Vector2i(4, 5), {}, 4)
	_sprawdz(not trasa.has(Vector2i(2, 5)), "Znana pulapka powoduje wybor objazdu")


func _test_spojnosci_zasiegu() -> void:
	var jednostka := _jednostka(Vector2i(7, 5))
	_wyczysc([jednostka])
	gra.obstacles.assign([{"grid_x": 8, "grid_y": 5, "type": "kamienie"}, {"grid_x": 6, "grid_y": 4, "type": "kamienie"}])
	var budzet := 4
	var spojne := true
	for pole in gra._get_reachable_cells(jednostka, budzet):
		var trasa: Array[Vector2i] = gra._find_path(jednostka, Vector2i(7, 5), pole, {}, budzet)
		spojne = spojne and not trasa.is_empty() and gra._get_path_cost(trasa) <= budzet
	_sprawdz(spojne, "Kazde podswietlone pole ma trase w budzecie")


func _test_szarzy() -> void:
	var jednostka := _jednostka(Vector2i(1, 5), 1, "player")
	jednostka.merge({"move_range": 3, "remaining_move": 3, "attack_range": 1}, true)
	var cel := _jednostka(Vector2i(5, 5), 2)
	_wyczysc([jednostka, cel])
	gra.obstacles.assign([{"grid_x": 2, "grid_y": 5, "type": "woda"}])
	_sprawdz(not gra._can_charge_attack_target(jednostka, cel, gra.skill_library["szarza"]), "Szarza nie deklaruje ataku przez pole konczace ruch")


func _test_map() -> void:
	var gracz := _jednostka(Vector2i(2, 5), 1, "player")
	var przeciwnik := _jednostka(Vector2i(12, 5), 2)
	var polaczone := true
	var pule: Dictionary = {
		"normalna": ["woda", "kamienie", "krzok"],
		"las": ["holy_tree", "elf_statue"],
		"kopalnia": ["cart", "detonator", "hole"],
		"zima": ["woda", "kamienie", "zimowy_krzak"],
		"pustynia": ["ruchome_piaski", "kamienie"],
	}
	for nazwa_mapy in pule:
		var typy: Array[String] = []
		for typ in pule[nazwa_mapy]:
			typy.append(str(typ))
		for _proba in 20:
			gra.units = [gracz, przeciwnik]
			gra.obstacles = gra.ObstacleGeneratorScript.generate(gra.units, typy, gra.GRID_COLUMNS, gra.GRID_ROWS, gra.SETUP_COLUMNS, nazwa_mapy == "zima")
			var ma_dojscie := false
			for sasiad in gra._get_neighbors(Vector2i(przeciwnik.grid_x, przeciwnik.grid_y)):
				if not gra._find_path(gracz, Vector2i(gracz.grid_x, gracz.grid_y), sasiad).is_empty():
					ma_dojscie = true
					break
			polaczone = polaczone and ma_dojscie
	_sprawdz(polaczone, "Losowe mapy wszystkich typow zachowuja polaczenie stron")


func _pomiar_wydajnosci() -> void:
	var ai: Dictionary = gra._prepare_unit({"id": 10, "type_id": "orc_warrior", "side": "enemy", "grid_x": 12, "grid_y": 5})
	var cel: Dictionary = gra._prepare_unit({"id": 11, "type_id": "human_archers", "side": "player", "grid_x": 2, "grid_y": 5})
	_wyczysc([ai, cel])
	var start: int = Time.get_ticks_usec()
	gra._ai_choose_plan(ai)
	print("PATHFINDING_AI_PLAN_US=", Time.get_ticks_usec() - start)
