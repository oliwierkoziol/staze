extends Node2D

signal unit_selected(unit_data: Dictionary)
signal cell_clicked(cell: Vector2i)
signal cell_right_clicked(cell: Vector2i)
signal animation_finished(unit_id: int)

const HEX_RADIUS := 42.0
const GRID_COLUMNS := 15
const GRID_ROWS := 11
const SQRT_THREE := 1.7320508
const GRASS_TEXTURE: Texture2D = preload("res://assets/mapTiles/grass.png")

var units: Array = []
var selected_unit_id := -1
var highlighted_move_cells: Array[Vector2i] = []
var highlighted_attack_cells: Array[Vector2i] = []
var visual_positions: Dictionary = {}
var active_tweens: Dictionary = {}
var obstacles: Array = []


func _ready() -> void:
	queue_redraw()


func set_units(new_units: Array) -> void:
	units = []
	for unit in new_units:
		var copied_unit: Dictionary = unit.duplicate(true)
		units.append(copied_unit)
		if not visual_positions.has(copied_unit.id):
			visual_positions[copied_unit.id] = axial_to_pixel(copied_unit.grid_x, copied_unit.grid_y)
	queue_redraw()


func set_obstacles(new_obstacles: Array) -> void:
	obstacles = []
	for obstacle in new_obstacles:
		obstacles.append(obstacle.duplicate(true))
	queue_redraw()


func get_obstacles() -> Array:
	return obstacles


func set_selected_unit(unit_id: int) -> void:
	selected_unit_id = unit_id
	queue_redraw()


func set_highlighted_cells(move_cells: Array, attack_cells: Array = []) -> void:
	highlighted_move_cells.clear()
	highlighted_attack_cells.clear()
	for cell in move_cells:
		highlighted_move_cells.append(cell)
	for cell in attack_cells:
		highlighted_attack_cells.append(cell)
	queue_redraw()


func _draw() -> void:
	draw_hex_grid()
	draw_obstacles()
	draw_highlighted_cells()
	draw_units()


func animate_unit_path(unit_id: int, path: Array) -> void:
	var current_position: Vector2 = visual_positions.get(unit_id, Vector2.ZERO)
	var points: Array[Vector2] = [current_position]
	for cell in path:
		points.append(axial_to_pixel(cell.x, cell.y))

	if points.size() < 2:
		animation_finished.emit(unit_id)
		return

	if active_tweens.has(unit_id):
		var old_tween: Tween = active_tweens[unit_id]
		old_tween.kill()

	var tween: Tween = create_tween()
	active_tweens[unit_id] = tween
	var from_position: Vector2 = current_position
	for index in range(1, points.size()):
		var target_position: Vector2 = points[index]
		tween.tween_method(_set_unit_visual_position.bind(unit_id), from_position, target_position, 0.12)
		from_position = target_position
	tween.finished.connect(_on_unit_tween_finished.bind(unit_id))


func _set_unit_visual_position(position: Vector2, unit_id: int) -> void:
	visual_positions[unit_id] = position
	queue_redraw()


func _on_unit_tween_finished(unit_id: int) -> void:
	active_tweens.erase(unit_id)
	animation_finished.emit(unit_id)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var local_position: Vector2 = to_local(event.position)
		var clicked_cell: Vector2i = get_cell_at_position(local_position)
		if clicked_cell.x == -1:
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			cell_clicked.emit(clicked_cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cell_right_clicked.emit(clicked_cell)


func draw_hex_grid() -> void:
	var texture_size: Vector2 = GRASS_TEXTURE.get_size()
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var center: Vector2 = axial_to_pixel(column, row)
			var points: PackedVector2Array = PackedVector2Array()
			var uvs: PackedVector2Array = PackedVector2Array()
			for corner in 6:
				var angle: float = deg_to_rad(60.0 * corner - 30.0)
				var offset: Vector2 = Vector2(cos(angle), sin(angle)) * HEX_RADIUS
				var vertex: Vector2 = center + offset
				points.append(vertex)
				uvs.append(_hex_vertex_to_uv(offset, texture_size))
			draw_colored_polygon(points, Color.WHITE, uvs, GRASS_TEXTURE)
			draw_polyline(points + PackedVector2Array([points[0]]), Color(0.33, 0.25, 0.16), 2.0)


func _hex_vertex_to_uv(offset: Vector2, texture_size: Vector2) -> Vector2:
	var half_width: float = HEX_RADIUS * SQRT_THREE / 2.0
	var half_height: float = HEX_RADIUS
	var u: float = (offset.x + half_width) / (half_width * 2.0)
	var v: float = (offset.y + half_height) / (half_height * 2.0)
	return Vector2(u * texture_size.x, v * texture_size.y)


func draw_obstacles() -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 11
	var colors: Dictionary = {
		"woda": Color(0.25, 0.55, 0.85, 0.45),
		"kamienie": Color(0.45, 0.45, 0.48, 0.50),
		"drzewa": Color(0.25, 0.70, 0.35, 0.45)
	}
	var labels: Dictionary = {
		"woda": "WODA",
		"kamienie": "KAMIENIE",
		"drzewa": "DRZEWA"
	}
	for obstacle in obstacles:
		var cell: Vector2i = Vector2i(int(obstacle.grid_x), int(obstacle.grid_y))
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = PackedVector2Array()
		for corner in 6:
			var angle: float = deg_to_rad(60.0 * corner - 30.0)
			points.append(center + Vector2(cos(angle), sin(angle)) * (HEX_RADIUS - 3.0))
		var type: String = str(obstacle.type)
		draw_colored_polygon(points, colors.get(type, Color(0.5, 0.5, 0.5, 0.4)))
		var label: String = labels.get(type, "???")
		var text_size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
		var text_position: Vector2 = center + Vector2(-text_size.x / 2.0, 4.0)
		draw_string(font, text_position, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.12, 0.12, 0.12))


func draw_units() -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 20
	for unit in units:
		var center: Vector2 = visual_positions.get(unit.id, axial_to_pixel(unit.grid_x, unit.grid_y))
		var base_color: Color = Color(0.22, 0.45, 0.85) if unit.side == "player" else Color(0.78, 0.28, 0.24)
		if unit.id == selected_unit_id:
			draw_circle(center, HEX_RADIUS * 0.52, Color(1.0, 0.92, 0.45, 0.95))
			draw_circle(center, HEX_RADIUS * 0.42, base_color)
		else:
			draw_circle(center, HEX_RADIUS * 0.44, base_color)

		draw_string(font, center + Vector2(-14, 7), unit.short_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)

		var count_text: String = str(unit.count)
		var text_size: Vector2 = font.get_string_size(count_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
		var text_position: Vector2 = center + Vector2(-text_size.x / 2.0, -HEX_RADIUS * 0.80)
		draw_string(font, text_position, count_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.12, 0.12, 0.12))


func draw_highlighted_cells() -> void:
	_draw_cell_highlights(
		highlighted_move_cells,
		Color(0.35, 0.72, 0.95, 0.35),
		Color(0.12, 0.46, 0.70, 0.95)
	)
	_draw_cell_highlights(
		highlighted_attack_cells,
		Color(0.82, 0.20, 0.20, 0.32),
		Color(0.62, 0.10, 0.10, 0.95)
	)


func _draw_cell_highlights(cells: Array[Vector2i], fill_color: Color, border_color: Color) -> void:
	for cell in cells:
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = PackedVector2Array()
		for corner in 6:
			var angle: float = deg_to_rad(60.0 * corner - 30.0)
			points.append(center + Vector2(cos(angle), sin(angle)) * (HEX_RADIUS - 6.0))
		draw_colored_polygon(points, fill_color)
		draw_polyline(points + PackedVector2Array([points[0]]), border_color, 2.0)


func get_unit_at_cell(cell: Vector2i) -> Dictionary:
	for unit in units:
		if unit.grid_x == cell.x and unit.grid_y == cell.y:
			return unit
	return {}


func get_unit_at_position(local_mouse_position: Vector2) -> Dictionary:
	var cell: Vector2i = get_cell_at_position(local_mouse_position)
	if cell.x == -1:
		return {}
	return get_unit_at_cell(cell)


func get_cell_at_position(local_mouse_position: Vector2) -> Vector2i:
	var best_cell: Vector2i = Vector2i(-1, -1)
	var best_distance: float = INF
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var center: Vector2 = axial_to_pixel(column, row)
			var distance: float = center.distance_to(local_mouse_position)
			if distance < best_distance:
				best_distance = distance
				best_cell = Vector2i(column, row)

	if best_distance <= HEX_RADIUS:
		return best_cell
	return Vector2i(-1, -1)


func axial_to_pixel(column: int, row: int) -> Vector2:
	var horizontal_spacing: float = HEX_RADIUS * SQRT_THREE
	var vertical_spacing: float = HEX_RADIUS * 1.5
	var x: float = column * horizontal_spacing + (row % 2) * (horizontal_spacing / 2.0)
	var y: float = row * vertical_spacing
	return Vector2(x, y)
