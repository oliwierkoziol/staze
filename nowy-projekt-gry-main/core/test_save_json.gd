extends SceneTree

class FakeWorld extends Node2D:
	var map_data: Dictionary = {
		Vector2(2, 3): {"building": "Brak", "color": Color(0.2, 0.4, 0.6)},
	}
	var owned_tiles: Dictionary = {Vector2(2, 3): true}
	var city_centers: Array[Vector2] = [Vector2(2, 3)]
	var camps: Dictionary = {}
	var camp_owned_tiles: Dictionary = {}
	var explored_tiles: Dictionary = {Vector2(2, 3): true}
	var last_expansion_turn: int = 4
	var last_camp_expansion_turn: int = 5
	var camp_tile_owner: Dictionary = {}
	var character: Node2D

func _initialize() -> void:
	var seed_testowy: int = -2147483001
	var sciezka: String = "user://test_export_save.json"
	var swiat := FakeWorld.new()
	var ekonomia: Node = root.get_node("EconomyManager")
	var ustawienia: Node = root.get_node("GameSettings")
	var zapis: Node = root.get_node("SaveManager")
	ekonomia.reset()
	ekonomia.current_turn = 7
	ustawienia.current_seed = seed_testowy
	ustawienia.use_custom_seed = true
	var zapisano: bool = zapis.export_game(sciezka, seed_testowy, swiat)
	ekonomia.current_turn = 1
	var wczytano: bool = zapis.import_game(sciezka)
	var mapa: Dictionary = zapis.loaded_gw_data.get("map_data", {})
	var poprawne: bool = (
		zapisano
		and wczytano
		and ekonomia.current_turn == 7
		and ustawienia.current_seed == seed_testowy
		and mapa.has(Vector2(2, 3))
		and mapa[Vector2(2, 3)]["color"] is Color
	)
	print("SAVE_JSON_ROUND_TRIP=", poprawne)
	zapis.delete_save(seed_testowy)
	if FileAccess.file_exists(sciezka):
		DirAccess.remove_absolute(sciezka)
	swiat.free()
	quit(0 if poprawne else 1)
