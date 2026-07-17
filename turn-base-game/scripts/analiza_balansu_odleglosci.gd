extends SceneTree

const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const MatematykaWalkiScript = preload("res://scripts/matematyka_walki.gd")
const ODLEGLOSCI: Array[int] = [1, 3, 5, 7, 9, 12]
const LICZEBNOSCI_1V1: Array[int] = [1, 3, 5, 10, 20, 50]
const LICZEBNOSCI_ARMII: Array[int] = [15, 20, 50, 75, 100]
const ROZNICE_LICZEBNOSCI: Array[int] = [1, 3, 5]
const ROLE_WRECZ: Array[String] = ["obronca", "wojownik", "uderzeniowa"]
const PROFILE_SKLADU: Array[Dictionary] = [
	{"id": "rowny", "wagi": [1, 1, 1, 1]},
	{"id": "dominanta_1", "wagi": [4, 1, 1, 1]},
	{"id": "dominanta_2", "wagi": [1, 4, 1, 1]},
	{"id": "dominanta_3", "wagi": [1, 1, 4, 1]},
	{"id": "dominanta_4", "wagi": [1, 1, 1, 4]}
]
const WARIANTY_LICZEBNOSCI: Array[int] = [-1, 0, 1]
const GLEBOKOSCI_FORMACJI: Array[int] = [1, 2, 3]
const BAZOWA_SKALA_ARMII := 20.0
const MIN_WR := 43.0
const MAX_WR := 57.0
const RAPORT_1V1 := "res://raporty/balans_1v1_odleglosc.csv"
const RAPORT_DOMEN_ODLEGLOSCI := "res://raporty/balans_domen_odleglosc.csv"
const RAPORT_FRAKCJI := "res://raporty/balans_frakcji_odleglosc.csv"
const RAPORT_PODSUMOWANIA_FRAKCJI := "res://raporty/podsumowanie_frakcji.csv"
const RAPORT_WPLYWU_LICZEBNOSCI := "res://raporty/wplyw_liczebnosci_armii.csv"
const RAPORT_SCENARIUSZY := "res://raporty/balans_scenariuszy.csv"


func _initialize() -> void:
	seed(12345)
	_smoke_test()
	var frakcje: Array[Dictionary] = []
	for frakcja in UnitTypeLibraryScript.get_factions():
		if str(frakcja.get("id", "")) != "testowa":
			frakcje.append(frakcja)
	_zapisz_domeny_odleglosci(_zapisz_1v1(frakcje))
	_zapisz_frakcje(frakcje)
	_zapisz_wplyw_liczebnosci(frakcje)
	_zapisz_scenariusze(frakcje)
	print("Analiza odleglosci zakonczona: %s, %s" % [RAPORT_1V1, RAPORT_FRAKCJI])
	quit()


func _zapisz_scenariusze(frakcje: Array[Dictionary]) -> void:
	var dane: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/scenarios.json"))
	var raport: FileAccess = FileAccess.open(RAPORT_SCENARIUSZY, FileAccess.WRITE)
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray(["scenariusz", "frakcja_gracza", "frakcja_wroga", "walki", "szacowany_wr_gracza_proc", "status"]))
	for scenariusz in dane.get("scenarios", []):
		var gracz: Dictionary = _sklad_scenariusza(frakcje, str(scenariusz.player_faction), scenariusz.player_units)
		var wrog: Dictionary = _sklad_scenariusza(frakcje, str(scenariusz.enemy_faction), scenariusz.enemy_units)
		var suma_wr: float = 0.0
		var walki: int = 0
		for odleglosc in ODLEGLOSCI:
			for glebokosc in GLEBOKOSCI_FORMACJI:
				for wariant_gracza in WARIANTY_LICZEBNOSCI:
					for wariant_wroga in WARIANTY_LICZEBNOSCI:
						var wynik_a: Dictionary = _walka_frakcji(gracz, wrog, odleglosc, wariant_gracza, glebokosc, wariant_wroga)
						var wynik_b: Dictionary = _walka_frakcji(wrog, gracz, odleglosc, wariant_wroga, glebokosc, wariant_gracza)
						suma_wr += 50.0 + (float(wynik_a.hp_a_proc) - float(wynik_a.hp_b_proc)) / 2.0
						suma_wr += 50.0 + (float(wynik_b.hp_b_proc) - float(wynik_b.hp_a_proc)) / 2.0
						walki += 2
		var procent: float = suma_wr / walki
		var status: String = "OK" if procent >= MIN_WR and procent <= MAX_WR else ("PRZEWAGA_GRACZA" if procent > MAX_WR else "PRZEWAGA_WROGA")
		raport.store_csv_line(PackedStringArray([str(scenariusz.id), str(gracz.id), str(wrog.id), str(walki), "%.2f" % procent, status]))
	raport.close()


func _sklad_scenariusza(frakcje: Array[Dictionary], id_frakcji: String, wpisy: Array) -> Dictionary:
	var wynik: Dictionary = {"id": id_frakcji, "units": []}
	for frakcja in frakcje:
		if str(frakcja.id) != id_frakcji:
			continue
		for wpis in wpisy:
			for unit in frakcja.units:
				if str(unit.id) == str(wpis.type_id):
					var kopia: Dictionary = unit.duplicate(true)
					kopia.count = int(wpis.count)
					for statystyka in ["hp", "atk", "dmg_min", "dmg_max", "def"]:
						if wpis.has(statystyka):
							kopia[statystyka] = int(wpis[statystyka])
					wynik.units.append(kopia)
	return wynik


func _zapisz_1v1(frakcje: Array[Dictionary]) -> Array[Dictionary]:
	var raport: FileAccess = FileAccess.open(RAPORT_1V1, FileAccess.WRITE)
	var wyniki: Array[Dictionary] = []
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray(["frakcja_a", "id_a", "liczebnosc_a", "frakcja_b", "id_b", "liczebnosc_b", "odleglosc", "zwyciezca", "rundy", "hp_a_proc", "hp_b_proc"]))
	for frakcja_a in frakcje:
		for a in frakcja_a.units:
			for frakcja_b in frakcje:
				for b in frakcja_b.units:
					for odleglosc in ODLEGLOSCI:
						for liczebnosc in LICZEBNOSCI_1V1:
							var oddzial_a: Dictionary = a.duplicate(true)
							var oddzial_b: Dictionary = b.duplicate(true)
							oddzial_a.count = liczebnosc
							oddzial_b.count = liczebnosc
							var wynik: Dictionary = _walka_1v1(oddzial_a, oddzial_b, odleglosc)
							wyniki.append({"rola_a": str(a.balance_role), "rola_b": str(b.balance_role), "odleglosc": odleglosc, "wr_a": 50.0 + (float(wynik.hp_a_proc) - float(wynik.hp_b_proc)) / 2.0})
							raport.store_csv_line(PackedStringArray([
								str(frakcja_a.id), str(a.id), str(liczebnosc), str(frakcja_b.id), str(b.id), str(liczebnosc),
								str(odleglosc), str(wynik.zwyciezca), str(wynik.rundy), "%.2f" % wynik.hp_a_proc, "%.2f" % wynik.hp_b_proc
							]))
	raport.close()
	return wyniki


func _zapisz_domeny_odleglosci(wyniki: Array[Dictionary]) -> void:
	var grupy: Dictionary = {}
	for wynik in wyniki:
		var role_grupy: PackedStringArray = _grupa_domeny(str(wynik.rola_a), str(wynik.rola_b))
		var klucz: String = "%s|%s|%d" % [role_grupy[0], role_grupy[1], int(wynik.odleglosc)]
		if not grupy.has(klucz):
			grupy[klucz] = {"rola_a": role_grupy[0], "rola_b": role_grupy[1], "odleglosc": int(wynik.odleglosc), "walki": 0, "suma_wr": 0.0}
		grupy[klucz].walki = int(grupy[klucz].walki) + 1
		grupy[klucz].suma_wr = float(grupy[klucz].suma_wr) + float(wynik.wr_a)
	var raport: FileAccess = FileAccess.open(RAPORT_DOMEN_ODLEGLOSCI, FileAccess.WRITE)
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray(["rola_a", "rola_b", "odleglosc", "walki", "szacowany_wr_a_proc", "oczekiwanie", "status"]))
	var klucze: Array = grupy.keys()
	klucze.sort()
	for klucz in klucze:
		var grupa: Dictionary = grupy[klucz]
		var wr: float = float(grupa.suma_wr) / int(grupa.walki)
		var zakres: Vector2 = _zakres_domeny_odleglosci(str(grupa.rola_a), str(grupa.rola_b), int(grupa.odleglosc))
		var oczekiwanie: String = "BRAK" if zakres.x < 0.0 else "%.0f-%.0f%%" % [zakres.x, zakres.y]
		var status: String = "INFO" if zakres.x < 0.0 else ("OK" if wr >= zakres.x and wr <= zakres.y else "NARUSZENIE")
		raport.store_csv_line(PackedStringArray([str(grupa.rola_a), str(grupa.rola_b), str(grupa.odleglosc), str(grupa.walki), "%.2f" % wr, oczekiwanie, status]))
	raport.close()


func _zakres_domeny_odleglosci(rola_a: String, rola_b: String, odleglosc: int) -> Vector2:
	if rola_a == "wsparcie_kontrola" and rola_b == "pozostale":
		return Vector2(20.0, 50.0)
	if rola_b == "wsparcie_kontrola" and rola_a == "pozostale":
		return Vector2(50.0, 80.0)
	if rola_a == "dystansowa" and rola_b == "wrecz":
		return Vector2(25.0, 50.0) if odleglosc <= 3 else (Vector2(35.0, 60.0) if odleglosc <= 7 else Vector2(45.0, 65.0))
	if rola_b == "dystansowa" and rola_a == "wrecz":
		var zakres_przeciwnika: Vector2 = _zakres_domeny_odleglosci(rola_b, rola_a, odleglosc)
		return Vector2(100.0 - zakres_przeciwnika.y, 100.0 - zakres_przeciwnika.x)
	return Vector2(-1.0, -1.0)


func _grupa_domeny(rola_a: String, rola_b: String) -> PackedStringArray:
	if rola_a == "wsparcie_kontrola" and rola_b != "wsparcie_kontrola":
		return PackedStringArray([rola_a, "pozostale"])
	if rola_b == "wsparcie_kontrola" and rola_a != "wsparcie_kontrola":
		return PackedStringArray(["pozostale", rola_b])
	if rola_a == "dystansowa" and ROLE_WRECZ.has(rola_b):
		return PackedStringArray([rola_a, "wrecz"])
	if rola_b == "dystansowa" and ROLE_WRECZ.has(rola_a):
		return PackedStringArray(["wrecz", rola_b])
	return PackedStringArray([rola_a, rola_b])


func _zapisz_frakcje(frakcje: Array[Dictionary]) -> void:
	var raport: FileAccess = FileAccess.open(RAPORT_FRAKCJI, FileAccess.WRITE)
	var wyniki: Array[Dictionary] = []
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray(["frakcja_a", "frakcja_b", "skala_armii_a", "skala_armii_b", "sklad_a", "sklad_b", "odleglosc", "glebokosc_formacji", "zwyciezca", "rundy", "oddzialy_a", "oddzialy_b", "hp_a_proc", "hp_b_proc"]))
	for frakcja_a in frakcje:
		for frakcja_b in frakcje:
			if str(frakcja_a.id) == str(frakcja_b.id):
				continue
			for liczebnosc_a in LICZEBNOSCI_ARMII:
				for liczebnosc_b in LICZEBNOSCI_ARMII:
					for profil_a in PROFILE_SKLADU:
						var sklad_a: Dictionary = _sklad_armii(frakcja_a, liczebnosc_a, profil_a)
						for profil_b in PROFILE_SKLADU:
							var sklad_b: Dictionary = _sklad_armii(frakcja_b, liczebnosc_b, profil_b)
							for odleglosc in ODLEGLOSCI:
								for glebokosc in GLEBOKOSCI_FORMACJI:
									var wynik: Dictionary = _walka_frakcji(sklad_a, sklad_b, odleglosc, 0, glebokosc)
									wyniki.append({"a": str(frakcja_a.id), "b": str(frakcja_b.id), "liczebnosc": liczebnosc_a if liczebnosc_a == liczebnosc_b else -1, "odleglosc": odleglosc, "wr_a": 50.0 + (float(wynik.hp_a_proc) - float(wynik.hp_b_proc)) / 2.0})
									raport.store_csv_line(PackedStringArray([
										str(frakcja_a.id), str(frakcja_b.id), str(liczebnosc_a), str(liczebnosc_b), _nazwa_profilu(sklad_a, profil_a), _nazwa_profilu(sklad_b, profil_b), str(odleglosc), str(glebokosc), str(wynik.zwyciezca), str(wynik.rundy),
										str(wynik.oddzialy_a), str(wynik.oddzialy_b), "%.2f" % wynik.hp_a_proc, "%.2f" % wynik.hp_b_proc
									]))
	raport.close()
	_zapisz_podsumowanie_frakcji(frakcje, wyniki)


func _zapisz_podsumowanie_frakcji(frakcje: Array[Dictionary], wyniki: Array[Dictionary]) -> void:
	var raport: FileAccess = FileAccess.open(RAPORT_PODSUMOWANIA_FRAKCJI, FileAccess.WRITE)
	raport.store_string("\ufeff")
	var naglowek: PackedStringArray = PackedStringArray(["frakcja_a", "frakcja_b"])
	for liczebnosc in LICZEBNOSCI_ARMII:
		naglowek.append("szacowany_wr_a_n%d_proc" % liczebnosc)
	naglowek.append_array(PackedStringArray(["szacowany_wr_a_d1_proc", "szacowany_wr_a_d12_proc", "szacowany_wr_a_lacznie_proc", "status"]))
	raport.store_csv_line(naglowek)
	for indeks_a in range(frakcje.size()):
		for indeks_b in range(indeks_a + 1, frakcje.size()):
			var id_a: String = str(frakcje[indeks_a].id)
			var id_b: String = str(frakcje[indeks_b].id)
			var wiersz: PackedStringArray = PackedStringArray([id_a, id_b])
			for liczebnosc in LICZEBNOSCI_ARMII:
				wiersz.append("%.2f" % _sredni_wr(wyniki, id_a, id_b, "liczebnosc", liczebnosc))
			wiersz.append("%.2f" % _sredni_wr(wyniki, id_a, id_b, "odleglosc", 1))
			wiersz.append("%.2f" % _sredni_wr(wyniki, id_a, id_b, "odleglosc", 12))
			var procent: float = _sredni_wr(wyniki, id_a, id_b)
			var status: String = "OK" if procent >= MIN_WR and procent <= MAX_WR else ("PRZEWAGA_A" if procent > MAX_WR else "PRZEWAGA_B")
			wiersz.append("%.2f" % procent)
			wiersz.append(status)
			raport.store_csv_line(wiersz)
	raport.close()


func _sredni_wr(wyniki: Array[Dictionary], id_a: String, id_b: String, filtr: String = "", wartosc: int = 0) -> float:
	var suma: float = 0.0
	var walki: int = 0
	for wynik in wyniki:
		if not [id_a, id_b].has(str(wynik.a)) or not [id_a, id_b].has(str(wynik.b)):
			continue
		if int(wynik.liczebnosc) < 0:
			continue
		if filtr != "" and int(wynik[filtr]) != wartosc:
			continue
		suma += float(wynik.wr_a) if str(wynik.a) == id_a else 100.0 - float(wynik.wr_a)
		walki += 1
	return suma / maxi(1, walki)


func _sklad_armii(frakcja: Dictionary, liczebnosc: int, profil: Dictionary) -> Dictionary:
	var wynik: Dictionary = {"id": str(frakcja.id), "units": []}
	var wagi: Array = profil.wagi
	var suma_wag: int = 0
	for waga in wagi:
		suma_wag += int(waga)
	for unit_index in range(frakcja.units.size()):
		var unit: Dictionary = frakcja.units[unit_index].duplicate(true)
		var udzial_profilu: float = float(int(wagi[unit_index]) * frakcja.units.size()) / float(suma_wag)
		unit.count = maxi(1, int(round(float(unit.count) * float(liczebnosc) / BAZOWA_SKALA_ARMII * udzial_profilu)))
		wynik.units.append(unit)
	return wynik


func _nazwa_profilu(sklad: Dictionary, profil: Dictionary) -> String:
	if str(profil.id) == "rowny":
		return "rowny"
	var indeks: int = int(str(profil.id).get_slice("_", 1)) - 1
	return "dominanta_%s" % str(sklad.units[indeks].id)


func _zapisz_wplyw_liczebnosci(frakcje: Array[Dictionary]) -> void:
	var raport: FileAccess = FileAccess.open(RAPORT_WPLYWU_LICZEBNOSCI, FileAccess.WRITE)
	raport.store_string("\ufeff")
	raport.store_csv_line(PackedStringArray(["frakcja", "skala_mniejszej_armii", "skala_wiekszej_armii", "roznica_skali", "walki", "szacowany_wr_wiekszej_armii_proc"]))
	for frakcja in frakcje:
		for mniejsza in [15, 20, 50, 75]:
			for roznica in ROZNICE_LICZEBNOSCI:
				var suma_wr: float = 0.0
				var walki: int = 0
				for profil in PROFILE_SKLADU:
					var slabsza: Dictionary = _sklad_armii(frakcja, mniejsza, profil)
					var silniejsza: Dictionary = _sklad_armii(frakcja, mniejsza + roznica, profil)
					for odleglosc in ODLEGLOSCI:
						for glebokosc in GLEBOKOSCI_FORMACJI:
							var wynik_a: Dictionary = _walka_frakcji(silniejsza, slabsza, odleglosc, 0, glebokosc)
							var wynik_b: Dictionary = _walka_frakcji(slabsza, silniejsza, odleglosc, 0, glebokosc)
							suma_wr += 50.0 + (float(wynik_a.hp_a_proc) - float(wynik_a.hp_b_proc)) / 2.0
							suma_wr += 50.0 + (float(wynik_b.hp_b_proc) - float(wynik_b.hp_a_proc)) / 2.0
							walki += 2
				raport.store_csv_line(PackedStringArray([str(frakcja.id), str(mniejsza), str(mniejsza + roznica), str(roznica), str(walki), "%.2f" % (suma_wr / walki)]))
	raport.close()


func _walka_1v1(szablon_a: Dictionary, szablon_b: Dictionary, odleglosc: int) -> Dictionary:
	var a: Dictionary = _oddzial(szablon_a, "a", 0)
	var b: Dictionary = _oddzial(szablon_b, "b", odleglosc)
	var rundy: int = 0
	while int(a.count) > 0 and int(b.count) > 0 and rundy < 100:
		rundy += 1
		var kolejnosc: Array[Dictionary] = [a, b]
		kolejnosc.sort_custom(_szybszy)
		for aktywny in kolejnosc:
			var cel: Dictionary = b if str(aktywny.side) == "a" else a
			_tura(aktywny, cel, 0, odleglosc)
	var zwyciezca: String = str(a.id) if int(a.count) > 0 else str(b.id)
	return {"zwyciezca": zwyciezca, "rundy": rundy, "hp_a_proc": _hp_proc(a), "hp_b_proc": _hp_proc(b)}


func _walka_frakcji(frakcja_a: Dictionary, frakcja_b: Dictionary, odleglosc: int, wariant: int, glebokosc: int, wariant_b: int = 999) -> Dictionary:
	var armia: Array[Dictionary] = []
	var korekta_b: int = wariant if wariant_b == 999 else wariant_b
	for szablon in frakcja_a.units:
		var oddzial_a: Dictionary = szablon.duplicate(true)
		oddzial_a.count = maxi(1, int(oddzial_a.count) + wariant)
		armia.append(_oddzial(oddzial_a, "a", mini(glebokosc, int(odleglosc / 2)) if int(szablon.get("attack_range", 1)) <= 1 else 0))
	for szablon in frakcja_b.units:
		var oddzial_b: Dictionary = szablon.duplicate(true)
		oddzial_b.count = maxi(1, int(oddzial_b.count) + korekta_b)
		armia.append(_oddzial(oddzial_b, "b", maxi(odleglosc - glebokosc, int(odleglosc / 2)) if int(szablon.get("attack_range", 1)) <= 1 else odleglosc))
	var hp_start_a: int = _suma_hp(armia, "a")
	var hp_start_b: int = _suma_hp(armia, "b")
	var rundy: int = 0
	while _zyje_strona(armia, "a") and _zyje_strona(armia, "b") and rundy < 100:
		rundy += 1
		var kolejnosc: Array[Dictionary] = armia.duplicate()
		kolejnosc.sort_custom(_szybszy)
		for aktywny in kolejnosc:
			if int(aktywny.count) <= 0:
				continue
			var cel: Dictionary = _najblizszy_cel(aktywny, armia)
			if not cel.is_empty():
				_tura(aktywny, cel, 0, odleglosc)
	var hp_a: int = _suma_hp(armia, "a")
	var hp_b: int = _suma_hp(armia, "b")
	return {
		"zwyciezca": str(frakcja_a.id) if hp_a > 0 else str(frakcja_b.id), "rundy": rundy,
		"oddzialy_a": _liczba_oddzialow(armia, "a"), "oddzialy_b": _liczba_oddzialow(armia, "b"),
		"hp_a_proc": 100.0 * hp_a / hp_start_a, "hp_b_proc": 100.0 * hp_b / hp_start_b
	}


func _oddzial(szablon: Dictionary, strona: String, pozycja: int) -> Dictionary:
	var wynik: Dictionary = szablon.duplicate(true)
	wynik["side"] = strona
	wynik["position"] = pozycja
	wynik["base_hp"] = int(szablon.hp)
	MatematykaWalkiScript.ustaw_pelne_hp(wynik)
	return wynik


func _tura(atakujacy: Dictionary, cel: Dictionary, min_pozycja: int, max_pozycja: int) -> void:
	if int(atakujacy.count) <= 0 or int(cel.count) <= 0:
		return
	var dystans: int = absi(int(cel.position) - int(atakujacy.position))
	var zasieg: int = maxi(1, int(atakujacy.get("attack_range", 1)))
	if dystans > zasieg:
		var ruch: int = mini(int(atakujacy.get("move_range", 0)), dystans - zasieg)
		atakujacy.position = clampi(int(atakujacy.position) + ruch * signi(int(cel.position) - int(atakujacy.position)), min_pozycja, max_pozycja)
		dystans = absi(int(cel.position) - int(atakujacy.position))
	if dystans <= zasieg:
		cel.current_total_hp = maxi(0, int(cel.current_total_hp) - MatematykaWalkiScript.oblicz_obrazenia(atakujacy, cel))
		MatematykaWalkiScript.odswiez_stan_hp(cel)
		if zasieg > 1 and int(cel.count) > 0 and dystans < zasieg:
			var odskok: int = mini(int(atakujacy.get("move_range", 0)), zasieg - dystans)
			atakujacy.position = clampi(int(atakujacy.position) - odskok * signi(int(cel.position) - int(atakujacy.position)), min_pozycja, max_pozycja)


func _najblizszy_cel(atakujacy: Dictionary, armia: Array[Dictionary]) -> Dictionary:
	var najlepszy: Dictionary = {}
	var odleglosc: int = 100000
	for kandydat in armia:
		if str(kandydat.side) == str(atakujacy.side) or int(kandydat.count) <= 0:
			continue
		var nowa: int = absi(int(kandydat.position) - int(atakujacy.position))
		if nowa < odleglosc or (nowa == odleglosc and int(kandydat.current_total_hp) < int(najlepszy.get("current_total_hp", 100000))):
			najlepszy = kandydat
			odleglosc = nowa
	return najlepszy


func _szybszy(a: Dictionary, b: Dictionary) -> bool:
	if int(a.speed) == int(b.speed):
		return str(a.id) < str(b.id)
	return int(a.speed) > int(b.speed)


func _zyje_strona(armia: Array[Dictionary], strona: String) -> bool:
	return _liczba_oddzialow(armia, strona) > 0


func _liczba_oddzialow(armia: Array[Dictionary], strona: String) -> int:
	var wynik: int = 0
	for unit in armia:
		wynik += int(str(unit.side) == strona and int(unit.count) > 0)
	return wynik


func _suma_hp(armia: Array[Dictionary], strona: String) -> int:
	var wynik: int = 0
	for unit in armia:
		if str(unit.side) == strona:
			wynik += int(unit.current_total_hp)
	return wynik


func _hp_proc(unit: Dictionary) -> float:
	return 100.0 * float(unit.current_total_hp) / float(unit.max_total_hp)


func _smoke_test() -> void:
	var dystansowy: Dictionary = {"id": "d", "hp": 10, "atk": 5, "dmg_min": 5, "dmg_max": 5, "def": 0, "speed": 5, "count": 1, "move_range": 2, "attack_range": 4, "balance_role": "dystansowa"}
	var wrecz: Dictionary = {"id": "w", "hp": 10, "atk": 5, "dmg_min": 5, "dmg_max": 5, "def": 0, "speed": 4, "count": 1, "move_range": 2, "attack_range": 1, "balance_role": "wojownik"}
	assert(int(_walka_1v1(dystansowy, wrecz, 7).rundy) >= int(_walka_1v1(dystansowy, wrecz, 1).rundy))
