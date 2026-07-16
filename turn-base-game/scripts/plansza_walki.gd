extends Node2D

signal unit_selected(unit_data: Dictionary)
signal cell_clicked(cell: Vector2i)
signal cell_double_clicked(cell: Vector2i)
signal cell_left_released(cell: Vector2i)
signal cell_right_clicked(cell: Vector2i)
signal cell_hovered(cell: Vector2i)
signal animation_finished(unit_id: int)

const HEX_RADIUS := 42.0
const GRID_COLUMNS := 15
const GRID_ROWS := 10
const SQRT_THREE := 1.7320508
const HEX_FILL_COLOR := Color(0.07, 0.05, 0.02, 0.20)
const HEX_OUTER_BORDER_COLOR := Color(0.14, 0.08, 0.03, 0.86)
const HEX_INNER_BORDER_COLOR := Color(0.76, 0.62, 0.36, 0.42)
const SHOW_OBSTACLE_CONNECTION_DEBUG := false
const UNIT_COUNT_BADGE_BG := Color(0.10, 0.10, 0.08, 0.96)
const UNIT_COUNT_BADGE_BORDER := Color(0.65, 0.52, 0.20, 0.90)
const UNIT_COUNT_BADGE_TEXT := Color(0.95, 0.90, 0.78, 1.0)
const PLAYER_OUTLINE_COLOR := Color(0.35, 0.65, 0.95, 0.95)
const ENEMY_OUTLINE_COLOR := Color(0.92, 0.35, 0.30, 0.95)
const HIDDEN_UNIT_ALPHA := 0.45
const REVEALED_HIDDEN_UNIT_ALPHA := 0.68
const ROCK1_TEXTURE: Texture2D = preload("res://assets/mapTiles/rock1.png")
const ROCK2_TEXTURE: Texture2D = preload("res://assets/mapTiles/rock2.png")
const ROCK2K_TEXTURE: Texture2D = preload("res://assets/mapTiles/rock2k.png")
const ROCK3_TEXTURE: Texture2D = preload("res://assets/mapTiles/rock3.png")
var KRZOK_TEXTURE: Texture2D = load("res://assets/mapTiles/bush.png")
var ZIMOWY_KRZOK_TEXTURE: Texture2D = load("res://assets/mapTiles/zimowykszok.png")
var VINES_TEXTURE: Texture2D = load("res://assets/vines_bottom.png")
const WATER_TEXTURE: Texture2D = preload("res://assets/mapTiles/water.png")
var QUICKSAND_TEXTURE: Texture2D = load("res://assets/mapTiles/quicksand.png")
var DUNE_TEXTURE: Texture2D = load("res://assets/mapTiles/dune.png")
var ICE_TEXTURE: Texture2D = load("res://assets/mapTiles/ice.png")
const ICE_HEX_1_TEXTURE: Texture2D = preload("res://assets/mapTiles/ice_hex_1.png")
const ICE_HEX_2_TEXTURE: Texture2D = preload("res://assets/mapTiles/ice_hex_2.png")
const ICE_HEX_3_TEXTURE: Texture2D = preload("res://assets/mapTiles/ice_hex_3.png")
var HOLY_TREE_TEXTURE: Texture2D = load("res://assets/holy_tree.png")
var HOLY_TREE_LEFT_TEXTURE: Texture2D = load("res://assets/mapTiles/holy_tree/holy_tree_left.png")
var HOLY_TREE_RIGHT_TEXTURE: Texture2D = load("res://assets/mapTiles/holy_tree/holy_tree_right.png")
var HOLY_TREE_TOP_TEXTURE: Texture2D = load("res://assets/mapTiles/holy_tree/holy_tree_top.png")
var HOLY_TREE_BOTTOM_TEXTURE: Texture2D = load("res://assets/mapTiles/holy_tree/holy_tree_bottom.png")
var ELF_STATUE_TEXTURE: Texture2D = load("res://assets/elfStatue.png")
var STATUE_LEFT_TEXTURE: Texture2D = load("res://assets/mapTiles/statue/statue_left.png")
var STATUE_RIGHT_TEXTURE: Texture2D = load("res://assets/mapTiles/statue/statue_right.png")
var STATUE_BOTTOM_TEXTURE: Texture2D = load("res://assets/mapTiles/statue/statue_bottom.png")
var HOLE_TEXTURE: Texture2D = load("res://assets/hole.png")
var HOLE_LEFT_TEXTURE: Texture2D = load("res://assets/newAssets/holeLeft.png")
var HOLE_RIGHT_TEXTURE: Texture2D = load("res://assets/newAssets/holeRight.png")
var CART_TEXTURE: Texture2D = load("res://assets/cart.png")
var DETONATOR_TEXTURE: Texture2D = load("res://assets/detonator.png")
const UnitTypeLibraryScript = preload("res://scripts/unit_type_library.gd")
const GEORGIA_FONT: Font = preload("res://theme/georgia.ttf")
const PROJECTILE_PATH_ARROWS := "res://assets/arrows_projectile.png"
const PROJECTILE_PATH_SPELL := "res://assets/spell_projectile.png"
const PROJECTILE_PATH_FIREBALL := "res://assets/spell_fireball.png"
const PROJECTILE_PATH_DYNAMITE := "res://assets/dynamite.png"
const PROJECTILE_PATH_THROWING_AXE := "res://assets/throwing_axe.png"
const SHIELD_TEXTURE: Texture2D = preload("res://assets/ui/energy_shield.png")
const HexUtilsScript = preload("res://scripts/hex_utils.gd")
var TRAP_TEXTURE: Texture2D = load("res://assets/trap-removebg-preview.png")
var MAGIC_PROJECTION_TEXTURE: Texture2D = load("res://assets/magic_projection.png")

var units: Array = []
var unit_textures: Dictionary = {}
var selected_unit_id := -1
var highlighted_move_cells: Array[Vector2i] = []
var highlighted_attack_cells: Array[Vector2i] = []
var map_event_warning_cells: Array[Vector2i] = []
var detonator_warning_cells: Array[Vector2i] = []
var falling_rock_cells: Array[Vector2i] = []
var move_highlight_opacity_mult: float = 1.0
var hovered_move_path: Array[Vector2i] = []
var hovered_attack_cell := Vector2i(-1, -1)
var hovered_area_cells: Array[Vector2i] = []
var hovered_pull_destination_cell := Vector2i(-1, -1)
var hovered_detonator_preview_cells: Array[Vector2i] = []
var hovered_detonator_preview_rocks: Array[Dictionary] = []
var visual_positions: Dictionary = {}
var active_tweens: Dictionary = {}
var unit_attack_offsets: Dictionary = {}
var unit_shield_flash_alpha: Dictionary = {}
var unit_damage_tint_alpha: Dictionary = {}
var projectile_textures: Dictionary = {}
var active_projectiles: Array[Dictionary] = []
var active_falling_arrows: Array[Dictionary] = []
var arrow_rain_overlay_cells: Array[Vector2i] = []
var arrow_rain_overlay_alpha: float = 0.0
var fireball_overlay_cells: Array[Vector2i] = []
var fireball_overlay_alpha: float = 0.0
var ice_ground_overlay_cells: Array[Vector2i] = []
var ice_ground_overlay_alpha: float = 0.0
var obstacles: Array = []
var statue_buff_cells: Array[Vector2i] = []
var terrain_effects: Array[Dictionary] = []
var hovered_cell := Vector2i(-1, -1)
var viewer_side := "player"
var grid_visible := true


func _ready() -> void:
	if OS.is_debug_build():
		_validate_obstacle_connections()
		_validate_unit_count_badge_layout()
	queue_redraw()


func set_units(new_units: Array) -> void:
	units = []
	unit_textures.clear()
	var valid_unit_ids: Dictionary = {}
	for unit in new_units:
		var copied_unit: Dictionary = unit.duplicate(true)
		var unit_id := int(copied_unit.id)
		units.append(copied_unit)
		unit_textures[unit_id] = _load_unit_portrait(copied_unit)
		valid_unit_ids[unit_id] = true
		if not visual_positions.has(unit_id):
			visual_positions[unit_id] = axial_to_pixel(copied_unit.grid_x, copied_unit.grid_y)
	for unit_id in unit_attack_offsets.keys():
		if not valid_unit_ids.has(unit_id):
			unit_attack_offsets.erase(unit_id)
	for unit_id in unit_shield_flash_alpha.keys():
		if not valid_unit_ids.has(unit_id):
			unit_shield_flash_alpha.erase(unit_id)
	for unit_id in unit_damage_tint_alpha.keys():
		if not valid_unit_ids.has(unit_id):
			unit_damage_tint_alpha.erase(unit_id)
	queue_redraw()


func reset_unit_positions(new_units: Array) -> void:
	visual_positions.clear()
	for unit in new_units:
		visual_positions[int(unit.id)] = axial_to_pixel(unit.grid_x, unit.grid_y)
	queue_redraw()


func snap_unit_to_cell(unit_id: int, cell: Vector2i) -> void:
	visual_positions[unit_id] = axial_to_pixel(cell.x, cell.y)
	queue_redraw()


func set_obstacles(new_obstacles: Array) -> void:
	obstacles = []
	var types_by_cell: Dictionary = {}
	for obstacle in new_obstacles:
		var copied_obstacle: Dictionary = obstacle.duplicate(true)
		var indexed_cell := Vector2i(int(copied_obstacle.get("grid_x", -1)), int(copied_obstacle.get("grid_y", -1)))
		obstacles.append(copied_obstacle)
		types_by_cell[indexed_cell] = str(copied_obstacle.get("type", ""))
	for obstacle in obstacles:
		var obstacle_cell := Vector2i(int(obstacle.get("grid_x", -1)), int(obstacle.get("grid_y", -1)))
		obstacle["connection_mask"] = _get_obstacle_connection_mask(obstacle_cell, str(obstacle.get("type", "")), types_by_cell)
	_rebuild_statue_buff_cells()
	queue_redraw()


func set_terrain_effects(new_effects: Array) -> void:
	terrain_effects = []
	for effect in new_effects:
		terrain_effects.append(effect.duplicate(true))
	queue_redraw()


func set_viewer_side(side: String) -> void:
	viewer_side = side
	queue_redraw()


func set_grid_visible(visible: bool) -> void:
	grid_visible = visible
	queue_redraw()


func get_obstacles() -> Array:
	return obstacles


func get_hovered_cell() -> Vector2i:
	return hovered_cell


func set_selected_unit(unit_id: int) -> void:
	selected_unit_id = unit_id
	queue_redraw()


func set_highlighted_cells(move_cells: Array, attack_cells: Array = [], move_opacity_mult: float = 1.0) -> void:
	highlighted_move_cells.clear()
	highlighted_attack_cells.clear()
	hovered_move_path.clear()
	hovered_attack_cell = Vector2i(-1, -1)
	hovered_area_cells.clear()
	hovered_pull_destination_cell = Vector2i(-1, -1)
	move_highlight_opacity_mult = move_opacity_mult
	for cell in move_cells:
		highlighted_move_cells.append(cell)
	for cell in attack_cells:
		highlighted_attack_cells.append(cell)
	queue_redraw()


func set_map_event_warning_cells(cells: Array) -> void:
	map_event_warning_cells.clear()
	for cell in cells:
		map_event_warning_cells.append(cell)
	queue_redraw()

func set_detonator_warning_cells(cells: Array) -> void:
	detonator_warning_cells.clear()
	for cell in cells:
		detonator_warning_cells.append(cell)
	queue_redraw()

func clear_falling_rock_cells() -> void:
	falling_rock_cells.clear()
	queue_redraw()


func set_hovered_move_path(path: Array) -> void:
	hovered_move_path.clear()
	for cell in path:
		hovered_move_path.append(cell)
	queue_redraw()


func set_hovered_attack_cell(cell: Vector2i) -> void:
	hovered_attack_cell = cell
	hovered_area_cells.clear()
	if cell.x == -1:
		hovered_pull_destination_cell = Vector2i(-1, -1)
	queue_redraw()


func set_hovered_area_skill(center_cell: Vector2i, area_cells: Array) -> void:
	hovered_attack_cell = center_cell
	hovered_area_cells.clear()
	for cell in area_cells:
		hovered_area_cells.append(cell)
	queue_redraw()


func set_hovered_pull_destination_cell(cell: Vector2i) -> void:
	hovered_pull_destination_cell = cell
	queue_redraw()


func set_hovered_detonator_preview(cells: Array) -> void:
	hovered_detonator_preview_cells.clear()
	hovered_detonator_preview_rocks.clear()
	if cells.is_empty():
		queue_redraw()
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for cell in cells:
		if not cell is Vector2i:
			continue
		hovered_detonator_preview_cells.append(cell)
		var cell_center: Vector2 = axial_to_pixel(cell.x, cell.y)
		for _index in 3:
			var lateral_offset: float = rng.randf_range(-18.0, 18.0)
			var start_height: float = HEX_RADIUS * rng.randf_range(1.6, 2.8)
			var position: Vector2 = cell_center + Vector2(lateral_offset, -start_height)
			hovered_detonator_preview_rocks.append({
				"position": position,
				"rotation": rng.randf_range(-0.45, 0.45),
				"scale": rng.randf_range(0.45, 0.80),
				"texture": ROCK1_TEXTURE
			})
	queue_redraw()


func _draw() -> void:
	if grid_visible:
		draw_hex_grid()
	draw_obstacles()
	_draw_statue_buff_cells()
	draw_terrain_effects()
	_draw_cell_highlights(map_event_warning_cells, Color(1.0, 0.25, 0.08, 0.32), Color(1.0, 0.55, 0.12, 0.95))
	_draw_cell_highlights(detonator_warning_cells, Color(0.92, 0.12, 0.12, 0.42), Color(1.0, 0.18, 0.18, 0.95))
	draw_highlighted_cells()
	_draw_hovered_detonator_preview()
	_draw_arrow_rain_overlay()
	_draw_fireball_overlay()
	_draw_ice_ground_overlay()
	draw_units()
	draw_projectiles()


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


func animate_unit_pull_path(unit_id: int, path: Array) -> void:
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
		tween.tween_method(_set_unit_visual_position.bind(unit_id), from_position, target_position, 0.10)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)
		from_position = target_position
	tween.finished.connect(_on_unit_tween_finished.bind(unit_id))


func play_shield_push_animation(caster_id: int, target_id: int) -> void:
	var caster_position: Vector2 = visual_positions.get(caster_id, Vector2.ZERO)
	var target_position: Vector2 = visual_positions.get(target_id, Vector2.ZERO)
	var direction: Vector2 = target_position - caster_position
	if direction.length_squared() <= 0.001:
		return
	var dash_offset: Vector2 = direction.normalized() * 22.0
	var tween: Tween = create_tween()
	tween.parallel().tween_method(_set_unit_shield_flash_alpha.bind(caster_id), 0.0, 0.9, 0.05)
	tween.parallel().tween_method(_set_unit_attack_offset.bind(caster_id), Vector2.ZERO, dash_offset, 0.09)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_unit_attack_offset.bind(caster_id), dash_offset, Vector2.ZERO, 0.11)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	tween.parallel().tween_method(_set_unit_shield_flash_alpha.bind(caster_id), 0.9, 0.0, 0.12)


func animate_unit_knockback_path(unit_id: int, path: Array) -> void:
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
		tween.tween_method(_set_unit_visual_position.bind(unit_id), from_position, target_position, 0.11)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		from_position = target_position
	tween.finished.connect(_on_unit_tween_finished.bind(unit_id))


func play_arrow_rain_animation(caster_id: int, cells: Array) -> void:
	var texture: Texture2D = _get_projectile_texture("arrows")
	if texture == null or cells.is_empty():
		return

	arrow_rain_overlay_cells.clear()
	for cell in cells:
		arrow_rain_overlay_cells.append(cell)

	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_method(_set_arrow_rain_overlay_alpha, 0.0, 0.55, 0.10)
	overlay_tween.tween_method(_set_arrow_rain_overlay_alpha, 0.55, 0.22, 0.28)
	overlay_tween.tween_method(_set_arrow_rain_overlay_alpha, 0.22, 0.0, 0.18)

	if caster_id >= 0:
		var caster_tween: Tween = create_tween()
		caster_tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2.ZERO, Vector2(0.0, -7.0), 0.08)
		caster_tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2(0.0, -7.0), Vector2.ZERO, 0.18)

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var spawn_index := 0
	for cell_index in cells.size():
		var cell: Vector2i = cells[cell_index]
		var arrows_per_cell: int = 4 if cell_index == 0 else 2
		var cell_center: Vector2 = axial_to_pixel(cell.x, cell.y)
		for _arrow_index in arrows_per_cell:
			_spawn_falling_arrow(texture, cell_center, rng, float(spawn_index) * 0.026)
			spawn_index += 1


func play_ice_ground_animation(caster_id: int, cells: Array) -> void:
	if cells.is_empty():
		return

	ice_ground_overlay_cells.clear()
	for cell in cells:
		ice_ground_overlay_cells.append(cell)

	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_method(_set_ice_ground_overlay_alpha, 0.0, 0.58, 0.10)
	overlay_tween.tween_method(_set_ice_ground_overlay_alpha, 0.58, 0.24, 0.28)
	overlay_tween.tween_method(_set_ice_ground_overlay_alpha, 0.24, 0.0, 0.18)

	if caster_id >= 0:
		var caster_tween: Tween = create_tween()
		caster_tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2.ZERO, Vector2(0.0, -7.0), 0.08)
		caster_tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2(0.0, -7.0), Vector2.ZERO, 0.18)


func play_fireball_animation(caster_id: int, center: Vector2i, cells: Array) -> void:
	var texture: Texture2D = _get_projectile_texture("fireball")
	if texture == null:
		return

	if caster_id >= 0:
		var caster_tween: Tween = create_tween()
		caster_tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2.ZERO, Vector2(5.0, -6.0), 0.07)
		caster_tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2(5.0, -6.0), Vector2.ZERO, 0.14)

	var caster_position: Vector2 = visual_positions.get(caster_id, Vector2.ZERO) if caster_id >= 0 else Vector2.ZERO
	var center_position: Vector2 = axial_to_pixel(center.x, center.y)
	var travel_direction: Vector2 = center_position - caster_position
	var travel_duration: float = clampf(caster_position.distance_to(center_position) / 480.0, 0.16, 0.40)
	var projectile: Dictionary = {
		"position": caster_position,
		"texture": texture,
		"rotation": travel_direction.angle()
	}
	active_projectiles.append(projectile)
	var tween: Tween = create_tween()
	tween.tween_method(_set_projectile_position.bind(projectile), caster_position, center_position, travel_duration)
	tween.finished.connect(_on_fireball_projectile_arrived.bind(projectile, cells))


func _on_fireball_projectile_arrived(projectile: Dictionary, cells: Array) -> void:
	active_projectiles.erase(projectile)
	fireball_overlay_cells.clear()
	for cell in cells:
		fireball_overlay_cells.append(cell)
	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_method(_set_fireball_overlay_alpha, 0.0, 0.72, 0.08)
	overlay_tween.tween_method(_set_fireball_overlay_alpha, 0.72, 0.38, 0.16)
	overlay_tween.tween_method(_set_fireball_overlay_alpha, 0.38, 0.0, 0.22)
	queue_redraw()


func play_falling_rocks_animation(cells: Array) -> void:
	var texture: Texture2D = ROCK1_TEXTURE
	if texture == null or cells.is_empty():
		return

	falling_rock_cells.clear()
	for cell in cells:
		falling_rock_cells.append(cell)

	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_method(_set_rock_overlay_alpha, 0.0, 0.55, 0.12)
	overlay_tween.tween_method(_set_rock_overlay_alpha, 0.55, 0.22, 0.32)
	overlay_tween.tween_method(_set_rock_overlay_alpha, 0.22, 0.0, 0.22)

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var spawn_index := 0
	for cell_index in cells.size():
		var cell: Vector2i = cells[cell_index]
		var rocks_per_cell: int = 3
		var cell_center: Vector2 = axial_to_pixel(cell.x, cell.y)
		for _rock_index in rocks_per_cell:
			_spawn_falling_rock(texture, cell_center, rng, float(spawn_index) * 0.045)
			spawn_index += 1


func _set_rock_overlay_alpha(alpha: float) -> void:
	arrow_rain_overlay_alpha = alpha
	queue_redraw()


func _spawn_falling_rock(texture: Texture2D, cell_center: Vector2, rng: RandomNumberGenerator, start_delay: float) -> void:
	var lateral_offset: float = rng.randf_range(-22.0, 22.0)
	var start_height: float = HEX_RADIUS * rng.randf_range(2.4, 3.8)
	var start_position: Vector2 = cell_center + Vector2(lateral_offset, -start_height)
	var impact_position: Vector2 = cell_center + Vector2(lateral_offset * 0.12, rng.randf_range(-6.0, 10.0))
	var rock: Dictionary = {
		"position": start_position,
		"texture": texture,
		"rotation": rng.randf_range(-0.55, 0.55),
		"alpha": 0.0,
		"scale": rng.randf_range(0.55, 0.95)
	}
	active_falling_arrows.append(rock)
	var fall_duration: float = rng.randf_range(0.24, 0.38)
	var tween: Tween = create_tween()
	if start_delay > 0.0:
		tween.tween_interval(start_delay)
	tween.tween_method(_set_falling_arrow_alpha.bind(rock), 0.0, 1.0, 0.06)
	tween.parallel().tween_method(
		_set_falling_arrow_position.bind(rock),
		start_position,
		impact_position,
		fall_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_method(_set_falling_arrow_alpha.bind(rock), 1.0, 0.0, 0.08)
	tween.finished.connect(_on_falling_arrow_finished.bind(rock))


func _spawn_falling_arrow(texture: Texture2D, cell_center: Vector2, rng: RandomNumberGenerator, start_delay: float) -> void:
	var lateral_offset: float = rng.randf_range(-24.0, 24.0)
	var start_height: float = HEX_RADIUS * rng.randf_range(2.2, 3.6)
	var start_position: Vector2 = cell_center + Vector2(lateral_offset, -start_height)
	var impact_position: Vector2 = cell_center + Vector2(lateral_offset * 0.16, rng.randf_range(-8.0, 12.0))
	var arrow: Dictionary = {
		"position": start_position,
		"texture": texture,
		"rotation": PI * 0.5 + rng.randf_range(-0.38, 0.38),
		"alpha": 0.0,
		"scale": rng.randf_range(0.72, 1.08)
	}
	active_falling_arrows.append(arrow)
	var fall_duration: float = rng.randf_range(0.20, 0.34)
	var tween: Tween = create_tween()
	if start_delay > 0.0:
		tween.tween_interval(start_delay)
	tween.tween_method(_set_falling_arrow_alpha.bind(arrow), 0.0, 1.0, 0.05)
	tween.parallel().tween_method(
		_set_falling_arrow_position.bind(arrow),
		start_position,
		impact_position,
		fall_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_method(_set_falling_arrow_alpha.bind(arrow), 1.0, 0.0, 0.07)
	tween.finished.connect(_on_falling_arrow_finished.bind(arrow))


func play_hook_throw_animation(caster_id: int, target_id: int) -> void:
	var caster_position: Vector2 = visual_positions.get(caster_id, Vector2.ZERO)
	var target_position: Vector2 = visual_positions.get(target_id, Vector2.ZERO)
	_spawn_projectile(caster_position, target_position, "arrows")
	var direction: Vector2 = target_position - caster_position
	if direction.length_squared() <= 0.001:
		return
	var dash_offset: Vector2 = direction.normalized() * 10.0
	var tween: Tween = create_tween()
	tween.tween_method(_set_unit_attack_offset.bind(caster_id), Vector2.ZERO, dash_offset, 0.08)
	tween.tween_method(_set_unit_attack_offset.bind(caster_id), dash_offset, Vector2.ZERO, 0.10)


func play_attack_animation(attacker_id: int, target_id: int, projectile_kind: String = "") -> void:
	var attacker_position: Vector2 = visual_positions.get(attacker_id, Vector2.ZERO)
	var target_position: Vector2 = visual_positions.get(target_id, Vector2.ZERO)
	if projectile_kind != "":
		_spawn_projectile(attacker_position, target_position, projectile_kind)
		return
	var direction: Vector2 = target_position - attacker_position
	if direction.length_squared() <= 0.001:
		return
	var dash_offset: Vector2 = direction.normalized() * 12.0
	var tween: Tween = create_tween()
	tween.tween_method(_set_unit_attack_offset.bind(attacker_id), Vector2.ZERO, dash_offset, 0.08)
	tween.tween_method(_set_unit_attack_offset.bind(attacker_id), dash_offset, Vector2.ZERO, 0.10)


func play_damage_animation(unit_id: int) -> void:
	var tween: Tween = create_tween()
	var shake := 0.0
	tween.parallel().tween_method(_set_unit_damage_tint_alpha.bind(unit_id), 0.0, 0.72, 0.03)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2.ZERO, Vector2(-shake, -shake * 0.35), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(-shake, -shake * 0.35), Vector2(shake, -shake * 0.2), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(shake, -shake * 0.2), Vector2(shake * 0.2, shake), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(shake * 0.2, shake), Vector2(-shake, shake * 0.6), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(-shake, shake * 0.6), Vector2(shake * 0.85, -shake * 0.85), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(shake * 0.85, -shake * 0.85), Vector2(-shake * 0.65, shake * 0.3), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(-shake * 0.65, shake * 0.3), Vector2(shake * 0.4, -shake * 0.35), 0.018)
	tween.tween_method(_set_unit_attack_offset.bind(unit_id), Vector2(shake * 0.4, -shake * 0.35), Vector2.ZERO, 0.03)
	tween.parallel().tween_method(_set_unit_damage_tint_alpha.bind(unit_id), 0.72, 0.0, 0.14)


func _set_unit_attack_offset(offset: Vector2, unit_id: int) -> void:
	unit_attack_offsets[unit_id] = offset
	queue_redraw()


func _set_unit_shield_flash_alpha(alpha: float, unit_id: int) -> void:
	unit_shield_flash_alpha[unit_id] = alpha
	queue_redraw()


func _set_unit_damage_tint_alpha(alpha: float, unit_id: int) -> void:
	unit_damage_tint_alpha[unit_id] = alpha
	queue_redraw()


func _spawn_projectile(start_position: Vector2, target_position: Vector2, projectile_kind: String) -> void:
	var texture: Texture2D = _get_projectile_texture(projectile_kind)
	if texture == null:
		return
	var travel_direction: Vector2 = target_position - start_position
	var projectile: Dictionary = {
		"position": start_position,
		"texture": texture,
		"rotation": travel_direction.angle()
	}
	active_projectiles.append(projectile)
	var tween: Tween = create_tween()
	tween.tween_method(_set_projectile_position.bind(projectile), start_position, target_position, 0.14)
	tween.finished.connect(_on_projectile_tween_finished.bind(projectile))


func _set_projectile_position(position: Vector2, projectile: Dictionary) -> void:
	projectile["position"] = position
	queue_redraw()


func _on_projectile_tween_finished(projectile: Dictionary) -> void:
	active_projectiles.erase(projectile)
	queue_redraw()


func _set_falling_arrow_position(position: Vector2, arrow: Dictionary) -> void:
	arrow["position"] = position
	queue_redraw()


func _set_falling_arrow_alpha(alpha: float, arrow: Dictionary) -> void:
	arrow["alpha"] = alpha
	queue_redraw()


func _on_falling_arrow_finished(arrow: Dictionary) -> void:
	active_falling_arrows.erase(arrow)
	queue_redraw()


func _set_arrow_rain_overlay_alpha(alpha: float) -> void:
	arrow_rain_overlay_alpha = alpha
	queue_redraw()


func _set_fireball_overlay_alpha(alpha: float) -> void:
	fireball_overlay_alpha = alpha
	queue_redraw()


func _set_ice_ground_overlay_alpha(alpha: float) -> void:
	ice_ground_overlay_alpha = alpha
	queue_redraw()


func _get_projectile_texture(projectile_kind: String) -> Texture2D:
	if projectile_textures.has(projectile_kind):
		return projectile_textures[projectile_kind]
	var path: String = ""
	match projectile_kind:
		"spell":
			path = PROJECTILE_PATH_SPELL
		"fireball":
			path = PROJECTILE_PATH_FIREBALL
		"arrows":
			path = PROJECTILE_PATH_ARROWS
		"dynamite":
			path = PROJECTILE_PATH_DYNAMITE
		"throwing_axe":
			path = PROJECTILE_PATH_THROWING_AXE
		_:
			return null
	var resource: Resource = load(path)
	var texture: Texture2D = resource as Texture2D
	if texture != null:
		projectile_textures[projectile_kind] = texture
	return texture


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_position: Vector2 = to_local(event.position)
		var next_hovered_cell: Vector2i = get_cell_at_position(local_position)
		if next_hovered_cell != hovered_cell:
			hovered_cell = next_hovered_cell
			cell_hovered.emit(hovered_cell)
		return

	if event is InputEventMouseButton and event.pressed:
		var local_position: Vector2 = to_local(event.position)
		var clicked_cell: Vector2i = get_cell_at_position(local_position)
		if clicked_cell.x == -1:
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				cell_double_clicked.emit(clicked_cell)
			else:
				cell_clicked.emit(clicked_cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cell_right_clicked.emit(clicked_cell)
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_position: Vector2 = to_local(event.position)
		var released_cell: Vector2i = get_cell_at_position(local_position)
		cell_left_released.emit(released_cell)


func draw_hex_grid() -> void:
	for row in GRID_ROWS:
		for column in GRID_COLUMNS:
			var center: Vector2 = axial_to_pixel(column, row)
			var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS)
			var inner_points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 2.0)
			draw_colored_polygon(points, HEX_FILL_COLOR)
			draw_polyline(points + PackedVector2Array([points[0]]), HEX_OUTER_BORDER_COLOR, 2.6)
			draw_polyline(inner_points + PackedVector2Array([inner_points[0]]), HEX_INNER_BORDER_COLOR, 1.5)


func draw_obstacles() -> void:
	var textures: Dictionary = {
		"woda": WATER_TEXTURE,
		"kamienie": ROCK1_TEXTURE,
		"water": WATER_TEXTURE,
		"ruchome_piaski": QUICKSAND_TEXTURE,
		"quicksand": QUICKSAND_TEXTURE,
		"dune": DUNE_TEXTURE,
		"rock1": ROCK1_TEXTURE,
		"rock2": ROCK2_TEXTURE,
		"rock2k": ROCK2K_TEXTURE,
		"rock3": ROCK3_TEXTURE,
		"krzok": KRZOK_TEXTURE,
		"bush": KRZOK_TEXTURE,
		"zimowy_krzak": ZIMOWY_KRZOK_TEXTURE,
		"zimowykszok": ZIMOWY_KRZOK_TEXTURE,
		"ice": ICE_TEXTURE,
		"ice_hex_1": ICE_HEX_1_TEXTURE,
		"ice_hex_2": ICE_HEX_2_TEXTURE,
		"ice_hex_3": ICE_HEX_3_TEXTURE,
		"holy_tree": HOLY_TREE_TEXTURE,
		"holy_tree_single": HOLY_TREE_TEXTURE,
		"holy_tree_left": HOLY_TREE_LEFT_TEXTURE,
		"holy_tree_right": HOLY_TREE_RIGHT_TEXTURE,
		"holy_tree_top": HOLY_TREE_TOP_TEXTURE,
		"holy_tree_bottom": HOLY_TREE_BOTTOM_TEXTURE,
		"swiete_drzewo": HOLY_TREE_TEXTURE,
		"elf_statue": ELF_STATUE_TEXTURE,
		"statue_left": STATUE_LEFT_TEXTURE,
		"statue_right": STATUE_RIGHT_TEXTURE,
		"statue_bottom": STATUE_BOTTOM_TEXTURE,
		"posag_elfow": ELF_STATUE_TEXTURE,
		"hole": HOLE_TEXTURE,
		"hole_left": HOLE_LEFT_TEXTURE,
		"hole_right": HOLE_RIGHT_TEXTURE,
		"dziura": HOLE_TEXTURE,
		"cart": CART_TEXTURE,
		"woz": CART_TEXTURE,
		"detonator": DETONATOR_TEXTURE,
		"magic_projection": MAGIC_PROJECTION_TEXTURE
	}
	var texture_draw_size := Vector2(HEX_RADIUS * 2.0, HEX_RADIUS * 2.0)
	for obstacle in obstacles:
		var cell: Vector2i = Vector2i(int(obstacle.grid_x), int(obstacle.grid_y))
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var variant: String = str(obstacle.get("variant", obstacle.get("type", "")))
		var texture: Texture2D = textures.get(variant)
		if texture == null:
			continue
		var draw_size: Vector2 = Vector2(texture_draw_size.x * 1.1, texture_draw_size.y) if variant.begins_with("ice_hex_") else texture_draw_size
		draw_texture_rect(texture, Rect2(center - draw_size / 2.0, draw_size), false)
	_draw_obstacle_connection_placeholders()


func _rebuild_statue_buff_cells() -> void:
	statue_buff_cells.clear()
	var statue_cells: Dictionary = {}
	for obstacle in obstacles:
		if str(obstacle.get("type", "")) != "elf_statue":
			continue
		var cell := Vector2i(int(obstacle.get("grid_x", -1)), int(obstacle.get("grid_y", -1)))
		if cell.x < 0:
			continue
		statue_cells[cell] = true
	for statue_cell in statue_cells.keys():
		for neighbor in HexUtilsScript.neighbors(statue_cell, GRID_COLUMNS, GRID_ROWS):
			if statue_cells.has(neighbor):
				continue
			if not statue_buff_cells.has(neighbor):
				statue_buff_cells.append(neighbor)


func _draw_statue_buff_cells() -> void:
	if statue_buff_cells.is_empty():
		return
	_draw_cell_highlights(
		statue_buff_cells,
		Color(0.58, 0.38, 0.92, 0.063),
		Color(0.68, 0.48, 0.98, 0.154),
		HEX_RADIUS - 2.0
	)


func _draw_obstacle_connection_placeholders() -> void:
	if not SHOW_OBSTACLE_CONNECTION_DEBUG:
		return
	for obstacle in obstacles:
		var obstacle_type: String = str(obstacle.get("type", ""))
		if obstacle_type == "holy_tree" or obstacle_type == "elf_statue":
			continue
		var mask: int = int(obstacle.get("connection_mask", 0))
		if mask == 0:
			continue
		var cell := Vector2i(int(obstacle.get("grid_x", -1)), int(obstacle.get("grid_y", -1)))
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var color: Color = _get_obstacle_connection_color(str(obstacle.get("type", "")))
		var neighbors: Array[Vector2i] = _get_connection_neighbors(cell)
		for direction in range(6):
			if (mask & (1 << direction)) != 0:
				draw_line(center, axial_to_pixel(neighbors[direction].x, neighbors[direction].y), color, 8.0, true)
		draw_circle(center, 7.0, color)


func _get_obstacle_connection_mask(cell: Vector2i, obstacle_type: String, types_by_cell: Dictionary) -> int:
	if obstacle_type == "":
		return 0
	var mask: int = 0
	var neighbors: Array[Vector2i] = _get_connection_neighbors(cell)
	for direction in range(6):
		if str(types_by_cell.get(neighbors[direction], "")) == obstacle_type:
			mask |= 1 << direction
	return mask


func _get_connection_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var row_offset: int = cell.y & 1
	return [
		cell + Vector2i(1, 0),
		cell + Vector2i(row_offset, 1),
		cell + Vector2i(row_offset - 1, 1),
		cell + Vector2i(-1, 0),
		cell + Vector2i(row_offset - 1, -1),
		cell + Vector2i(row_offset, -1)
	]


func _get_obstacle_connection_color(obstacle_type: String) -> Color:
	var hue: float = float(posmod(obstacle_type.hash(), 360)) / 360.0
	return Color.from_hsv(hue, 0.55, 0.95, 0.42)


func _validate_obstacle_connections() -> void:
	var types_by_cell: Dictionary = {
		Vector2i(4, 4): "test",
		Vector2i(5, 4): "test",
		Vector2i(4, 5): "inny"
	}
	var first_mask: int = _get_obstacle_connection_mask(Vector2i(4, 4), "test", types_by_cell)
	var second_mask: int = _get_obstacle_connection_mask(Vector2i(5, 4), "test", types_by_cell)
	assert((first_mask & 1) != 0, "Przeszkoda musi laczyc sie z tym samym typem po prawej.")
	assert((second_mask & (1 << 3)) != 0, "Polaczenie przeszkod musi dzialac w obie strony.")
	assert((first_mask & (1 << 2)) == 0, "Rozne typy przeszkod nie moga sie laczyc.")


func draw_terrain_effects() -> void:
	for effect in terrain_effects:
		var cell := Vector2i(int(effect.get("grid_x", -1)), int(effect.get("grid_y", -1)))
		if cell.x < 0:
			continue
		if str(effect.get("id", "")) in ["bear_trap", "goblin_trap"]:
			if _should_draw_trap(effect):
				_draw_trap(cell)
			continue
		var color := Color(0.35, 0.80, 1.0, 0.28)
		match str(effect.get("id", "")):
			"fire":
				color = Color(1.0, 0.30, 0.05, 0.34)
			"ice":
				color = Color(0.45, 0.85, 1.0, 0.32)
			"poison_cloud":
				color = Color(0.20, 0.85, 0.25, 0.30)
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 4.0)
		draw_colored_polygon(points, color)
		draw_polyline(points + PackedVector2Array([points[0]]), color.lightened(0.35), 2.0)


const COUNT_REFERENCE_DIGIT := "8"
const COUNT_BASELINE_UP_DIGITS: Array[String] = ["3", "4", "5", "9"]
const STATUS_ARROW_HALF_WIDTH := 4.0
const STATUS_ARROW_HEIGHT := 6.0
const STATUS_ARROW_SPACING := 4.0
const STATUS_ARROW_VERTICAL_GAP := 2.0
const BUFF_ARROW_COLOR := Color(0.32, 0.78, 0.28, 1.0)
const DEBUFF_ARROW_COLOR := Color(0.90, 0.25, 0.22, 1.0)


func _count_baseline_nudge(count_text: String, text_size: Vector2, font: Font, font_size: int) -> float:
	var ref_text_height: float = font.get_string_size(COUNT_REFERENCE_DIGIT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).y
	var half_height_delta: float = (ref_text_height - text_size.y) / 2.0
	if count_text == "6":
		return maxf(1.0, half_height_delta)
	if COUNT_BASELINE_UP_DIGITS.has(count_text):
		return minf(-1.0, -half_height_delta) - 1.0
	return 0.0


func _unit_has_effect_category(unit: Dictionary, category: String) -> bool:
	for effect in unit.get("active_effects", []):
		if str(effect.get("category", "")) == category:
			return true
	return false


func _count_unit_status_arrows(unit: Dictionary) -> int:
	var count := 0
	if _unit_has_effect_category(unit, "buff"):
		count += 1
	if _unit_has_effect_category(unit, "debuff"):
		count += 1
	return count


func _status_arrows_extra_width(status_arrow_count: int) -> float:
	if status_arrow_count <= 0:
		return 0.0
	return STATUS_ARROW_HALF_WIDTH * 2.0 + STATUS_ARROW_SPACING


func _draw_status_arrow(tip: Vector2, points_up: bool, color: Color) -> void:
	var half_width: float = STATUS_ARROW_HALF_WIDTH
	var height: float = STATUS_ARROW_HEIGHT
	var points: PackedVector2Array
	if points_up:
		points = PackedVector2Array([
			tip,
			tip + Vector2(-half_width, height),
			tip + Vector2(half_width, height),
		])
	else:
		points = PackedVector2Array([
			tip,
			tip + Vector2(-half_width, -height),
			tip + Vector2(half_width, -height),
		])
	draw_colored_polygon(points, color)


func _draw_unit_status_arrows(unit: Dictionary, text_position: Vector2, text_size: Vector2, alpha: float) -> void:
	var show_buff: bool = _unit_has_effect_category(unit, "buff")
	var show_debuff: bool = _unit_has_effect_category(unit, "debuff")
	if not show_buff and not show_debuff:
		return
	var column_center_x: float = text_position.x - STATUS_ARROW_SPACING - STATUS_ARROW_HALF_WIDTH
	var text_center_y: float = text_position.y - text_size.y * 0.42
	if show_buff and show_debuff:
		var gap_half: float = STATUS_ARROW_VERTICAL_GAP * 0.5
		var buff_tip_y: float = text_center_y - gap_half - STATUS_ARROW_HEIGHT
		var debuff_tip_y: float = text_center_y + gap_half + STATUS_ARROW_HEIGHT
		var buff_color: Color = BUFF_ARROW_COLOR
		buff_color.a *= alpha
		_draw_status_arrow(Vector2(column_center_x, buff_tip_y), true, buff_color)
		var debuff_color: Color = DEBUFF_ARROW_COLOR
		debuff_color.a *= alpha
		_draw_status_arrow(Vector2(column_center_x, debuff_tip_y), false, debuff_color)
	elif show_buff:
		var buff_color: Color = BUFF_ARROW_COLOR
		buff_color.a *= alpha
		_draw_status_arrow(Vector2(column_center_x, text_center_y - STATUS_ARROW_HEIGHT * 0.15), true, buff_color)
	else:
		var debuff_color: Color = DEBUFF_ARROW_COLOR
		debuff_color.a *= alpha
		_draw_status_arrow(Vector2(column_center_x, text_center_y + STATUS_ARROW_HEIGHT * 0.15), false, debuff_color)


func _compute_unit_count_badge(
	center: Vector2,
	count_text: String,
	font: Font,
	font_size: int,
	status_arrow_count: int = 0
) -> Dictionary:
	var font_ascent: float = font.get_ascent(font_size)
	var font_descent: float = font.get_descent(font_size)
	var text_size: Vector2 = font.get_string_size(count_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var badge_padding := Vector2(8.0, 4.0)
	var arrow_extra_width: float = _status_arrows_extra_width(status_arrow_count)
	var content_width: float = text_size.x + arrow_extra_width
	var badge_size := Vector2(
		maxf(HEX_RADIUS * 0.95 - 6.0, content_width + badge_padding.x),
		font_ascent + font_descent + badge_padding.y
	)
	var badge_rect := Rect2(center + Vector2(-badge_size.x / 2.0, HEX_RADIUS * 0.28), badge_size)
	var base_baseline: float = badge_rect.position.y + (badge_rect.size.y - font_descent - font_ascent) / 2.0 + font_ascent
	var text_position := Vector2(
		badge_rect.position.x + (badge_rect.size.x - content_width) / 2.0 + arrow_extra_width,
		base_baseline + _count_baseline_nudge(count_text, text_size, font, font_size)
	)
	return {"badge_rect": badge_rect, "text_position": text_position, "text_size": text_size}


func _validate_unit_count_badge_layout() -> void:
	var font: Font = GEORGIA_FONT
	var font_size: int = 22
	var text_size_5: Vector2 = font.get_string_size("5", HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var text_size_6: Vector2 = font.get_string_size("6", HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	assert(_count_baseline_nudge("5", text_size_5, font, font_size) <= -2.0, "Cyfra 5 musi byc lekko podniesiona.")
	assert(_count_baseline_nudge("6", text_size_6, font, font_size) >= 1.0, "Cyfra 6 musi byc lekko opusczona.")
	assert(_count_baseline_nudge("8", font.get_string_size("8", HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size), font, font_size) == 0.0, "Cyfra 8 jest punktem odniesienia.")


func _draw_unit_immobilize_vines(unit: Dictionary, center: Vector2, alpha: float, font: Font, font_size: int) -> void:
	if VINES_TEXTURE == null or not _unit_is_immobilized(unit):
		return
	var count_text: String = str(unit.get("count", 0))
	var status_arrow_count: int = _count_unit_status_arrows(unit)
	var badge_rect: Rect2 = _compute_unit_count_badge(center, count_text, font, font_size, status_arrow_count)["badge_rect"]
	var texture_size: Vector2 = VINES_TEXTURE.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var source_region := Rect2(0.0, texture_size.y * 0.50, texture_size.x, texture_size.y * 0.50)
	var vine_size: Vector2 = _fit_rect_size(source_region.size, Vector2(HEX_RADIUS * 2.15, HEX_RADIUS * 1.45))
	var vine_top: float = badge_rect.position.y + badge_rect.size.y + 3.0 - 48.0
	var vine_rect := Rect2(center.x - vine_size.x / 2.0, vine_top, vine_size.x, vine_size.y)
	var max_bottom: float = center.y + HEX_RADIUS - 5.0
	var vine_bottom: float = vine_rect.position.y + vine_rect.size.y
	if vine_bottom > max_bottom:
		vine_rect.position.y -= vine_bottom - max_bottom
	var shadow_center := Vector2(center.x, vine_rect.position.y + vine_rect.size.y - 5.0)
	draw_circle(shadow_center, HEX_RADIUS * 0.34, Color(0.04, 0.16, 0.03, 0.42 * alpha))
	var glow_rect := vine_rect.grow(5.0)
	draw_texture_rect_region(
		VINES_TEXTURE,
		glow_rect,
		source_region,
		Color(0.42, 0.92, 0.30, 0.24 * alpha)
	)
	draw_texture_rect_region(
		VINES_TEXTURE,
		vine_rect,
		source_region,
		Color(0.94, 1.05, 0.90, alpha)
	)


func _fit_rect_size(source_size: Vector2, max_size: Vector2) -> Vector2:
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return max_size
	var scale: float = min(max_size.x / source_size.x, max_size.y / source_size.y)
	return source_size * scale


func _unit_is_immobilized(unit: Dictionary) -> bool:
	for effect in unit.get("active_effects", []):
		if str(effect.get("id", "")) == "immobilize":
			return true
	return false


func _should_draw_trap(effect: Dictionary) -> bool:
	if str(effect.get("caster_side", "")) == viewer_side:
		return true
	var visible := Time.get_ticks_msec() <= int(effect.get("visible_until_ms", 0))
	if visible:
		queue_redraw()
	return visible


func _draw_trap(cell: Vector2i) -> void:
	var center: Vector2 = axial_to_pixel(cell.x, cell.y)
	if TRAP_TEXTURE == null:
		return
	var texture_size := Vector2(HEX_RADIUS * 1.9, HEX_RADIUS * 1.9)
	draw_texture_rect(TRAP_TEXTURE, Rect2(center - texture_size / 2.0, texture_size), false)


func draw_units() -> void:
	var font: Font = GEORGIA_FONT
	var font_size: int = 22
	for unit in units:
		var unit_id := int(unit.id)
		var hidden := bool(unit.get("is_hidden", false))
		var revealed := bool(unit.get("is_revealed", false))
		if hidden and not revealed and not _should_draw_hidden_unit(unit):
			continue
		var alpha := REVEALED_HIDDEN_UNIT_ALPHA if hidden and revealed else HIDDEN_UNIT_ALPHA if hidden else 1.0
		var center: Vector2 = visual_positions.get(unit_id, axial_to_pixel(unit.grid_x, unit.grid_y))
		center += unit_attack_offsets.get(unit_id, Vector2.ZERO)
		var portrait: Texture2D = unit_textures.get(unit_id, null)
		var sprite_size := Vector2(HEX_RADIUS * 1.9, HEX_RADIUS * 2.2)
		var sprite_rect := Rect2(center - Vector2(sprite_size.x / 2.0, sprite_size.y * 0.68), sprite_size)
		var damage_tint_alpha: float = float(unit_damage_tint_alpha.get(unit_id, 0.0))

		var marker_center := center + Vector2(0.0, HEX_RADIUS * 0.18)
		if unit_id == selected_unit_id:
			var outline_radius := HEX_RADIUS * 0.55
			draw_arc(marker_center, outline_radius, 0.0, TAU, 24, Color(1.0, 0.92, 0.45, 0.9 * alpha), 3.0)
		else:
			var team_radius := HEX_RADIUS * 0.52
			var team_color := PLAYER_OUTLINE_COLOR if unit.side == "player" else ENEMY_OUTLINE_COLOR
			team_color.a *= alpha
			draw_arc(marker_center, team_radius, 0.0, TAU, 24, team_color, 2.5)

		if portrait != null:
			var tint: Color = Color(1.0, 1.0 - damage_tint_alpha * 0.82, 1.0 - damage_tint_alpha * 0.82, alpha)
			draw_texture_rect(portrait, sprite_rect, false, tint)

		var shield_alpha: float = float(unit_shield_flash_alpha.get(unit_id, 0.0))
		if shield_alpha > 0.0 and SHIELD_TEXTURE != null:
			var shield_size := Vector2(HEX_RADIUS * 2.1, HEX_RADIUS * 2.1)
			var shield_rect := Rect2(center - shield_size / 2.0, shield_size)
			draw_texture_rect(SHIELD_TEXTURE, shield_rect, false, Color(0.75, 0.9, 1.0, shield_alpha * alpha))

		_draw_unit_immobilize_vines(unit, center, alpha, font, font_size)

		var count_text: String = str(unit.get("count", 0))
		var status_arrow_count: int = _count_unit_status_arrows(unit)
		var badge_data: Dictionary = _compute_unit_count_badge(center, count_text, font, font_size, status_arrow_count)
		var badge_rect: Rect2 = badge_data["badge_rect"]
		var text_position: Vector2 = badge_data["text_position"]
		var text_size: Vector2 = badge_data["text_size"]
		var badge_bg := UNIT_COUNT_BADGE_BG
		var badge_border := UNIT_COUNT_BADGE_BORDER
		var badge_text := UNIT_COUNT_BADGE_TEXT
		badge_bg.a *= alpha
		badge_border.a *= alpha
		badge_text.a *= alpha
		draw_rect(badge_rect, badge_bg, true)
		draw_rect(badge_rect, badge_border, false, 2.0)
		_draw_unit_status_arrows(unit, text_position, text_size, alpha)
		draw_string(font, text_position, count_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, badge_text)


func _should_draw_hidden_unit(unit: Dictionary) -> bool:
	if bool(unit.get("is_revealed", false)):
		return true
	if unit.side == "player":
		return true
	for other in units:
		if other.side != "player":
			continue
		if _units_share_adjacent_bushes(other, unit):
			return true
	return false


func _units_share_adjacent_bushes(observer: Dictionary, target: Dictionary) -> bool:
	var observer_cell := Vector2i(observer.grid_x, observer.grid_y)
	var target_cell := Vector2i(target.grid_x, target.grid_y)
	return _is_bush_cell(observer_cell) and _is_bush_cell(target_cell) and _hex_distance(observer_cell, target_cell) == 1


func _is_bush_cell(cell: Vector2i) -> bool:
	var bush_types: Array[String] = ["krzok", "zimowy_krzak", "holy_tree", "cart"]
	for obstacle in obstacles:
		if int(obstacle.grid_x) == cell.x and int(obstacle.grid_y) == cell.y and bush_types.has(str(obstacle.get("type", ""))):
			return true
	return false


func draw_projectiles() -> void:
	var projectile_size := Vector2(42.0, 42.0)
	for projectile in active_projectiles:
		var texture: Texture2D = projectile.get("texture", null)
		if texture == null:
			continue
		var position: Vector2 = projectile.get("position", Vector2.ZERO)
		var rotation: float = float(projectile.get("rotation", 0.0))
		draw_set_transform(position, rotation, Vector2.ONE)
		draw_texture_rect(texture, Rect2(-projectile_size / 2.0, projectile_size), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for arrow in active_falling_arrows:
		var arrow_texture: Texture2D = arrow.get("texture", null)
		if arrow_texture == null:
			continue
		var arrow_position: Vector2 = arrow.get("position", Vector2.ZERO)
		var arrow_rotation: float = float(arrow.get("rotation", 0.0))
		var arrow_alpha: float = float(arrow.get("alpha", 1.0))
		var arrow_scale: float = float(arrow.get("scale", 1.0))
		var arrow_size: Vector2 = projectile_size * arrow_scale
		draw_set_transform(arrow_position, arrow_rotation, Vector2.ONE * arrow_scale)
		draw_texture_rect(
			arrow_texture,
			Rect2(-arrow_size / 2.0, arrow_size),
			false,
			Color(1.0, 1.0, 1.0, arrow_alpha)
		)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_arrow_rain_overlay() -> void:
	if arrow_rain_overlay_alpha <= 0.0 or arrow_rain_overlay_cells.is_empty():
		return
	for cell in arrow_rain_overlay_cells:
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 4.0)
		draw_colored_polygon(points, Color(0.95, 0.82, 0.38, arrow_rain_overlay_alpha * 0.30))
		draw_polyline(
			points + PackedVector2Array([points[0]]),
			Color(1.0, 0.9, 0.45, arrow_rain_overlay_alpha * 0.88),
			2.5
		)


func _draw_fireball_overlay() -> void:
	if fireball_overlay_alpha <= 0.0 or fireball_overlay_cells.is_empty():
		return
	for cell in fireball_overlay_cells:
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 4.0)
		draw_colored_polygon(points, Color(1.0, 0.38, 0.05, fireball_overlay_alpha * 0.40))
		draw_polyline(
			points + PackedVector2Array([points[0]]),
			Color(1.0, 0.68, 0.14, fireball_overlay_alpha * 0.92),
			2.5
		)


func _draw_ice_ground_overlay() -> void:
	if ice_ground_overlay_alpha <= 0.0 or ice_ground_overlay_cells.is_empty():
		return
	for cell in ice_ground_overlay_cells:
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 4.0)
		draw_colored_polygon(points, Color(0.45, 0.85, 1.0, ice_ground_overlay_alpha * 0.34))
		draw_polyline(
			points + PackedVector2Array([points[0]]),
			Color(0.78, 0.94, 1.0, ice_ground_overlay_alpha * 0.90),
			2.5
		)
func _draw_hovered_detonator_preview() -> void:
	if hovered_detonator_preview_cells.is_empty():
		return
	_draw_cell_highlights(hovered_detonator_preview_cells, Color(0.92, 0.12, 0.12, 0.36), Color(1.0, 0.18, 0.18, 0.90))
	var projectile_size := Vector2(42.0, 42.0)
	for rock in hovered_detonator_preview_rocks:
		var texture: Texture2D = rock.get("texture", null)
		if texture == null:
			continue
		var position: Vector2 = rock.get("position", Vector2.ZERO)
		var rotation: float = float(rock.get("rotation", 0.0))
		var scale: float = float(rock.get("scale", 1.0))
		var size: Vector2 = projectile_size * scale
		draw_set_transform(position, rotation, Vector2.ONE * scale)
		draw_texture_rect(
			texture,
			Rect2(-size / 2.0, size),
			false,
			Color(1.0, 1.0, 1.0, 0.42)
		)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _load_unit_portrait(unit: Dictionary) -> Texture2D:
	var portrait_path: String = str(unit.get("portrait", ""))
	if portrait_path == "":
		var type_id: String = str(unit.get("type_id", ""))
		if type_id != "":
			var type_data: Dictionary = UnitTypeLibraryScript.lookup(type_id)
			portrait_path = str(type_data.get("portrait", ""))
	if portrait_path == "":
		return null
	var res: Resource = load(portrait_path)
	if res is Texture2D:
		return res
	return null


func draw_highlighted_cells() -> void:
	var overlapping_cells: Array[Vector2i] = _get_overlapping_highlight_cells()
	_draw_cell_highlights(
		highlighted_move_cells,
		Color(0.35, 0.72, 0.95, 0.0),
		Color(0.45, 0.82, 1.0, 0.58 * move_highlight_opacity_mult)
	)
	_draw_hovered_move_path()
	var attack_only_cells: Array[Vector2i] = []
	for cell in highlighted_attack_cells:
		if overlapping_cells.has(cell):
			continue
		attack_only_cells.append(cell)
	_draw_cell_highlights(
		attack_only_cells,
		Color(0.82, 0.20, 0.20, 0.0),
		Color(0.62, 0.10, 0.10, 0.95)
	)
	# Dla pól wspólnych: duży (niebieski) rysuje się z ruchu, a w środku rysujemy mniejszy czerwony.
	_draw_cell_highlights(
		overlapping_cells,
		Color(0.82, 0.20, 0.20, 0.0),
		Color(0.62, 0.10, 0.10, 0.95),
		HEX_RADIUS - 12.0
	)
	_draw_hovered_attack_cell()
	_draw_hovered_area_cells()
	_draw_hovered_pull_destination_cell()


func _draw_hovered_pull_destination_cell() -> void:
	if hovered_pull_destination_cell.x == -1:
		return
	var center: Vector2 = axial_to_pixel(hovered_pull_destination_cell.x, hovered_pull_destination_cell.y)
	var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 10.0)
	draw_colored_polygon(points, Color(1.0, 0.72, 0.18, 0.22))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(1.0, 0.78, 0.20, 0.95), 3.0)


func _draw_cell_highlights(cells: Array[Vector2i], fill_color: Color, border_color: Color, radius: float = HEX_RADIUS - 6.0) -> void:
	for cell in cells:
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = _build_hex_points(center, radius)
		draw_colored_polygon(points, fill_color)
		draw_polyline(points + PackedVector2Array([points[0]]), border_color, 2.0)


func _get_overlapping_highlight_cells() -> Array[Vector2i]:
	var overlapping: Array[Vector2i] = []
	for cell in highlighted_move_cells:
		if highlighted_attack_cells.has(cell):
			overlapping.append(cell)
	return overlapping


func _draw_hovered_move_path() -> void:
	if hovered_move_path.is_empty():
		return

	var path_points: Array[Vector2] = []
	if selected_unit_id != -1 and visual_positions.has(selected_unit_id):
		path_points.append(visual_positions[selected_unit_id])
	for cell in hovered_move_path:
		path_points.append(axial_to_pixel(cell.x, cell.y))

	var destination: Vector2 = path_points[path_points.size() - 1]
	var destination_hex: PackedVector2Array = _build_hex_points(destination, HEX_RADIUS - 8.0)
	draw_polyline(destination_hex + PackedVector2Array([destination_hex[0]]), Color(0.60, 0.90, 1.0, 0.90), 3.0)

	for index in range(path_points.size() - 1):
		_draw_dotted_segment(path_points[index], path_points[index + 1], Color(0.45, 0.82, 1.0, 0.85))


func _draw_hovered_attack_cell() -> void:
	if hovered_attack_cell.x == -1:
		return
	if not highlighted_attack_cells.has(hovered_attack_cell) and hovered_area_cells.is_empty():
		return
	var center: Vector2 = axial_to_pixel(hovered_attack_cell.x, hovered_attack_cell.y)
	var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 8.0)
	draw_polyline(points + PackedVector2Array([points[0]]), Color(1.0, 0.30, 0.30, 1.0), 3.0)


func _draw_hovered_area_cells() -> void:
	if hovered_area_cells.is_empty():
		return
	for cell in hovered_area_cells:
		var center: Vector2 = axial_to_pixel(cell.x, cell.y)
		var points: PackedVector2Array = _build_hex_points(center, HEX_RADIUS - 8.0)
		var is_center: bool = cell == hovered_attack_cell
		if is_center:
			draw_colored_polygon(points, Color(0.95, 0.72, 0.22, 0.38))
			draw_polyline(points + PackedVector2Array([points[0]]), Color(1.0, 0.82, 0.28, 0.98), 3.0)
		else:
			draw_colored_polygon(points, Color(0.92, 0.38, 0.22, 0.30))
			draw_polyline(points + PackedVector2Array([points[0]]), Color(1.0, 0.42, 0.26, 0.90), 2.5)


func _draw_dotted_segment(start: Vector2, finish: Vector2, color: Color) -> void:
	var distance: float = start.distance_to(finish)
	if distance <= 0.0:
		draw_circle(start, 3.0, color)
		return

	var step_distance := 14.0
	var step_count: int = maxi(1, int(distance / step_distance))
	for step_index in range(step_count + 1):
		var weight: float = float(step_index) / float(step_count)
		var point: Vector2 = start.lerp(finish, weight)
		draw_circle(point, 3.0, color)


func _build_hex_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for corner in 6:
		var angle: float = deg_to_rad(60.0 * corner - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points


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


func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	return HexUtilsScript.distance(a, b)


func _oddr_to_cube(cell: Vector2i) -> Vector3i:
	return HexUtilsScript.oddr_to_cube(cell)
