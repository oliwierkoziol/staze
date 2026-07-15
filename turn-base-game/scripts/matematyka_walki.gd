class_name MatematykaWalki

const MNOZNIK_TEMPA_WALKI := 1.43
const MNOZNIK_TEMPA_DYSTANSU_I_WSPARCIA := 1.25


static func oblicz_obrazenia(atakujacy: Dictionary, cel: Dictionary, mnoznik: float = 1.0) -> int:
	var liczebnosc: int = max(1, int(atakujacy.get("count", 1)))
	var efektywna_liczebnosc: float = sqrt(float(liczebnosc))
	var obrazenia: float = max(1.0, float(atakujacy.get("dmg", 1)) * mnoznik)
	var obrona: float = float(cel.get("def", 0))
	var mnoznik_obrony: float = 100.0 / (100.0 + obrona * 10.0) if obrona >= 0.0 else 1.0 + abs(obrona) * 0.1
	var rola: String = str(atakujacy.get("balance_role", ""))
	var tempo: float = MNOZNIK_TEMPA_DYSTANSU_I_WSPARCIA if rola in ["dystansowa", "wsparcie_kontrola"] else MNOZNIK_TEMPA_WALKI
	return max(int(ceil(efektywna_liczebnosc)), int(obrazenia * efektywna_liczebnosc * mnoznik_obrony * 1.35 * tempo))


static func odswiez_stan_hp(unit: Dictionary) -> void:
	var hp_jednostki: int = max(1, int(unit.get("base_hp", unit.get("max_hp", 1))))
	var hp_oddzialu: int = max(0, int(unit.get("current_total_hp", hp_jednostki * max(1, int(unit.get("count", 1))))))
	unit["max_hp"] = hp_jednostki
	unit["max_total_hp"] = max(hp_jednostki, int(unit.get("max_total_hp", hp_jednostki * max(1, int(unit.get("count", 1))))))
	unit["current_total_hp"] = hp_oddzialu
	if hp_oddzialu <= 0:
		unit["count"] = 0
		unit["current_hp"] = 0
		return
	unit["count"] = int(ceil(float(hp_oddzialu) / float(hp_jednostki)))
	var reszta: int = hp_oddzialu % hp_jednostki
	unit["current_hp"] = hp_jednostki if reszta == 0 else reszta
