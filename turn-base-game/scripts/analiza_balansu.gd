extends SceneTree

const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const MatematykaWalkiScript = preload("res://scripts/matematyka_walki.gd")
const RAPORT_SZCZEGOLOWY := "res://raporty/balans_1v1.csv"
const RAPORT_PODSUMOWANIE := "res://raporty/podsumowanie_balansu.csv"
const RAPORT_ROLE := "res://raporty/balans_rol.csv"
const RAPORT_DOMENY := "res://raporty/balans_domen.csv"
const DOMYSLNA_MAKSYMALNA_LICZEBNOSC := 14
const ROLE_BALANSOWE: Array[String] = ["obronca", "wojownik", "uderzeniowa", "dystansowa", "wsparcie_kontrola"]


func _initialize() -> void:
	seed(12345)
	_uruchom_smoke_test()
	var jednostki: Array[Dictionary] = _wczytaj_jednostki()
	if jednostki.is_empty():
		push_error("Brak jednostek do analizy.")
		quit(1)
		return
	_sprawdz_tempo_walki(jednostki)

	var maksymalna_liczebnosc: int = DOMYSLNA_MAKSYMALNA_LICZEBNOSC
	var argument: int = _pobierz_argument_maksymalnej_liczebnosci()
	if argument == -1:
		quit(2)
		return
	if argument > 0:
		maksymalna_liczebnosc = argument

	var katalog: String = ProjectSettings.globalize_path("res://raporty")
	if not DirAccess.dir_exists_absolute(katalog) and DirAccess.make_dir_recursive_absolute(katalog) != OK:
		push_error("Nie mozna utworzyc katalogu raportow: %s" % katalog)
		quit(1)
		return

	var raport: FileAccess = FileAccess.open(RAPORT_SZCZEGOLOWY, FileAccess.WRITE)
	if raport == null:
		push_error("Nie mozna zapisac raportu: %s" % RAPORT_SZCZEGOLOWY)
		quit(1)
		return
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray([
		"frakcja_a", "id_a", "nazwa_a", "rola_a", "liczebnosc_a", "hp_a", "atk_a", "dmg_min_a", "dmg_max_a", "def_a", "speed_a",
		"frakcja_b", "id_b", "nazwa_b", "rola_b", "liczebnosc_b", "hp_b", "atk_b", "dmg_min_b", "dmg_max_b", "def_b", "speed_b",
		"pierwszy_atakujacy", "zwyciezca", "rundy", "ataki", "pozostala_liczebnosc",
		"pozostale_hp", "pozostale_hp_proc", "przewaga_a_hp_proc"
	]))

	var podsumowanie: Dictionary = {}
	var role_jednostek: Dictionary = {}
	var domeny: Dictionary = {}
	for jednostka in jednostki:
		podsumowanie[str(jednostka.id)] = {
			"walki": 0, "wygrane": 0, "suma_hp_proc": 0.0, "suma_rund": 0,
			"domyslne_walki": 0, "domyslne_wygrane": 0
		}
		role_jednostek[str(jednostka.id)] = {
			"walki": 0, "wygrane": 0, "walki_w_roli": 0, "wygrane_w_roli": 0
		}

	var liczba_walk: int = 0
	for szablon_a in jednostki:
		for szablon_b in jednostki:
			for liczebnosc_a in range(1, maksymalna_liczebnosc + 1):
				for liczebnosc_b in range(1, maksymalna_liczebnosc + 1):
					var wynik: Dictionary = _symuluj(szablon_a, liczebnosc_a, szablon_b, liczebnosc_b)
					_zapisz_walke(raport, szablon_a, liczebnosc_a, szablon_b, liczebnosc_b, wynik)
					var domyslne_liczebnosci: bool = liczebnosc_a == int(szablon_a.count) and liczebnosc_b == int(szablon_b.count)
					_aktualizuj_podsumowanie(
						podsumowanie[str(szablon_a.id)],
						wynik,
						domyslne_liczebnosci
					)
					if liczebnosc_a == liczebnosc_b and str(szablon_a.id) != str(szablon_b.id):
						_aktualizuj_role(role_jednostek, szablon_a, szablon_b, wynik)
						_aktualizuj_domeny(domeny, szablon_a, szablon_b, wynik)
					liczba_walk += 1
	raport.close()
	if not _zapisz_podsumowanie(jednostki, podsumowanie):
		quit(1)
		return
	if not _zapisz_role(jednostki, role_jednostek) or not _zapisz_domeny(domeny):
		quit(1)
		return
	print("Analiza zakonczona: %d walk, liczebnosc 1-%d." % [liczba_walk, maksymalna_liczebnosc])
	print(ProjectSettings.globalize_path(RAPORT_SZCZEGOLOWY))
	print(ProjectSettings.globalize_path(RAPORT_PODSUMOWANIE))
	print(ProjectSettings.globalize_path(RAPORT_ROLE))
	print(ProjectSettings.globalize_path(RAPORT_DOMENY))
	quit()


func _wczytaj_jednostki() -> Array[Dictionary]:
	var wynik: Array[Dictionary] = []
	for frakcja in UnitTypeLibraryScript.get_factions():
		if str(frakcja.get("id", "")) == "testowa":
			continue
		for surowa_jednostka in frakcja.get("units", []):
			if typeof(surowa_jednostka) != TYPE_DICTIONARY:
				continue
			var jednostka: Dictionary = (surowa_jednostka as Dictionary).duplicate(true)
			var rola: String = str(jednostka.get("balance_role", ""))
			if not ROLE_BALANSOWE.has(rola):
				push_error("Brak poprawnej roli balansowej jednostki: %s" % str(jednostka.get("id", "")))
				return []
			jednostka["faction_id"] = str(frakcja.get("id", ""))
			wynik.append(jednostka)
	return wynik


func _pobierz_argument_maksymalnej_liczebnosci() -> int:
	for surowy_argument in OS.get_cmdline_user_args():
		var argument: String = str(surowy_argument)
		if not argument.begins_with("--max-count="):
			continue
		var wartosc: String = argument.trim_prefix("--max-count=")
		if not wartosc.is_valid_int() or int(wartosc) < 1 or int(wartosc) > 100:
			push_error("--max-count musi byc liczba od 1 do 100.")
			return -1
		return int(wartosc)
	return 0


func _przygotuj_oddzial(szablon: Dictionary, liczebnosc: int) -> Dictionary:
	var oddzial: Dictionary = szablon.duplicate(true)
	oddzial["base_hp"] = int(szablon.get("hp", 1))
	oddzial["count"] = liczebnosc
	MatematykaWalkiScript.ustaw_pelne_hp(oddzial)
	return oddzial


func _sprawdz_tempo_walki(jednostki: Array[Dictionary]) -> void:
	var suma_atakow: int = 0
	var liczba_par: int = 0
	for atakujacy in jednostki:
		for cel in jednostki:
			if str(atakujacy.id) == str(cel.id):
				continue
			var zakres: Vector2i = MatematykaWalkiScript.oblicz_zakres_obrazen(atakujacy, cel)
			var hp_oddzialu: int = int(cel.hp) * int(cel.count)
			assert(zakres.y < hp_oddzialu, "Zwykly atak nie moze zabic pelnego oddzialu: %s -> %s" % [atakujacy.id, cel.id])
			var srednie_obrazenia: int = maxi(1, int(round((zakres.x + zakres.y) / 2.0)))
			suma_atakow += ceili(float(hp_oddzialu) / float(srednie_obrazenia))
			liczba_par += 1
	var srednia_atakow: float = float(suma_atakow) / float(maxi(1, liczba_par))
	assert(srednia_atakow >= 3.5 and srednia_atakow <= 4.5, "Srednie tempo walki musi wynosic 3,5-4,5 ataku, jest %.2f." % srednia_atakow)
	print("Tempo walki: %.2f ataku, one-shoty zwyklym atakiem: 0/%d" % [srednia_atakow, liczba_par])


func _symuluj(szablon_a: Dictionary, liczebnosc_a: int, szablon_b: Dictionary, liczebnosc_b: int) -> Dictionary:
	var oddzial_a: Dictionary = _przygotuj_oddzial(szablon_a, liczebnosc_a)
	var oddzial_b: Dictionary = _przygotuj_oddzial(szablon_b, liczebnosc_b)
	var a_pierwszy: bool = int(oddzial_a.speed) >= int(oddzial_b.speed)
	var rundy: int = 0
	var ataki: int = 0
	while int(oddzial_a.count) > 0 and int(oddzial_b.count) > 0:
		rundy += 1
		if a_pierwszy:
			_atakuj(oddzial_a, oddzial_b)
			ataki += 1
			if int(oddzial_b.count) > 0:
				_atakuj(oddzial_b, oddzial_a)
				ataki += 1
		else:
			_atakuj(oddzial_b, oddzial_a)
			ataki += 1
			if int(oddzial_a.count) > 0:
				_atakuj(oddzial_a, oddzial_b)
				ataki += 1

	var wygral_a: bool = int(oddzial_a.count) > 0
	var zwyciezca: Dictionary = oddzial_a if wygral_a else oddzial_b
	var hp_proc: float = 100.0 * float(zwyciezca.current_total_hp) / float(zwyciezca.max_total_hp)
	return {
		"wygral_a": wygral_a,
		"pierwszy": str(szablon_a.id) if a_pierwszy else str(szablon_b.id),
		"zwyciezca": str(szablon_a.id) if wygral_a else str(szablon_b.id),
		"rundy": rundy,
		"ataki": ataki,
		"pozostala_liczebnosc": int(zwyciezca.count),
		"pozostale_hp": int(zwyciezca.current_total_hp),
		"pozostale_hp_proc": hp_proc,
		"przewaga_a_hp_proc": hp_proc if wygral_a else -hp_proc
	}


func _atakuj(atakujacy: Dictionary, cel: Dictionary) -> void:
	cel["current_total_hp"] = maxi(0, int(cel.current_total_hp) - MatematykaWalkiScript.oblicz_obrazenia(atakujacy, cel))
	MatematykaWalkiScript.odswiez_stan_hp(cel)


func _zapisz_walke(raport: FileAccess, a: Dictionary, liczebnosc_a: int, b: Dictionary, liczebnosc_b: int, wynik: Dictionary) -> void:
	raport.store_csv_line(PackedStringArray([
		str(a.faction_id), str(a.id), str(a.name), str(a.balance_role), str(liczebnosc_a), str(a.hp), str(a.atk), str(a.dmg_min), str(a.dmg_max), str(a.def), str(a.speed),
		str(b.faction_id), str(b.id), str(b.name), str(b.balance_role), str(liczebnosc_b), str(b.hp), str(b.atk), str(b.dmg_min), str(b.dmg_max), str(b.def), str(b.speed),
		str(wynik.pierwszy), str(wynik.zwyciezca), str(wynik.rundy), str(wynik.ataki),
		str(wynik.pozostala_liczebnosc), str(wynik.pozostale_hp), "%.2f" % float(wynik.pozostale_hp_proc),
		"%.2f" % float(wynik.przewaga_a_hp_proc)
	]))


func _aktualizuj_podsumowanie(statystyki: Dictionary, wynik: Dictionary, domyslne_liczebnosci: bool) -> void:
	statystyki["walki"] = int(statystyki.walki) + 1
	statystyki["suma_rund"] = int(statystyki.suma_rund) + int(wynik.rundy)
	if bool(wynik.wygral_a):
		statystyki["wygrane"] = int(statystyki.wygrane) + 1
		statystyki["suma_hp_proc"] = float(statystyki.suma_hp_proc) + float(wynik.pozostale_hp_proc)
	if domyslne_liczebnosci:
		statystyki["domyslne_walki"] = int(statystyki.domyslne_walki) + 1
		if bool(wynik.wygral_a):
			statystyki["domyslne_wygrane"] = int(statystyki.domyslne_wygrane) + 1


func _aktualizuj_role(role_jednostek: Dictionary, a: Dictionary, b: Dictionary, wynik: Dictionary) -> void:
	var ta_sama_rola: bool = str(a.balance_role) == str(b.balance_role)
	_dodaj_wynik_roli(role_jednostek[str(a.id)], bool(wynik.wygral_a), ta_sama_rola)
	_dodaj_wynik_roli(role_jednostek[str(b.id)], not bool(wynik.wygral_a), ta_sama_rola)


func _dodaj_wynik_roli(statystyki: Dictionary, wygrana: bool, ta_sama_rola: bool) -> void:
	statystyki["walki"] = int(statystyki.walki) + 1
	statystyki["wygrane"] = int(statystyki.wygrane) + int(wygrana)
	if ta_sama_rola:
		statystyki["walki_w_roli"] = int(statystyki.walki_w_roli) + 1
		statystyki["wygrane_w_roli"] = int(statystyki.wygrane_w_roli) + int(wygrana)


func _aktualizuj_domeny(domeny: Dictionary, a: Dictionary, b: Dictionary, wynik: Dictionary) -> void:
	_dodaj_wynik_domeny(domeny, str(a.balance_role), str(b.balance_role), bool(wynik.wygral_a))
	_dodaj_wynik_domeny(domeny, str(b.balance_role), str(a.balance_role), not bool(wynik.wygral_a))


func _dodaj_wynik_domeny(domeny: Dictionary, rola_a: String, rola_b: String, wygrana_a: bool) -> void:
	var klucz: String = "%s|%s" % [rola_a, rola_b]
	if not domeny.has(klucz):
		domeny[klucz] = {"rola_a": rola_a, "rola_b": rola_b, "walki": 0, "wygrane": 0}
	var statystyki: Dictionary = domeny[klucz]
	statystyki["walki"] = int(statystyki.walki) + 1
	statystyki["wygrane"] = int(statystyki.wygrane) + int(wygrana_a)


func _zapisz_podsumowanie(jednostki: Array[Dictionary], podsumowanie: Dictionary) -> bool:
	var raport: FileAccess = FileAccess.open(RAPORT_PODSUMOWANIE, FileAccess.WRITE)
	if raport == null:
		push_error("Nie mozna zapisac raportu: %s" % RAPORT_PODSUMOWANIE)
		return false
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray([
		"frakcja", "id", "nazwa", "domyslna_liczebnosc", "walki", "wygrane", "przegrane",
		"wygrane_proc", "srednie_pozostale_hp_proc", "srednia_liczba_rund", "wygrane_proc_domyslne_liczebnosci"
	]))
	for jednostka in jednostki:
		var statystyki: Dictionary = podsumowanie[str(jednostka.id)]
		var walki: int = int(statystyki.walki)
		var domyslne_walki: int = int(statystyki.domyslne_walki)
		raport.store_csv_line(PackedStringArray([
			str(jednostka.faction_id), str(jednostka.id), str(jednostka.name), str(jednostka.count),
			str(walki), str(statystyki.wygrane), str(walki - int(statystyki.wygrane)),
			"%.2f" % (100.0 * float(statystyki.wygrane) / float(walki)),
			"%.2f" % (float(statystyki.suma_hp_proc) / float(walki)),
			"%.2f" % (float(statystyki.suma_rund) / float(walki)),
			"%.2f" % (100.0 * float(statystyki.domyslne_wygrane) / float(domyslne_walki))
		]))
	raport.close()
	return true


func _zapisz_role(jednostki: Array[Dictionary], role_jednostek: Dictionary) -> bool:
	var raport: FileAccess = FileAccess.open(RAPORT_ROLE, FileAccess.WRITE)
	if raport == null:
		push_error("Nie mozna zapisac raportu: %s" % RAPORT_ROLE)
		return false
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray([
		"frakcja", "id", "nazwa", "rola", "domyslna_liczebnosc", "walki", "wygrane_proc",
		"walki_w_roli", "wygrane_w_roli_proc"
	]))
	for jednostka in jednostki:
		var statystyki: Dictionary = role_jednostek[str(jednostka.id)]
		var rola: String = str(jednostka.balance_role)
		var wygrane_proc: float = 100.0 * float(statystyki.wygrane) / float(statystyki.walki)
		var wygrane_w_roli_proc: float = 100.0 * float(statystyki.wygrane_w_roli) / float(statystyki.walki_w_roli)
		raport.store_csv_line(PackedStringArray([
			str(jednostka.faction_id), str(jednostka.id), str(jednostka.name), rola, str(jednostka.count),
			str(statystyki.walki), "%.2f" % wygrane_proc, str(statystyki.walki_w_roli), "%.2f" % wygrane_w_roli_proc
		]))
	raport.close()
	return true


func _zapisz_domeny(domeny: Dictionary) -> bool:
	var raport: FileAccess = FileAccess.open(RAPORT_DOMENY, FileAccess.WRITE)
	if raport == null:
		push_error("Nie mozna zapisac raportu: %s" % RAPORT_DOMENY)
		return false
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray(["rola_a", "rola_b", "walki", "wygrane_a_proc", "oczekiwanie", "status"]))
	var klucze: Array = domeny.keys()
	klucze.sort()
	var naruszenia: int = 0
	for klucz in klucze:
		var statystyki: Dictionary = domeny[klucz]
		var wygrane_proc: float = 100.0 * float(statystyki.wygrane) / float(statystyki.walki)
		var zakres: Vector2 = _zakres_domeny(str(statystyki.rola_a), str(statystyki.rola_b))
		var oczekiwanie: String = "BRAK" if zakres.x < 0.0 else "%.0f-%.0f%%" % [zakres.x, zakres.y]
		var status: String = "INFO"
		if zakres.x >= 0.0:
			status = "OK" if wygrane_proc >= zakres.x and wygrane_proc <= zakres.y else "NARUSZENIE"
		if status == "NARUSZENIE":
			naruszenia += 1
		raport.store_csv_line(PackedStringArray([
			str(statystyki.rola_a), str(statystyki.rola_b), str(statystyki.walki),
			"%.2f" % wygrane_proc, oczekiwanie, status
		]))
	raport.close()
	if naruszenia > 0:
		push_warning("Zakresy domen maja %d odchylen." % naruszenia)
	return true


func _zakres_domeny(rola_a: String, rola_b: String) -> Vector2:
	if rola_a == rola_b:
		return Vector2(-1.0, -1.0)
	return Vector2(-1.0, -1.0)


func _uruchom_smoke_test() -> void:
	assert(MatematykaWalkiScript.pojemnosc_hp(10, 4) == 40 and MatematykaWalkiScript.pojemnosc_hp(10, 5) == 50)
	var pelny_oddzial: Dictionary = {"base_hp": 22, "count": 4}
	MatematykaWalkiScript.ustaw_pelne_hp(pelny_oddzial)
	MatematykaWalkiScript.odswiez_stan_hp(pelny_oddzial)
	assert(int(pelny_oddzial.current_hp) == 22)
	assert(_zakres_domeny("dystansowa", "wojownik") == Vector2(-1.0, -1.0))
	assert(is_equal_approx(MatematykaWalkiScript.mnoznik_ataku_obrony(20, 14), 1.3))
	assert(is_equal_approx(MatematykaWalkiScript.mnoznik_ataku_obrony(14, 20), 0.85))
	assert(MatematykaWalkiScript.oblicz_obrazenia({"atk": 0, "dmg_min": 4, "dmg_max": 4, "count": 5}, {"def": 0}) == 20)
	var wynik: Dictionary = _symuluj(
		{"id": "a", "hp": 10, "atk": 5, "dmg_min": 10, "dmg_max": 10, "def": 0, "speed": 2}, 1,
		{"id": "b", "hp": 5, "atk": 0, "dmg_min": 1, "dmg_max": 1, "def": 0, "speed": 1}, 1
	)
	assert(bool(wynik.wygral_a) and int(wynik.ataki) == 1, "Szybszy oddzial musi zakonczyc walke pierwszym smiertelnym atakiem.")
