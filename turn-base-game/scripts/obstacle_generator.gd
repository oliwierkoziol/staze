class_name ObstacleGenerator

const HexUtilsScript = preload("res://scripts/hex_utils.gd")


static func generate(units: Array, obstacle_types: Array[String], columns: int, rows: int, setup_columns: int, winter_mode: bool = false, max_detonators: int = 2, max_elf_statues: int = 3) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var occupied: Dictionary = {}
	var obstacle_types_by_cell: Dictionary = {}
	var detonator_count: int = 0
	var elf_statue_count: int = 0
	var holy_tree_cluster_count: int = 0
	var statue_cluster_count: int = 0
	for unit in units:
		occupied[Vector2i(unit.grid_x, unit.grid_y)] = true

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	# ponytail: generujemy ustalone formacje dla forest scenario przed losowymi przeszkodami
	if obstacle_types.has("holy_tree"):
		var holy_cluster: Array[Vector2i] = _generate_holy_tree_cluster(occupied, obstacle_types_by_cell, rng, columns, rows, setup_columns)
		if holy_cluster.size() == 4:
			_assign_holy_tree_variants(holy_cluster, result, occupied, obstacle_types_by_cell)
			holy_tree_cluster_count += 1
	if obstacle_types.has("elf_statue"):
		for _statue_index in range(2):
			var statue_cluster: Array[Vector2i] = _generate_statue_cluster(occupied, obstacle_types_by_cell, rng, columns, rows, setup_columns)
			if statue_cluster.size() == 3:
				_assign_statue_variants(statue_cluster, result, occupied, obstacle_types_by_cell)
				statue_cluster_count += 1
				elf_statue_count += 3

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
		if obstacle_type == "elf_statue" and elf_statue_count >= max_elf_statues:
			var fallback_types: Array[String] = obstacle_types.duplicate()
			while fallback_types.has("elf_statue"):
				fallback_types.erase("elf_statue")
			if fallback_types.is_empty():
				continue
			obstacle_type = fallback_types[rng.randi_range(0, fallback_types.size() - 1)]
		if obstacle_type == "holy_tree" and holy_tree_cluster_count >= 1:
			obstacle_type = "holy_tree_single"
		var cluster_size: int = 1 if obstacle_type == "detonator" or obstacle_type == "elf_statue" or obstacle_type == "holy_tree_single" else (rng.randi_range(1, 3) + (1 if cluster_index < 2 else 0))
		var cluster: Array[Vector2i] = _generate_cluster(cluster_size, occupied, obstacle_types_by_cell, obstacle_type, rng, columns, rows, setup_columns)
		for cell in cluster:
			occupied[cell] = true
			var stored_type: String = "holy_tree" if obstacle_type == "holy_tree_single" else obstacle_type
			obstacle_types_by_cell[cell] = stored_type
			if obstacle_type == "detonator":
				detonator_count += 1
			if obstacle_type == "elf_statue":
				elf_statue_count += 1
			var obstacle_data: Dictionary = {
				"grid_x": cell.x,
				"grid_y": cell.y,
				"type": stored_type,
				"variant": _pick_variant(obstacle_type, rng, winter_mode)
			}
			if obstacle_type == "detonator":
				obstacle_data["target_cells"] = _random_detonator_target_cells(cell, columns, rows, rng)
			result.append(obstacle_data)
	return result


static func _random_detonator_target_cells(excluded_cell: Vector2i, columns: int, rows: int, rng: RandomNumberGenerator) -> Array:
	var candidates: Array = []
	for column in columns:
		for row in rows:
			var candidate := Vector2i(column, row)
			if candidate == excluded_cell:
				continue
			candidates.append(candidate)
	candidates.shuffle()
	var count: int = mini(4, candidates.size())
	var result: Array = []
	for index in count:
		result.append(candidates[index])
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
	if obstacle_type == "holy_tree_single":
		return "holy_tree_single"
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


static func _generate_holy_tree_cluster(occupied: Dictionary, obstacle_types_by_cell: Dictionary, rng: RandomNumberGenerator, columns: int, rows: int, setup_columns: int) -> Array[Vector2i]:
	# ponytail: krzyz z centralnym rightem, left po lewej, top i bottom w trojkaty
	var margin: int = 2
	for _attempt in range(100):
		var right_cell: Vector2i = _random_empty_cell(occupied, obstacle_types_by_cell, "holy_tree", rng, columns, rows, setup_columns)
		if right_cell == Vector2i(-1, -1):
			continue
		if right_cell.x < setup_columns + margin or right_cell.x >= columns - setup_columns - margin or right_cell.y < margin or right_cell.y >= rows - margin:
			continue
		var left_cell: Vector2i = right_cell + Vector2i(-1, 0)
		var top_cell: Vector2i
		var bottom_cell: Vector2i
		var row_offset: int = right_cell.y & 1
		if row_offset == 0:
			top_cell = right_cell + Vector2i(-1, -1)
			bottom_cell = right_cell + Vector2i(-1, 1)
		else:
			top_cell = right_cell + Vector2i(0, -1)
			bottom_cell = right_cell + Vector2i(0, 1)
		var cluster_cells: Array[Vector2i] = [right_cell, left_cell, top_cell, bottom_cell]
		var valid: bool = true
		for cell in cluster_cells:
			if not _can_place_cell(cell, occupied, obstacle_types_by_cell, "holy_tree", {}, columns, rows, setup_columns):
				valid = false
				break
		if valid:
			return cluster_cells
	return []


static func _assign_holy_tree_variants(cluster: Array[Vector2i], result: Array[Dictionary], occupied: Dictionary, obstacle_types_by_cell: Dictionary) -> void:
	var right_cell: Vector2i = cluster[0]
	var left_cell: Vector2i = cluster[1]
	var top_cell: Vector2i = cluster[2]
	var bottom_cell: Vector2i = cluster[3]
	var variants: Dictionary = {
		right_cell: "holy_tree_right",
		left_cell: "holy_tree_left",
		top_cell: "holy_tree_top",
		bottom_cell: "holy_tree_bottom"
	}
	for cell in cluster:
		occupied[cell] = true
		obstacle_types_by_cell[cell] = "holy_tree"
		result.append({"grid_x": cell.x, "grid_y": cell.y, "type": "holy_tree", "variant": variants[cell]})


static func _generate_statue_cluster(occupied: Dictionary, obstacle_types_by_cell: Dictionary, rng: RandomNumberGenerator, columns: int, rows: int, setup_columns: int) -> Array[Vector2i]:
	# ponytail: left-right w poziomie, bottom w dolny trojkat pod ich polaczeniem
	var margin: int = 2
	for _attempt in range(100):
		var left_cell: Vector2i = _random_empty_cell(occupied, obstacle_types_by_cell, "elf_statue", rng, columns, rows, setup_columns)
		if left_cell == Vector2i(-1, -1):
			continue
		if left_cell.x < setup_columns + margin or left_cell.x >= columns - setup_columns - margin or left_cell.y < margin or left_cell.y >= rows - margin:
			continue
		var right_cell: Vector2i = left_cell + Vector2i(1, 0)
		var bottom_cell: Vector2i
		var row_offset: int = left_cell.y & 1
		if row_offset == 0:
			bottom_cell = left_cell + Vector2i(0, 1)
		else:
			bottom_cell = left_cell + Vector2i(1, 1)
		var cluster_cells: Array[Vector2i] = [left_cell, right_cell, bottom_cell]
		var valid: bool = true
		for cell in cluster_cells:
			if not _can_place_cell(cell, occupied, obstacle_types_by_cell, "elf_statue", {}, columns, rows, setup_columns):
				valid = false
				break
			for neighbor in HexUtilsScript.neighbors(cell, columns, rows):
				if str(obstacle_types_by_cell.get(neighbor, "")) == "elf_statue":
					valid = false
					break
			if not valid:
				break
		if valid:
			return cluster_cells
	return []


static func _assign_statue_variants(cluster: Array[Vector2i], result: Array[Dictionary], occupied: Dictionary, obstacle_types_by_cell: Dictionary) -> void:
	var left_cell: Vector2i = cluster[0]
	var right_cell: Vector2i = cluster[1]
	var bottom_cell: Vector2i = cluster[2]
	var variants: Dictionary = {
		left_cell: "statue_left",
		right_cell: "statue_right",
		bottom_cell: "statue_bottom"
	}
	for cell in cluster:
		occupied[cell] = true
		obstacle_types_by_cell[cell] = "elf_statue"
		result.append({"grid_x": cell.x, "grid_y": cell.y, "type": "elf_statue", "variant": variants[cell]})


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
		if obstacle_type == "elf_statue" and neighbor_type == "elf_statue":
			return false
	return true
