extends Node

const SAVE_DIR = "user://saves"

var is_loading = false
var loaded_gw_data = {}
var pending_battle: Dictionary = {}

func _ready():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func get_save_path(seed_val: int) -> String:
	return SAVE_DIR + "/seed_" + str(seed_val) + ".dat"

func has_save(seed_val: int) -> bool:
	return FileAccess.file_exists(get_save_path(seed_val))

func delete_save(seed_val: int) -> void:
	if has_save(seed_val):
		DirAccess.remove_absolute(get_save_path(seed_val))

func save_game(seed_val: int, game_world: Node2D) -> void:
	var save_data = {}
	
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
	
	var unlocked_tech = []
	for k in EconomyManager.technology_tree:
		if EconomyManager.technology_tree[k]["unlocked"]: unlocked_tech.append(k)
	save_data["economy"]["unlocked_tech"] = unlocked_tech
	
	var unlocked_culture = []
	for k in EconomyManager.culture_tree:
		if EconomyManager.culture_tree[k]["unlocked"]: unlocked_culture.append(k)
	save_data["economy"]["unlocked_culture"] = unlocked_culture
	
	var unlocked_skills = []
	for k in EconomyManager.skill_tree:
		if EconomyManager.skill_tree[k]["unlocked"]: unlocked_skills.append(k)
	save_data["economy"]["unlocked_skills"] = unlocked_skills

	var gw_data = {
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
	
	var file = FileAccess.open(get_save_path(seed_val), FileAccess.WRITE)
	if file:
		file.store_var(save_data)

func load_game(seed_val: int) -> bool:
	if not has_save(seed_val): return false
	
	var file = FileAccess.open(get_save_path(seed_val), FileAccess.READ)
	if not file: return false
	
	var save_data = file.get_var()
	if typeof(save_data) != TYPE_DICTIONARY: return false
	
	var econ = save_data.get("economy", {})
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
		
		var unlocked_tech = econ.get("unlocked_tech", [])
		for k in EconomyManager.technology_tree:
			EconomyManager.technology_tree[k]["unlocked"] = k in unlocked_tech
			
		var unlocked_culture = econ.get("unlocked_culture", [])
		for k in EconomyManager.culture_tree:
			EconomyManager.culture_tree[k]["unlocked"] = k in unlocked_culture
			
		var unlocked_skills = econ.get("unlocked_skills", [])
		if "przyspieszenie" in unlocked_skills:
			unlocked_skills.append("sztandar")
		if "precyzyjny_strzal" in unlocked_skills:
			unlocked_skills.append("deszcz_strzal")
		for k in EconomyManager.skill_tree:
			EconomyManager.skill_tree[k]["unlocked"] = k in unlocked_skills
		EconomyManager.notify_change()

	GameSettings.debug_mode = bool(save_data.get("debug_mode", false))
	pending_battle = save_data.get("pending_battle", {})
	loaded_gw_data = save_data.get("game_world", {})
	is_loading = true
	return true
