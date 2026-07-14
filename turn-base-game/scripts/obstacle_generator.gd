class_name ObstacleGenerator

const HexUtilsScript = preload("res://scripts/hex_utils.gd")


static func generate(units: Array, obstacle_types: Array[String], columns: int, rows: int, setup_columns: int, winter_mode: bool = false, max_detonators: int = 2) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var occupied: Dictionary = {}
	var obstacle_types_by_cell: Dictionary = {}
	var detonator_count: int = 0
	for unit in units:
		occupied[Vector2i(unit.grid_x, unit.grid_y)] = true

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var cluster_count: int = rng.randi_range(4, 7)
	for cluster_index in range(cluster_count):
		var obstacle_type: String = obstacle_types[rng.randi_range(0, obstacle_types.size() - 1)]
		if obstacle_type == "detonator" and detonator_count >= max_detonators:
			var fallback_types: Array[String] = obstacle_types.duplicate()
			while fallback_types.has("detonator"):
				fallback_types.erase("detonator")
			if fallback_types.is_empty():
				continue
			obstacle_type = fallback_types[rng.randi_range(0, fallback_types.size() - 1)]
		var cluster_size: int = 1 if obstacle_type == "detonator" else (rng.randi_range(1, 3) + (1 if cluster_index < 2 else 0))
		var cluster: Array[Vector2i] = _generate_cluster(cluster_size, occupied, obstacle_types_by_cell, obstacle_type, rng, columns, rows, setup_columns)
		for cell in cluster:
			occupied[cell] = true
			obstacle_types_by_cell[cell] = obstacle_type
			if obstacle_type == "detonator":
				detonator_count += 1
			result.append({
				"grid_x": cell.x,
				"grid_y": cell.y,
				"type": obstacle_type,
				"variant": _pick_variant(obstacle_type, rng, winter_mode)
			})
	return result


static func _pick_variant(obstacle_type: String, rng: RandomNumberGenerator, winter_mode: bool = false) -> String:
	if obstacle_type == "kamienie":
		if winter_mode:
			return "ice"
		if rng.randi_range(1, 100) == 1:
			return "rock2k"
		var rock_variants: Array[String] = ["rock1", "rock2", "rock3"]
		return rock_variants[rng.randi_range(0, rock_variants.size() - 1)]
	if obstacle_type == "krzok":
		return "krzok"
	if obstacle_type == "zimowy_krzak":
		return "zimowykszok"
	if obstacle_type == "woda":
		return "water"
	if obstacle_type == "ruchome_piaski":
		return "quicksand"
	if obstacle_type == "holy_tree":
		return "holy_tree"
	if obstacle_type == "cart":
		return "cart"
	if obstacle_type == "elf_statue":
		return "elf_statue"
	if obstacle_type == "hole":
		return "hole"
	if obstacle_type == "detonator":
		return "detonator"
	return ""


static func _generate_cluster(target_size: int, occupied: Dictionary, obstacle_types_by_cell: Dictionary, obstacle_type: String, rng: RandomNumberGenerator, columns: int, rows: int, setup_columns: int) -> Array[Vector2i]:
	for _attempt in range(200):
		var start: Vector2i = _random_empty_cell(occupied, obstacle_types_by_cell, obstacle_type, rng, columns, rows, setup_columns)
		if start == Vector2i(-1, -1):
			continue
		var cluster: Array[Vector2i] = [start]
		var cluster_cells: Dictionary = {start: true}
		var frontier: Array[Vector2i] = [start]
		while cluster.size() < target_size and not frontier.is_empty():
			frontier.shuffle()
			var current: Vector2i = frontier.pop_front()
			var neighbors: Array[Vector2i] = HexUtilsScript.neighbors(current, columns, rows)
			neighbors.shuffle()
			for neighbor in neighbors:
				if not _can_place_cell(neighbor, occupied, obstacle_types_by_cell, obstacle_type, cluster_cells, columns, rows, setup_columns):
					continue
				cluster.append(neighbor)
				cluster_cells[neighbor] = true
				frontier.append(neighbor)
				if cluster.size() >= target_size:
					break
		return cluster
	return []


static func _random_empty_cell(occupied: Dictionary, obstacle_types_by_cell: Dictionary, obstacle_type: String, rng: RandomNumberGenerator, columns: int, rows: int, setup_columns: int) -> Vector2i:
	for _attempt in range(100):
		var cell := Vector2i(rng.randi_range(setup_columns, columns - setup_columns - 1), rng.randi_range(0, rows - 1))
		if _can_place_cell(cell, occupied, obstacle_types_by_cell, obstacle_type, {}, columns, rows, setup_columns):
			return cell
	return Vector2i(-1, -1)


static func _can_place_cell(cell: Vector2i, occupied: Dictionary, obstacle_types_by_cell: Dictionary, obstacle_type: String, cluster_cells: Dictionary, columns: int, rows: int, setup_columns: int) -> bool:
	if occupied.has(cell) or cluster_cells.has(cell) or cell.x < setup_columns or cell.x >= columns - setup_columns:
		return false
	for neighbor in HexUtilsScript.neighbors(cell, columns, rows):
		if cluster_cells.has(neighbor):
			continue
		var neighbor_type: String = str(obstacle_types_by_cell.get(neighbor, ""))
		if neighbor_type != "" and neighbor_type != obstacle_type:
			return false
		if obstacle_type == "detonator" and neighbor_type == "detonator":
			return false
	return true
