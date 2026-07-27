class_name MechanikaUmiejetnosci


static func czy_mozna_uzyc(unit: Dictionary, skill_id: String, skill_library: Dictionary) -> bool:
	var skill: Dictionary = skill_library.get(skill_id, {})
	if skill.is_empty():
		return false
	var has_skill := false
	for owned_skill_id in unit.get("skill_ids", []):
		if str(owned_skill_id) == skill_id:
			has_skill = true
			break
	if not has_skill or str(skill.get("target_type", "")) == "passive":
		return false
	if int(unit.get("action_points", 0)) < int(skill.get("ap_cost", 0)):
		return false
	return int(unit.get("skill_cooldowns", {}).get(skill_id, 0)) == 0


static func pobierz_bonus_szarzy(skill: Dictionary, stat_name: String) -> int:
	for change in skill.get("effect", {}).get("stat_changes", []):
		if str(change.get("stat", "")) == stat_name and str(change.get("mode", "")) == "flat":
			return int(change.get("value", 0))
	return 0


static func pobierz_mnoznik_szarzy(skill: Dictionary) -> float:
	for change in skill.get("effect", {}).get("stat_changes", []):
		if str(change.get("stat", "")) == "dmg" and str(change.get("mode", "")) == "percent":
			return 1.0 + float(change.get("value", 0)) / 100.0
	return 1.0


static func pobierz_sume_cooldownow(unit: Dictionary) -> int:
	var total := 0
	for skill_id in unit.get("skill_ids", []):
		total += int(unit.get("skill_cooldowns", {}).get(str(skill_id), 0))
	return total


static func oblicz_obrazenia_okresowe(unit: Dictionary, effect_damage: int) -> int:
	return maxi(1, effect_damage * int(unit.get("count", 1)))


static func pobierz_mnoznik_obszaru(effect_type: String, is_center: bool) -> float:
	if effect_type == "arrow_rain":
		return 0.5 if is_center else 0.35
	return 1.0 if is_center else 0.5


static func wykonaj(battle: Node, caster: Dictionary, target: Dictionary, skill: Dictionary, target_cell: Vector2i) -> void:
	caster.action_points = maxi(0, int(caster.action_points) - int(skill.get("ap_cost", 0)))
	caster.skill_cooldowns[skill.get("id", "")] = int(skill.get("cooldown", 0))
	battle.pending_skill_id = ""
	battle.damage_tooltip.visible = false
	if str(skill.get("target_type", "")) != "self":
		battle._reveal_if_in_bush(caster)

	match String(skill.get("effect_type", "")):
		"taunt_burst": battle._execute_taunt_burst(caster)
		"sztandar": battle._execute_sztandar(caster, target)
		"dancing_blade": battle._execute_dancing_blade(caster)
		"knee_shot": battle._execute_knee_shot(caster, target)
		"poison_dagger": battle._execute_poison_dagger(caster, target)
		"eagle_eye": battle._execute_eagle_eye(caster)
		"pnacza": battle._execute_pnacza(caster, target)
		"curse_throw": battle._execute_curse_throw(caster, target)
		"shield_push": await battle._execute_shield_push(caster, target)
		"hammer_strike": battle._execute_hammer_strike(caster, target)
		"hook_throw": await battle._execute_hook_throw(caster, target)
		"fireball": await battle._execute_fireball(caster, target_cell)
		"dynamite_throw": battle._execute_dynamite_throw(caster, target_cell)
		"arrow_rain": await battle._execute_arrow_rain(caster, target_cell)
		"ice_ground": await battle._execute_ice_ground(caster, target_cell)
		"poison_cloud": battle._execute_poison_cloud(caster, target_cell)
		"bear_trap": battle._execute_bear_trap(caster, target_cell)
		"summon_statue": battle._execute_summon_statue(caster, target_cell)
		"goblin_trap": battle._execute_goblin_trap(caster, target_cell)
		"energy_barrier": battle._execute_energy_barrier(caster)
		"iron_curtain": battle._execute_iron_curtain(caster, target)
		"self_buff": battle._execute_self_buff(caster, skill)
		"zadza_krwi": battle._execute_zadza_krwi(caster, skill)
		"utwardzenie": battle._execute_utwardzenie(caster, skill)
		"focused_strike": battle._execute_focused_strike(caster, target, skill)
		"shattering_strike": battle._execute_shattering_strike(caster, target, skill)
		"piercing_shot": battle._execute_piercing_shot(caster, target, skill)
		"zaklete_ciecie": battle._execute_zaklete_ciecie(caster, target)
		"rozszarpanie": battle._execute_rozszarpanie(caster, target)
		"magic_projection": battle._execute_magic_projection(caster, target_cell)
	battle._sync_board()
