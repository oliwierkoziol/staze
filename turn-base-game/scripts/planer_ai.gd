class_name PlanerAI


const PROFILE: Dictionary = {
	"latwy": {"threat_weight": 0.35, "hazard_weight": 0.6, "casualty_weight": 45, "kill_bonus": 150, "target_value_weight": 0.02, "formation_weight": 0.25, "coordination_weight": 0.0, "decision_noise": 0.18},
	"sredni": {"threat_weight": 0.7, "hazard_weight": 0.9, "casualty_weight": 75, "kill_bonus": 400, "target_value_weight": 0.06, "formation_weight": 0.65, "coordination_weight": 0.4, "decision_noise": 0.05},
	"trudny": {"threat_weight": 1.0, "hazard_weight": 1.0, "casualty_weight": 90, "kill_bonus": 600, "target_value_weight": 0.1, "formation_weight": 1.0, "coordination_weight": 1.0, "decision_noise": 0.0},
}


static func pobierz_profil(trudnosc: String) -> Dictionary:
	return PROFILE.get(trudnosc, PROFILE["sredni"])


static func zastosuj_szum(unit: Dictionary, plan: Dictionary, round_number: int, trudnosc: String) -> int:
	var score: int = int(plan.get("score", 0))
	var noise: float = float(pobierz_profil(trudnosc).get("decision_noise", 0.0))
	if noise <= 0.0:
		return score
	var key: String = "%d:%d:%s:%s:%s:%s:%s" % [round_number, int(unit.id), plan.get("kind", ""), plan.get("skill_id", ""), plan.get("target_id", -1), plan.get("target_cell", Vector2i(-1, -1)), plan.get("path", [])]
	var direction: float = float(posmod(hash(key), 201) - 100) / 100.0
	return score + int(round(direction * maxf(30.0, absf(float(score)) * noise)))


static func wartosc_jednostki(unit: Dictionary) -> int:
	var average_damage: int = int(round((int(unit.get("dmg_min", 1)) + int(unit.get("dmg_max", 1))) / 2.0))
	return int(unit.get("current_total_hp", int(unit.get("hp", 1)) * int(unit.get("count", 1)))) + average_damage * int(unit.get("count", 1)) + int(unit.get("attack_range", 1)) * 20


static func czy_lepszy_plan(candidate: Dictionary, current: Dictionary) -> bool:
	var candidate_score: int = int(candidate.get("score", -1000000))
	var current_score: int = int(current.get("score", -1000000))
	if candidate_score != current_score:
		return candidate_score > current_score
	var candidate_key: String = "%s:%s:%s:%s" % [candidate.get("kind", ""), candidate.get("skill_id", ""), candidate.get("target_id", -1), candidate.get("target_cell", Vector2i(-1, -1))]
	var current_key: String = "%s:%s:%s:%s" % [current.get("kind", ""), current.get("skill_id", ""), current.get("target_id", -1), current.get("target_cell", Vector2i(-1, -1))]
	return candidate_key < current_key
