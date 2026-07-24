class_name MatematykaWalki


static func mnoznik_ataku_obrony(atak: int, obrona: int) -> float:
	var roznica: int = atak - obrona
	if roznica >= 0:
		return 1.0 + 0.05 * mini(roznica, 60)
	return 1.0 - 0.025 * mini(-roznica, 28)


static func oblicz_obrazenia(atakujacy: Dictionary, cel: Dictionary, mnoznik: float = 1.0) -> int:
	var liczebnosc: int = maxi(0, int(atakujacy.get("count", 0)))
	if liczebnosc == 0:
		return 0
	var minimum: int = maxi(1, int(atakujacy.get("dmg_min", atakujacy.get("dmg", 1))))
	var maksimum: int = maxi(minimum, int(atakujacy.get("dmg_max", atakujacy.get("dmg", minimum))))
	var liczba_rzutow: int = mini(liczebnosc, 10)
	var bazowe_obrazenia: int = 0
	for _rzut in liczba_rzutow:
		bazowe_obrazenia += randi_range(minimum, maksimum)
	if liczebnosc > 10:
		bazowe_obrazenia = int(floor(float(bazowe_obrazenia * liczebnosc) / 10.0))
	var modyfikator: float = mnoznik_ataku_obrony(int(atakujacy.get("atk", 0)), int(cel.get("def", 0)))
	return maxi(1, int(floor(float(bazowe_obrazenia) * modyfikator * maxf(0.0, mnoznik))))


static func oblicz_zakres_obrazen(atakujacy: Dictionary, cel: Dictionary, mnoznik: float = 1.0) -> Vector2i:
	var liczebnosc: int = maxi(0, int(atakujacy.get("count", 0)))
	if liczebnosc == 0:
		return Vector2i.ZERO
	var minimum: int = maxi(1, int(atakujacy.get("dmg_min", atakujacy.get("dmg", 1))))
	var maksimum: int = maxi(minimum, int(atakujacy.get("dmg_max", atakujacy.get("dmg", minimum))))
	var modyfikator: float = mnoznik_ataku_obrony(int(atakujacy.get("atk", 0)), int(cel.get("def", 0))) * maxf(0.0, mnoznik)
	return Vector2i(
		maxi(1, int(floor(float(minimum * liczebnosc) * modyfikator))),
		maxi(1, int(floor(float(maksimum * liczebnosc) * modyfikator)))
	)


static func pojemnosc_hp(hp_jednostki: int, liczebnosc: int) -> int:
	return maxi(0, hp_jednostki) * maxi(0, liczebnosc)


static func ustaw_pelne_hp(unit: Dictionary) -> void:
	var hp_jednostki: int = maxi(1, int(unit.get("base_hp", unit.get("hp", 1))))
	var liczebnosc: int = maxi(0, int(unit.get("count", 0)))
	unit["base_hp"] = hp_jednostki
	unit["max_count"] = liczebnosc
	unit["max_hp"] = hp_jednostki
	unit["max_total_hp"] = pojemnosc_hp(hp_jednostki, liczebnosc)
	unit["current_total_hp"] = int(unit.max_total_hp)
	unit["current_hp"] = hp_jednostki if liczebnosc > 0 else 0


static func odswiez_stan_hp(unit: Dictionary) -> void:
	var hp_jednostki: int = maxi(1, int(unit.get("base_hp", unit.get("max_hp", 1))))
	var maksymalna_liczebnosc: int = maxi(0, int(unit.get("max_count", unit.get("count", 0))))
	var maksymalne_hp: int = pojemnosc_hp(hp_jednostki, maksymalna_liczebnosc)
	var hp_oddzialu: int = clampi(int(unit.get("current_total_hp", maksymalne_hp)), 0, maksymalne_hp)
	unit["max_hp"] = hp_jednostki
	unit["max_count"] = maksymalna_liczebnosc
	unit["max_total_hp"] = maksymalne_hp
	unit["current_total_hp"] = hp_oddzialu
	if hp_oddzialu == 0:
		unit["count"] = 0
		unit["current_hp"] = 0
		return
	unit["count"] = ceili(float(hp_oddzialu) / float(hp_jednostki))
	unit["current_hp"] = ((hp_oddzialu - 1) % hp_jednostki) + 1
