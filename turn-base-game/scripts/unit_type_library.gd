class_name UnitTypeLibrary

const UNIT_TYPES_PATH := "res://data/unit_types.json"
const GENERAL_SKILLS_PATH := "res://data/general_skills.json"
const STATUS_EFFECTS_PATH := "res://data/status_effects.json"

static var _factions: Array[Dictionary] = []
static var _unit_lookup: Dictionary = {}
static var _skill_library: Dictionary = {}
static var _general_skills: Dictionary = {}
static var _status_effects: Dictionary = {}
static var _loaded := false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_load()


static func reload() -> void:
	_loaded = false
	_load()


static func _load_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Nie mozna otworzyc %s" % path)
		return {}
	var text: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Plik %s musi zawierac obiekt JSON." % path)
		return {}
	return parsed


static func _load() -> void:
	_loaded = true
	var config: Dictionary = _load_json_file(UNIT_TYPES_PATH)
	if config.is_empty():
		return

	_factions.clear()
	_unit_lookup.clear()
	_skill_library.clear()
	_general_skills.clear()
	_status_effects.clear()

	var status_effects_data: Dictionary = _load_json_file(STATUS_EFFECTS_PATH)
	var raw_status_effects: Dictionary = status_effects_data.get("status_effects", {})
	for effect_id in raw_status_effects.keys():
		var raw_effect: Variant = raw_status_effects[effect_id]
		if typeof(raw_effect) != TYPE_DICTIONARY:
			continue
		_status_effects[str(effect_id)] = _normalize_status_effect_config(str(effect_id), raw_effect)

	var general_data: Dictionary = _load_json_file(GENERAL_SKILLS_PATH)
	var raw_general_skills: Dictionary = general_data.get("general_skills", {})
	for skill_id in raw_general_skills.keys():
		var raw_skill: Variant = raw_general_skills[skill_id]
		if typeof(raw_skill) != TYPE_DICTIONARY:
			continue
		_general_skills[str(skill_id)] = _normalize_general_skill(str(skill_id), raw_skill)

	var skills_path: String = str(config.get("skill_library_path", "res://data/skills/skills.json"))
	var skills_data: Dictionary = _load_json_file(skills_path)
	var raw_skills: Dictionary = skills_data.get("skill_library", {})
	for skill_id in raw_skills.keys():
		var raw_skill: Variant = raw_skills[skill_id]
		if typeof(raw_skill) != TYPE_DICTIONARY:
			continue
		_skill_library[str(skill_id)] = _normalize_skill_config(str(skill_id), raw_skill)

	var factions_dir: String = str(config.get("factions_path", "res://data/factions/"))
	var faction_files: Array = config.get("factions", [])
	for faction_file in faction_files:
		if typeof(faction_file) != TYPE_STRING:
			continue
		var faction_path: String = factions_dir.path_join(str(faction_file))
		var faction_data: Dictionary = _load_json_file(faction_path)
		var raw_faction: Variant = faction_data.get("faction", {})
		if typeof(raw_faction) != TYPE_DICTIONARY:
			continue
		var faction: Dictionary = raw_faction.duplicate(true)
		var units: Array = faction.get("units", [])
		var normalized_units: Array[Dictionary] = []
		for raw_unit in units:
			if typeof(raw_unit) != TYPE_DICTIONARY:
				continue
			var unit_data: Dictionary = _normalize_unit_type(raw_unit)
			normalized_units.append(unit_data)
			_unit_lookup[unit_data.id] = unit_data
		faction["units"] = normalized_units
		_factions.append(faction)


static func _normalize_unit_type(raw_unit: Dictionary) -> Dictionary:
	var unit: Dictionary = raw_unit.duplicate(true)
	for key in ["hp", "dmg", "def", "speed", "action_points", "count", "move_range", "attack_range"]:
		unit[key] = int(unit.get(key, 0))
	for key in ["id", "name", "short_name", "role", "resistance", "portrait"]:
		unit[key] = str(unit.get(key, ""))
	var skill_ids: Array[String] = []
	for skill_id in unit.get("skill_ids", []):
		skill_ids.append(str(skill_id))
	unit["skill_ids"] = skill_ids
	return unit


static func _normalize_skill_config(skill_id: String, raw_skill: Dictionary) -> Dictionary:
	var skill: Dictionary = raw_skill.duplicate(true)
	skill["id"] = str(skill.get("id", skill_id))
	skill["name"] = str(skill.get("name", skill_id))
	skill["description"] = str(skill.get("description", ""))
	skill["ap_cost"] = int(skill.get("ap_cost", 0))
	skill["cooldown"] = int(skill.get("cooldown", 0))
	skill["range"] = int(skill.get("range", 0))
	skill["target_type"] = str(skill.get("target_type", ""))
	skill["effect_type"] = str(skill.get("effect_type", ""))
	var raw_effect: Variant = skill.get("effect", {})
	if typeof(raw_effect) == TYPE_DICTIONARY and not raw_effect.is_empty():
		skill["effect"] = _normalize_skill_effect(str(skill.get("id", skill_id)), skill, raw_effect)
	return skill


static func _normalize_skill_effect(skill_id: String, skill: Dictionary, raw_effect: Variant) -> Dictionary:
	var effect: Dictionary = (raw_effect as Dictionary).duplicate(true)
	effect["id"] = str(effect.get("id", skill_id))
	effect["name"] = str(effect.get("name", skill.get("name", skill_id)))
	effect["category"] = str(effect.get("category", "buff"))
	effect["remaining_turns"] = int(effect.get("remaining_turns", 1))
	var stat_changes: Array[Dictionary] = []
	for change in effect.get("stat_changes", []):
		if typeof(change) != TYPE_DICTIONARY:
			continue
		stat_changes.append({
			"stat": str(change.get("stat", "")),
			"mode": str(change.get("mode", "flat")),
			"value": int(change.get("value", 0))
		})
	effect["stat_changes"] = stat_changes
	return effect


static func _normalize_general_skill(skill_id: String, raw_skill: Dictionary) -> Dictionary:
	var skill: Dictionary = raw_skill.duplicate(true)
	skill["id"] = str(skill.get("id", skill_id))
	skill["name"] = str(skill.get("name", skill_id))
	skill["description"] = str(skill.get("description", ""))
	skill["cooldown"] = int(skill.get("cooldown", 0))
	var raw_effect: Variant = skill.get("effect", {})
	if typeof(raw_effect) == TYPE_DICTIONARY and not raw_effect.is_empty():
		skill["effect"] = _normalize_skill_effect(str(skill.get("id", skill_id)), skill, raw_effect)
	return skill


static func _normalize_status_effect_config(effect_id: String, raw_effect: Dictionary) -> Dictionary:
	var effect: Dictionary = raw_effect.duplicate(true)
	effect["id"] = str(effect.get("id", effect_id))
	effect["name"] = str(effect.get("name", effect_id))
	effect["description"] = str(effect.get("description", ""))
	effect["category"] = str(effect.get("category", ""))
	effect["icon"] = str(effect.get("icon", ""))
	effect["color"] = str(effect.get("color", ""))
	return effect


static func get_factions() -> Array[Dictionary]:
	_ensure_loaded()
	return _factions.duplicate(true)


static func get_faction_units(faction_id: String) -> Array[Dictionary]:
	_ensure_loaded()
	for faction in _factions:
		if faction.get("id", "") == faction_id:
			var result: Array[Dictionary] = []
			for unit in faction.get("units", []):
				result.append(unit.duplicate(true))
			return result
	return []


static func lookup(type_id: String) -> Dictionary:
	_ensure_loaded()
	if _unit_lookup.has(type_id):
		return _unit_lookup[type_id].duplicate(true)
	return {}


static func get_skill_library() -> Dictionary:
	_ensure_loaded()
	return _skill_library.duplicate(true)


static func get_skill(skill_id: String) -> Dictionary:
	_ensure_loaded()
	if _skill_library.has(skill_id):
		return _skill_library[skill_id].duplicate(true)
	return {}


static func get_general_skills() -> Dictionary:
	_ensure_loaded()
	return _general_skills.duplicate(true)


static func get_general_skill(skill_id: String) -> Dictionary:
	_ensure_loaded()
	if _general_skills.has(skill_id):
		return _general_skills[skill_id].duplicate(true)
	return {}


static func get_status_effects() -> Dictionary:
	_ensure_loaded()
	return _status_effects.duplicate(true)


static func get_status_effect(effect_id: String) -> Dictionary:
	_ensure_loaded()
	var lookup_id: String = effect_id
	if effect_id.begins_with("taunt_"):
		lookup_id = "taunt"
	if _status_effects.has(lookup_id):
		return _status_effects[lookup_id].duplicate(true)
	return {}


static func get_faction_ids() -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for faction in _factions:
		result.append(str(faction.get("id", "")))
	return result


static func get_default_faction() -> String:
	var ids := get_faction_ids()
	if ids.is_empty():
		return ""
	return ids[0]


static func build_instance(type_id: String, instance_id: int, side: String, grid_x: int, grid_y: int) -> Dictionary:
	var type_data: Dictionary = lookup(type_id)
	if type_data.is_empty():
		push_error("Nieznany type_id: %s" % type_id)
		return {}
	var unit: Dictionary = type_data.duplicate(true)
	unit["id"] = instance_id
	unit["type_id"] = type_id
	unit["side"] = side
	unit["grid_x"] = grid_x
	unit["grid_y"] = grid_y
	for key in ["base_hp", "base_dmg", "base_def", "base_speed", "base_move_range", "base_attack_range"]:
		var stat_name: String = key.replace("base_", "")
		unit[key] = int(unit.get(stat_name, 0))
	unit["current_ap"] = int(unit.get("action_points", 1))
	unit["effects"] = []
	unit["cooldowns"] = {}
	unit["has_moved"] = false
	unit["has_acted"] = false
	return unit
