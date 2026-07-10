class_name HexUtils


static func distance(a: Vector2i, b: Vector2i) -> int:
	var ac: Vector3i = oddr_to_cube(a)
	var bc: Vector3i = oddr_to_cube(b)
	return int((abs(ac.x - bc.x) + abs(ac.y - bc.y) + abs(ac.z - bc.z)) / 2)


static func oddr_to_cube(cell: Vector2i) -> Vector3i:
	var x: int = cell.x - int((cell.y - (cell.y & 1)) / 2)
	var z: int = cell.y
	var y: int = -x - z
	return Vector3i(x, y, z)
