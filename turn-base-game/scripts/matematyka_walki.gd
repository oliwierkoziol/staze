class_name MatematykaWalki

const MNOZNIK_TEMPA_WALKI := 1.43
const MNOZNIK_TEMPA_DYSTANSU_I_WSPARCIA := 1.25
const WYKLADNIK_HP_LICZEBNOSCI := 1.00
const WYKLADNIK_DMG_LICZEBNOSCI := 0.40
const MNOZNIK_DYSTANSOWY_BLISKO := 0.80
const MNOZNIK_DYSTANSOWY_MAKS := 1.40


static func oblicz_obrazenia(atakujacy: Dictionary, cel: Dictionary, mnoznik: float = 1.0, odleglosc: int = 1) -> int:
	var liczebnosc: int = max(1, int(atakujacy.get("count", 1)))
	var efektywna_liczebnosc: float = pow(float(liczebnosc), WYKLADNIK_DMG_LICZEBNOSCI)
	var obrazenia: float = max(1.0, float(atakujacy.get("dmg", 1)) * mnoznik * float(atakujacy.get("faction_damage_multiplier", 1.0)) * mnoznik_dystansu(atakujacy, odleglosc))
	var obrona: float = float(cel.get("def", 0))
	var mnoznik_obrony: float = 100.0 / (100.0 + obrona * 10.0) if obrona >= 0.0 else 1.0 + abs(obrona) * 0.1
	var rola: String = str(atakujacy.get("balance_role", ""))
	var tempo: float = MNOZNIK_TEMPA_DYSTANSU_I_WSPARCIA if rola in ["dystansowa", "wsparcie_kontrola"] else MNOZNIK_TEMPA_WALKI
	return max(int(ceil(efektywna_liczebnosc)), int(round(obrazenia * efektywna_liczebnosc * mnoznik_obrony * 1.35 * tempo)))


static func mnoznik_dystansu(atakujacy: Dictionary, odleglosc: int) -> float:
	var zasieg: int = maxi(1, int(atakujacy.get("attack_range", 1)))
	var tryb_ataku: String = str(atakujacy.get("attack_mode", "ranged" if str(atakujacy.get("balance_role", "")) == "dystansowa" else "melee"))
	if tryb_ataku != "ranged" or zasieg <= 1:
		return 1.0
	var udzial_zasiegu: float = clampf(float(odleglosc - 1) / float(zasieg - 1), 0.0, 1.0)
	return lerpf(MNOZNIK_DYSTANSOWY_BLISKO, MNOZNIK_DYSTANSOWY_MAKS, udzial_zasiegu)


static func pojemnosc_hp(hp_jednostki: int, liczebnosc: int) -> int:
	return 0 if liczebnosc <= 0 else maxi(hp_jednostki, int(round(hp_jednostki * pow(float(liczebnosc), WYKLADNIK_HP_LICZEBNOSCI))))


static func ustaw_pelne_hp(unit: Dictionary) -> void:
	var hp_jednostki: int = maxi(1, int(unit.get("base_hp", unit.get("hp", 1))))
	var liczebnosc: int = maxi(1, int(unit.get("count", 1)))
	unit["base_hp"] = hp_jednostki
	unit["max_count"] = liczebnosc
	unit["max_hp"] = hp_jednostki
	unit["max_total_hp"] = pojemnosc_hp(hp_jednostki, liczebnosc)
	unit["current_total_hp"] = int(unit.max_total_hp)
	unit["current_hp"] = hp_jednostki


static func odswiez_stan_hp(unit: Dictionary) -> void:
	var hp_jednostki: int = max(1, int(unit.get("base_hp", unit.get("max_hp", 1))))
	var maksymalna_liczebnosc: int = maxi(1, int(unit.get("max_count", unit.get("count", 1))))
	var maksymalne_hp: int = pojemnosc_hp(hp_jednostki, maksymalna_liczebnosc)
	var hp_oddzialu: int = clampi(int(unit.get("current_total_hp", maksymalne_hp)), 0, maksymalne_hp)
	unit["max_hp"] = hp_jednostki
	unit["max_count"] = maksymalna_liczebnosc
	unit["max_total_hp"] = maksymalne_hp
	unit["current_total_hp"] = hp_oddzialu
	if hp_oddzialu <= 0:
		unit["count"] = 0
		unit["current_hp"] = 0
		return
	var zywi: int = 1
	while zywi < maksymalna_liczebnosc and hp_oddzialu > pojemnosc_hp(hp_jednostki, zywi):
		zywi += 1
	unit["count"] = zywi
	var dolny_prog: int = pojemnosc_hp(hp_jednostki, zywi - 1)
	var gorny_prog: int = pojemnosc_hp(hp_jednostki, zywi)
	var wypelnienie: float = float(hp_oddzialu - dolny_prog) / maxi(1, gorny_prog - dolny_prog)
	unit["current_hp"] = clampi(int(round(hp_jednostki * wypelnienie)), 1, hp_jednostki)
