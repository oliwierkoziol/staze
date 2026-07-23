extends SceneTree


const ZasobyAnimacjiWalkiScript = preload("res://scripts/zasoby_animacji_walki.gd")

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
	for projectile_kind in ["arrows", "spell", "fireball", "dynamite", "throwing_axe"]:
		_sprawdz(ZasobyAnimacjiWalkiScript.pobierz_pocisk(projectile_kind) != null, "Zasob pocisku istnieje: %s" % projectile_kind)
	_sprawdz(ZasobyAnimacjiWalkiScript.pobierz_pocisk("nieznany") == null, "Nieznany pocisk nie tworzy zasobu")
	var gra: Control = load("res://gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	gra.board._spawn_projectile(Vector2.ZERO, Vector2(100.0, 0.0), "spell")
	_sprawdz(gra.board.active_projectiles.size() == 1, "Pocisk jest dodawany do warstwy animacji")
	_sprawdz(is_zero_approx(float(gra.board.active_projectiles[0].rotation)), "Pocisk zachowuje kierunek w lokalnym ukladzie planszy")
	await create_timer(0.2).timeout
	_sprawdz(gra.board.active_projectiles.is_empty(), "Pocisk jest usuwany po zakonczeniu tweenu")
	gra.board.set_active_unit(42)
	_sprawdz(gra.board.active_unit_id == 42, "Plansza zna aktywna jednostke tury")
	_sprawdz(gra.board.turn_indicator_pulse_tween != null, "Puls wskaznika tury jest uruchomiony")
	gra.board.set_active_unit(-1)
	_sprawdz(gra.board.turn_indicator_pulse_tween == null, "Puls wskaznika tury zatrzymuje sie bez aktywnej jednostki")
	var rycerze: Dictionary = gra._prepare_unit({"id": 7001, "type_id": "human_knights", "side": "player", "grid_x": 1, "grid_y": 1})
	var lucznicy: Dictionary = gra._prepare_unit({"id": 7002, "type_id": "human_archers", "side": "player", "grid_x": 2, "grid_y": 1})
	var przeciwnik: Dictionary = gra._prepare_unit({"id": 7003, "type_id": "human_knights", "side": "enemy", "grid_x": 3, "grid_y": 1})
	gra.units = [rycerze, lucznicy, przeciwnik]
	gra.setup_mode = false
	gra._start_unit_activation(rycerze)
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("knight-select.wav"), "Select ludzi odpala sie na starcie aktywacji")
	gra._show_unit_details(lucznicy)
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("knight-select.wav"), "Zmiana zaznaczenia nie powtarza voice line")
	gra._apply_damage_to_unit(rycerze, 1)
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("knight-hurt.wav"), "Obrazenia odtwarzaja SFX trafionej jednostki")
	rycerze["count"] = 0
	rycerze["current_total_hp"] = 0
	gra._cleanup_destroyed_unit(rycerze)
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("knight-death.wav"), "Smierc odtwarza SFX zniszczonej jednostki")
	gra._odtworz_sfx_jednostki(przeciwnik, "wybor")
	gra._apply_damage_to_unit(przeciwnik, 1)
	przeciwnik["count"] = 0
	przeciwnik["current_total_hp"] = 0
	gra._cleanup_destroyed_unit(przeciwnik)
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("knight-death.wav"), "Select, obrazenia i smierc armii wroga nie odtwarzaja SFX")
	var pozostale_sfx: Dictionary = {
		"dwarf_guardian": "dwarf-select.wav",
		"elf_mage": "elf-select.wav",
		"goblin_trapper": "goblin-select.wav",
		"orc_shaman": "warrior-select.wav",
	}
	for type_id in pozostale_sfx:
		var jednostka: Dictionary = gra._prepare_unit({"id": 7100, "type_id": type_id, "side": "player"})
		gra._odtworz_sfx_jednostki(jednostka, "wybor")
		_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with(str(pozostale_sfx[type_id])), "Select jest przypisany do frakcji: %s" % type_id)
	var ork_kishaka: Dictionary = gra._prepare_unit({"id": 7200, "type_id": "orc_shaman", "side": "player"})
	var probnik: RandomNumberGenerator = RandomNumberGenerator.new()
	var ziarno_kishaka: int = 0
	while true:
		probnik.seed = ziarno_kishaka
		if probnik.randf() < gra.SZANSA_SFX_KISHAKA:
			break
		ziarno_kishaka += 1
	gra.orc_general_is_kishak = true
	gra.general_portrait.texture = gra.ORC_GENERAL_KISHAK_PORTRAIT
	gra.losowanie_sfx.seed = ziarno_kishaka
	gra._odtworz_sfx_jednostki(ork_kishaka, "wybor")
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("warrior-kishak.wav"), "Kwestia Kishaka dziala dla kazdej jednostki orkow")
	gra.general_portrait.texture = gra.DEFAULT_GENERAL_PORTRAIT
	gra.losowanie_sfx.seed = ziarno_kishaka
	gra._odtworz_sfx_jednostki(ork_kishaka, "wybor")
	_sprawdz(gra.odtwarzacz_sfx_jednostek.stream.resource_path.ends_with("warrior-select.wav"), "Kwestia Kishaka wymaga portretu generala Kishaka")
	_sprawdz(is_equal_approx(float(gra.SZANSA_SFX_KISHAKA), 0.2), "Kwestia Kishaka ma 20 procent szans")
	_sprawdz(is_equal_approx(gra.odtwarzacz_sfx_jednostek.volume_db, -10.0), "Wszystkie SFX jednostek maja wspolna glosnosc odtwarzacza")
	_sprawdz(gra._pobierz_rodzaj_sfx_broni({"type_id": "orc_warrior", "side": "enemy"}, "") == "axe", "Ataki AI korzystaja z SFX broni")
	_sprawdz(gra._pobierz_rodzaj_sfx_broni({"type_id": "elf_archer"}, "arrows") == "arrow", "Pocisk strzaly korzysta z SFX luku")
	_sprawdz(gra._pobierz_rodzaj_sfx_broni({"type_id": "goblin_thief"}, "") == "dagger", "Zlodziej korzysta z SFX sztyletu")
	_sprawdz(gra._pobierz_rodzaj_sfx_broni({"type_id": "goblin_trapper"}, "") == "dagger", "Traper korzysta z SFX sztyletu")
	_sprawdz(gra._pobierz_rodzaj_sfx_broni({"type_id": "human_mages"}, "spell") == "", "Atak magiczny nie udaje broni fizycznej")
	_sprawdz(gra._pobierz_rodzaj_sfx_broni({"type_id": "dwarf_axeman"}, "", "axe") == "axe", "Mlot korzysta z SFX topora")
	gra.odtwarzacz_sfx_trafienia.stream = null
	gra._odtworz_sfx_broni("sword")
	_sprawdz(gra.odtwarzacz_sfx_broni.stream.resource_path.ends_with("sword.mp3"), "SFX broni odtwarza przypisany plik")
	gra._odtworz_sfx_trafienia_po_czasie(0.02)
	_sprawdz(gra.odtwarzacz_sfx_trafienia.stream == null, "SFX trafienia nie wyprzedza SFX broni")
	await create_timer(0.03).timeout
	_sprawdz(gra.odtwarzacz_sfx_trafienia.stream.resource_path.ends_with("hitSound.mp3"), "Po SFX broni odtwarzany jest osobny SFX trafienia")
	_sprawdz(is_equal_approx(gra.odtwarzacz_sfx_broni.volume_db, -12.0), "SFX broni ma stonowana glosnosc")
	_sprawdz(is_equal_approx(gra.odtwarzacz_sfx_trafienia.volume_db, -12.0), "SFX trafienia ma stonowana glosnosc")
	print("ANIMATION_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
