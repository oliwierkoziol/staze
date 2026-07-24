class_name BattleSetupPositions


static func player(count: int, columns: int, rows: int) -> Array[Vector2i]:
	var center_y := rows / 2
	var result: Array[Vector2i] = []
	match count:
		1:
			result = [Vector2i(1, center_y)]
		2:
			result = [Vector2i(1, center_y - 1), Vector2i(1, center_y + 1)]
		3:
			result = [Vector2i(2, center_y), Vector2i(1, center_y - 1), Vector2i(1, center_y + 1)]
		4:
			result = [Vector2i(2, center_y - 1), Vector2i(2, center_y + 1), Vector2i(1, center_y - 2), Vector2i(1, center_y + 2)]
		_:
			for index in count:
				result.append(Vector2i(1 + (index % 2), center_y + index - count / 2))
	return _clamp(result, columns, rows)


static func enemy(count: int, columns: int, rows: int) -> Array[Vector2i]:
	var center_y := rows / 2
	var right_x := columns - 2
	var result: Array[Vector2i] = []
	match count:
		1:
			result = [Vector2i(right_x, center_y)]
		2:
			result = [Vector2i(right_x, center_y - 1), Vector2i(right_x, center_y + 1)]
		3:
			result = [Vector2i(right_x - 1, center_y), Vector2i(right_x, center_y - 1), Vector2i(right_x, center_y + 1)]
		4:
			result = [Vector2i(right_x - 1, center_y - 1), Vector2i(right_x - 1, center_y + 1), Vector2i(right_x, center_y - 2), Vector2i(right_x, center_y + 2)]
		_:
			for index in count:
				result.append(Vector2i(right_x - (index % 2), center_y + index - count / 2))
	return _clamp(result, columns, rows)


static func _clamp(positions: Array[Vector2i], columns: int, rows: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for pos in positions:
		result.append(Vector2i(clampi(pos.x, 0, columns - 1), clampi(pos.y, 0, rows - 1)))
	return result
