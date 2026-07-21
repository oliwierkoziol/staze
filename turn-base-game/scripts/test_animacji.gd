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
	print("ANIMATION_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
