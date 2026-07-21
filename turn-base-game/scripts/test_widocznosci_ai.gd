extends SceneTree

var gra: Control
var bledy: Array[String] = []


func _initialize() -> void:
	call_deferred("_uruchom")


func _sprawdz(warunek: bool, opis: String) -> void:
	if not warunek:
		bledy.append(opis)
	print("PASS: " if warunek else "FAIL: ", opis)


func _uruchom() -> void:
	gra = load("res://gra.tscn").instantiate()
	root.add_child(gra)
	await process_frame
	var ai: Dictionary = {"id": 1, "side": "enemy", "grid_x": 7, "grid_y": 5, "active_effects": [], "attack_range": 4}
	var gracz: Dictionary = {"id": 2, "side": "player", "grid_x": 3, "grid_y": 5, "active_effects": [], "is_hidden": true}
	gra.units = [ai, gracz]
	gra.obstacles.clear()
	gra.terrain_effects.clear()
	_sprawdz(gra._find_nearest_player_unit(ai).is_empty(), "AI nie wybiera niewidocznego gracza")
	_sprawdz(gra._ai_score_approach(ai, Vector2i(6, 5)) == 0, "Ukryty gracz nie wyznacza kierunku ruchu")
	_sprawdz(gra._ai_score_area_damage(ai, Vector2i(3, 5), 1.0, 0.5) == 0, "AI nie punktuje obszarówki na ukrytym graczu")
	gracz["grid_x"] = 6
	_sprawdz(not gra._find_nearest_player_unit(ai).is_empty(), "Sąsiedni gracz pozostaje widoczny")
	print("AI_VISIBILITY_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
