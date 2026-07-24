extends Node

signal external_load_finished(success: bool, message: String)

const SAVE_DIR: String = "user://saves"
const SAVE_SCHEMA_VERSION: int = 1

var is_loading: bool = false
var loaded_gw_data: Dictionary = {}
var pending_battle: Dictionary = {}
var last_error: String = ""
var _web_load_input: Variant
var _web_load_reader: Variant
var _web_load_change_callback: Variant
var _web_load_callback: Variant

func _ready() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func get_save_path(seed_val: int) -> String:
	return SAVE_DIR + "/seed_" + str(seed_val) + ".json"

func has_save(seed_val: int) -> bool:
	return (
		FileAccess.file_exists(get_save_path(seed_val))
		or FileAccess.file_exists(_get_legacy_save_path(seed_val))
	)

func delete_save(seed_val: int) -> void:
	for path: String in [get_save_path(seed_val), _get_legacy_save_path(seed_val)]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)

func save_game(seed_val: int, game_world: Node2D) -> bool:
	return _write_text(get_save_path(seed_val), _make_save_json(seed_val, game_world))

func export_game(path: String, seed_val: int, game_world: Node2D) -> bool:
	var json_text: String = _make_save_json(seed_val, game_world)
	if not _write_text(get_save_path(seed_val), json_text):
		return false
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(
			json_text.to_utf8_buffer(),
			"zapis_gry_%s.json" % seed_val,
			"application/json"
		)
		return true
	var save_path: String = path if path.get_extension().to_lower() == "json" else "%s.json" % path
	return _write_text(save_path, json_text)

func import_game(path: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Nie udało się odczytać pliku zapisu."
		return false
	return import_game_from_text(file.get_as_text())

func import_game_from_text(text: String) -> bool:
	var save_data: Dictionary = _parse_save_json(text)
	if save_data.is_empty():
		return false
	var seed_val: int = int(save_data.get("seed", 0))
	var normalized_json: String = JSON.stringify(JSON.from_native(save_data), "\t")
	if not _write_text(get_save_path(seed_val), normalized_json):
		return false
	return _apply_save_data(save_data, seed_val)

func open_web_load_dialog() -> void:
	var document: Variant = JavaScriptBridge.get_interface("document")
	if document == null:
		last_error = "Przeglądarka nie udostępnia wyboru pliku."
		external_load_finished.emit(false, last_error)
		return
	_web_load_input = document.createElement("input")
	_web_load_input.type = "file"
	_web_load_input.accept = ".json,application/json"
	_web_load_change_callback = JavaScriptBridge.create_callback(_on_web_load_selected)
	_web_load_input.addEventListener("change", _web_load_change_callback)
	_web_load_input.click()

func _on_web_load_selected(args: Array) -> void:
	var files: Variant = args[0].target.files
	if int(files.length) == 0:
		return
	_web_load_reader = JavaScriptBridge.create_object("FileReader")
	_web_load_callback = JavaScriptBridge.create_callback(_on_web_load_finished)
	_web_load_reader.onload = _web_load_callback
	_web_load_reader.readAsText(files[0])

func _on_web_load_finished(args: Array) -> void:
	var success: bool = import_game_from_text(str(args[0].target.result))
	external_load_finished.emit(success, last_error)

func _make_save_json(seed_val: int, game_world: Node2D) -> String:
	return JSON.stringify(JSON.from_native(_make_save_data(seed_val, game_world)), "\t")

func _make_save_data(seed_val: int, game_world: Node2D) -> Dictionary:
	var save_data: Dictionary = {
		"schema_version": SAVE_SCHEMA_VERSION,
		"seed": seed_val,
		"use_custom_seed": GameSettings.use_custom_seed,
	}
	
	save_data["economy"] = {
		"current_turn": EconomyManager.current_turn,
		"player_army": EconomyManager.player_army,
		"owned_potions": EconomyManager.owned_potions,
		"active_potions": EconomyManager.active_potions,
		"potion_bonus_hp": EconomyManager.potion_bonus_hp,
		"potion_bonus_dmg": EconomyManager.potion_bonus_dmg,
		"potion_bonus_def": EconomyManager.potion_bonus_def,
		"potion_bonus_speed": EconomyManager.potion_bonus_speed,
		"temple_blessing_turns_left": EconomyManager.temple_blessing_turns_left,
		"temple_blessing_cooldown_left": EconomyManager.temple_blessing_cooldown_left,
		"resources": EconomyManager.resources,
		"max_tech_points": EconomyManager.max_tech_points,
		"max_culture_points": EconomyManager.max_culture_points,
		"current_research": EconomyManager.current_research,
		"research_turns_left": EconomyManager.research_turns_left,
		"current_culture_research": EconomyManager.current_culture_research,
		"culture_turns_left": EconomyManager.culture_turns_left,
		"next_unit_uid": EconomyManager.next_unit_uid,
	}
	save_data["debug_mode"] = GameSettings.debug_mode
	save_data["pending_battle"] = pending_battle
	
	var unlocked_tech: Array = []
	for k in EconomyManager.technology_tree:
		if EconomyManager.technology_tree[k]["unlocked"]: unlocked_tech.append(k)
	save_data["economy"]["unlocked_tech"] = unlocked_tech
	
	var unlocked_culture: Array = []
	for k in EconomyManager.culture_tree:
		if EconomyManager.culture_tree[k]["unlocked"]: unlocked_culture.append(k)
	save_data["economy"]["unlocked_culture"] = unlocked_culture
	
	var unlocked_skills: Array = []
	for k in EconomyManager.skill_tree:
		if EconomyManager.skill_tree[k]["unlocked"]: unlocked_skills.append(k)
	save_data["economy"]["unlocked_skills"] = unlocked_skills

	var gw_data: Dictionary = {
		"map_data": game_world.map_data,
		"owned_tiles": game_world.owned_tiles,
		"city_centers": game_world.city_centers,
		"camps": game_world.camps,
		"camp_owned_tiles": game_world.camp_owned_tiles,
		"explored_tiles": game_world.explored_tiles,
		"last_expansion_turn": game_world.last_expansion_turn,
		"last_camp_expansion_turn": game_world.last_camp_expansion_turn,
		"camp_tile_owner": game_world.camp_tile_owner,
	}
	
	if game_world.character:
		gw_data["character_pos"] = game_world.character.global_position
		gw_data["character_path"] = game_world.character.path
		gw_data["character_moves_left"] = game_world.character.moves_left
	
	save_data["game_world"] = gw_data
	return save_data

func load_game(seed_val: int) -> bool:
	if not has_save(seed_val): return false
	var save_path: String = get_save_path(seed_val)
	if FileAccess.file_exists(save_path):
		var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
		if file == null:
			return false
		var save_data: Dictionary = _parse_save_json(file.get_as_text())
		return not save_data.is_empty() and _apply_save_data(save_data, seed_val)
	var legacy_file: FileAccess = FileAccess.open(_get_legacy_save_path(seed_val), FileAccess.READ)
	if legacy_file == null:
		return false
	var legacy_data: Variant = legacy_file.get_var()
	if typeof(legacy_data) != TYPE_DICTIONARY:
		return false
	return _apply_save_data(legacy_data, seed_val)

func _apply_save_data(save_data: Dictionary, fallback_seed: int) -> bool:
	EconomyManager.reset()
	var econ: Dictionary = save_data.get("economy", {})
	if not econ.is_empty():
		EconomyManager.current_turn = econ.get("current_turn", 1)
		EconomyManager.player_army = econ.get("player_army", [])
		EconomyManager.owned_potions = econ.get("owned_potions", {})
		EconomyManager.active_potions = econ.get("active_potions", {})
		EconomyManager.potion_bonus_hp = econ.get("potion_bonus_hp", 0)
		EconomyManager.potion_bonus_dmg = econ.get("potion_bonus_dmg", 0)
		EconomyManager.potion_bonus_def = econ.get("potion_bonus_def", 0)
		EconomyManager.potion_bonus_speed = econ.get("potion_bonus_speed", 0)
		EconomyManager.temple_blessing_turns_left = econ.get("temple_blessing_turns_left", 0)
		EconomyManager.temple_blessing_cooldown_left = econ.get("temple_blessing_cooldown_left", 0)
		EconomyManager.resources = econ.get("resources", EconomyManager.resources)
		EconomyManager.max_tech_points = econ.get("max_tech_points", 500.0)
		EconomyManager.max_culture_points = econ.get("max_culture_points", 420.0)
		EconomyManager.current_research = econ.get("current_research", "")
		EconomyManager.research_turns_left = econ.get("research_turns_left", 0)
		EconomyManager.current_culture_research = econ.get("current_culture_research", "")
		EconomyManager.culture_turns_left = econ.get("culture_turns_left", 0)
		EconomyManager.next_unit_uid = econ.get("next_unit_uid", 1)
		EconomyManager.ensure_army_unit_ids()
		
		var unlocked_tech: Array = econ.get("unlocked_tech", [])
		for k in EconomyManager.technology_tree:
			EconomyManager.technology_tree[k]["unlocked"] = k in unlocked_tech
			
		var unlocked_culture: Array = econ.get("unlocked_culture", [])
		for k in EconomyManager.culture_tree:
			EconomyManager.culture_tree[k]["unlocked"] = k in unlocked_culture
			
		var unlocked_skills: Array = econ.get("unlocked_skills", [])
		if "przyspieszenie" in unlocked_skills:
			unlocked_skills.append("sztandar")
		if "precyzyjny_strzal" in unlocked_skills:
			unlocked_skills.append("deszcz_strzal")
		for k in EconomyManager.skill_tree:
			EconomyManager.skill_tree[k]["unlocked"] = k in unlocked_skills
		EconomyManager.notify_change()

	GameSettings.current_seed = int(save_data.get("seed", fallback_seed))
	GameSettings.use_custom_seed = bool(save_data.get("use_custom_seed", true))
	GameSettings.debug_mode = bool(save_data.get("debug_mode", false))
	pending_battle = save_data.get("pending_battle", {})
	loaded_gw_data = save_data.get("game_world", {})
	is_loading = true
	last_error = ""
	return true

func _parse_save_json(text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "Plik nie zawiera poprawnego zapisu JSON."
		return {}
	var native: Variant = JSON.to_native(parsed)
	if (
		typeof(native) != TYPE_DICTIONARY
		or int(native.get("schema_version", 0)) != SAVE_SCHEMA_VERSION
		or typeof(native.get("economy", null)) != TYPE_DICTIONARY
		or typeof(native.get("game_world", null)) != TYPE_DICTIONARY
	):
		last_error = "Nieobsługiwana lub uszkodzona wersja zapisu."
		return {}
	return native

func _write_text(path: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_error = "Nie udało się zapisać pliku: %s" % path
		return false
	file.store_string(text)
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		last_error = "Błąd zapisu pliku: %s" % error_string(write_error)
		return false
	last_error = ""
	return true

func _get_legacy_save_path(seed_val: int) -> String:
	return SAVE_DIR + "/seed_" + str(seed_val) + ".dat"
