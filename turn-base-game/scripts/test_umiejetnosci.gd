extends SceneTree


const MechanikaUmiejetnosciScript = preload("res://scripts/mechanika_umiejetnosci.gd")

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


func _uruchom() -> void:
	gra = load("res://gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	gra._load_skill_library()
	gra._load_general_skills()
	gra.obstacles.clear()
	gra.terrain_effects.clear()
	_test_dostepnosci()
	_test_szarzy()
	_test_statusow()
	_test_celowania()
	_test_obrazen_i_obszarow()
	await _test_wykonania()
	print("SKILL_TEST_FAILURES=", bledy.size())
	quit(bledy.size())


func _test_dostepnosci() -> void:
	var unit: Dictionary = gra._prepare_unit({"id": 1, "type_id": "human_cavalry", "side": "player", "grid_x": 2, "grid_y": 5})
	_sprawdz(MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, "szarza", gra.skill_library), "Szarza jest dostepna z AP i bez cooldownu")
	unit.skill_cooldowns["szarza"] = 1
	_sprawdz(not MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, "szarza", gra.skill_library), "Cooldown blokuje umiejetnosc")
	unit.skill_cooldowns["szarza"] = 0
	unit.action_points = 0
	_sprawdz(not MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, "szarza", gra.skill_library), "Brak AP blokuje umiejetnosc")
	unit.action_points = 1
	unit.skill_ids = ["bariera_energetyczna"]
	_sprawdz(not MechanikaUmiejetnosciScript.czy_mozna_uzyc(unit, "bariera_energetyczna", gra.skill_library), "Umiejetnosc bierna nie jest aktywowana recznie")


func _test_szarzy() -> void:
	var skill: Dictionary = gra.skill_library["szarza"]
	_sprawdz(MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(skill, "move_range") == 1, "Szarza dodaje 1 pole ruchu")
	_sprawdz(MechanikaUmiejetnosciScript.pobierz_bonus_szarzy(skill, "attack_range") == 1, "Szarza dodaje 1 pole zasiegu")
	_sprawdz(is_equal_approx(MechanikaUmiejetnosciScript.pobierz_mnoznik_szarzy(skill), 1.5), "Szarza zadaje 150 procent obrazen")
	var unit: Dictionary = {"skill_ids": ["szarza", "sztandar"], "skill_cooldowns": {"szarza": 4, "sztandar": 2}}
	_sprawdz(MechanikaUmiejetnosciScript.pobierz_sume_cooldownow(unit) == 6, "Suma cooldownow uwzglednia wszystkie umiejetnosci")


func _test_statusow() -> void:
	var unit: Dictionary = gra._prepare_unit({"id": 2, "type_id": "human_knights", "side": "player", "grid_x": 2, "grid_y": 5})
	var base_speed: int = int(unit.speed)
	gra._apply_or_refresh_effect(unit, {"id": "test_szybkosci", "name": "Test", "category": "buff", "remaining_turns": 2, "stat_changes": [{"stat": "speed", "mode": "flat", "value": 2}]})
	_sprawdz(int(unit.speed) == base_speed + 2, "Buff natychmiast zmienia statystyke")
	gra._apply_or_refresh_effect(unit, {"id": "test_szybkosci", "name": "Test", "category": "buff", "remaining_turns": 1, "stat_changes": [{"stat": "speed", "mode": "flat", "value": 2}]})
	_sprawdz(unit.active_effects.size() == 1 and int(unit.speed) == base_speed + 2, "Ponowne nalozenie odswieza zamiast dublowac status")


func _test_celowania() -> void:
	var caster: Dictionary = gra._prepare_unit({"id": 3, "type_id": "human_archers", "side": "player", "grid_x": 2, "grid_y": 5})
	var enemy: Dictionary = gra._prepare_unit({"id": 4, "type_id": "human_knights", "side": "enemy", "grid_x": 5, "grid_y": 5})
	var ally: Dictionary = gra._prepare_unit({"id": 5, "type_id": "human_knights", "side": "player", "grid_x": 3, "grid_y": 5})
	gra.units = [caster, enemy, ally]
	var knee_shot: Dictionary = gra.skill_library["strzal_w_kolano"]
	_sprawdz(gra._can_target_enemy_with_skill(caster, enemy, knee_shot), "Skill w zasiegu moze wskazac widocznego wroga")
	_sprawdz(not gra._can_target_enemy_with_skill(caster, ally, knee_shot), "Skill ofensywny nie moze wskazac sojusznika")
	enemy.is_hidden = true
	_sprawdz(not gra._can_target_enemy_with_skill(caster, enemy, knee_shot), "Skill nie moze wskazac ukrytego celu z daleka")


func _test_obrazen_i_obszarow() -> void:
	_sprawdz(MechanikaUmiejetnosciScript.oblicz_obrazenia_okresowe({"count": 3}, 2) == 6, "Obrazenia okresowe skaluja sie liczebnoscia")
	var blocked: Vector2i = gra._calculate_attack_preview_damage({"atk": 10, "dmg_min": 5, "dmg_max": 5, "count": 2}, {"def": 0, "active_effects": [{"block_next_attack": true}]}, 1.0)
	_sprawdz(blocked == Vector2i.ZERO, "Bariera zeruje podglad obrazen")
	_sprawdz(gra._get_magic_projection_cells(Vector2i(4, 4), "player").size() == 3, "Magiczna Projekcja tworzy 3 pola")
	_sprawdz(gra._get_ice_ground_cells(Vector2i(7, 5)) == [Vector2i(7, 5), Vector2i(8, 6), Vector2i(7, 6)], "Lodowe Podloze tworzy 3 pola w trojkacie")


func _test_wykonania() -> void:
	var caster: Dictionary = gra._prepare_unit({"id": 6, "type_id": "human_mages", "side": "player", "grid_x": 2, "grid_y": 5})
	gra.units = [caster]
	await gra._execute_skill(caster, {}, gra.skill_library["medytacja"], Vector2i(2, 5))
	_sprawdz(int(caster.action_points) == 0, "Wykonanie umiejetnosci zuzywa AP")
	_sprawdz(int(caster.skill_cooldowns.get("medytacja", 0)) == 3, "Wykonanie umiejetnosci ustawia cooldown")
	_sprawdz(gra._has_effect(caster, "medytacja"), "Dispatcher wykonuje efekt konkretnej umiejetnosci")
