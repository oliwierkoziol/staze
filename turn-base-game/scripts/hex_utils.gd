static func distance(a: Vector2i, b: Vector2i) -> int:
	var ac: Vector3i = oddr_to_cube(a)
	var bc: Vector3i = oddr_to_cube(b)
	return int((abs(ac.x - bc.x) + abs(ac.y - bc.y) + abs(ac.z - bc.z)) / 2)


static func oddr_to_cube(cell: Vector2i) -> Vector3i:
	var x: int = cell.x - int((cell.y - (cell.y & 1)) / 2)
	var z: int = cell.y
	var y: int = -x - z
	return Vector3i(x, y, z)


static func cube_to_oddr(cube: Vector3i) -> Vector2i:
	var x: int = cube.x + int((cube.z - (cube.z & 1)) / 2)
	return Vector2i(x, cube.z)


static func line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var line_cells: Array[Vector2i] = []
	var line_distance: int = distance(start, end)
	if line_distance == 0:
		return [start]
	var start_cube: Vector3i = oddr_to_cube(start)
	var end_cube: Vector3i = oddr_to_cube(end)
	for step in range(line_distance + 1):
		var t: float = float(step) / float(line_distance)
		line_cells.append(cube_to_oddr(_cube_round(_cube_lerp(start_cube, end_cube, t))))
	return line_cells


static func neighbors(cell: Vector2i, columns: int, rows: int) -> Array[Vector2i]:
	var offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0)]
	if cell.y % 2 == 0:
		offsets.append_array([Vector2i(0, -1), Vector2i(-1, -1), Vector2i(0, 1), Vector2i(-1, 1)])
	else:
		offsets.append_array([Vector2i(1, -1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(0, 1)])

	var result: Array[Vector2i] = []
	for offset in offsets:
		var next: Vector2i = cell + offset
		if next.x >= 0 and next.x < columns and next.y >= 0 and next.y < rows:
			result.append(next)
	return result


static func _cube_round(cube: Vector3) -> Vector3i:
	var rx: int = int(round(cube.x))
	var ry: int = int(round(cube.y))
	var rz: int = int(round(cube.z))
	var dx: float = absf(rx - cube.x)
	var dy: float = absf(ry - cube.y)
	var dz: float = absf(rz - cube.z)
	if dx > dy and dx > dz:
		rx = -ry - rz
	elif dy > dz:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector3i(rx, ry, rz)


static func _cube_lerp(a: Vector3i, b: Vector3i, t: float) -> Vector3:
	return Vector3(lerpf(a.x, b.x, t), lerpf(a.y, b.y, t), lerpf(a.z, b.z, t))
