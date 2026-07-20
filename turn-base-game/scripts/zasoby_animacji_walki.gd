class_name ZasobyAnimacjiWalki


const POCISKI: Dictionary = {
	"arrows": preload("res://assets/arrows_projectile.png"),
	"spell": preload("res://assets/spell_projectile.png"),
	"fireball": preload("res://assets/spell_fireball.png"),
	"dynamite": preload("res://assets/dynamite.png"),
	"throwing_axe": preload("res://assets/throwing_axe.png"),
}


static func pobierz_pocisk(projectile_kind: String) -> Texture2D:
	return POCISKI.get(projectile_kind, null) as Texture2D


static func uruchom_pocisk(board: Node2D, start_position: Vector2, target_position: Vector2, projectile_kind: String) -> void:
	var texture: Texture2D = pobierz_pocisk(projectile_kind)
	if texture == null:
		return
	var travel_direction: Vector2 = target_position - start_position
	var projectile: Dictionary = {
		"position": start_position,
		"texture": texture,
		"rotation": travel_direction.angle(),
	}
	board.active_projectiles.append(projectile)
	var tween: Tween = board.create_tween()
	tween.tween_method(board._set_projectile_position.bind(projectile), start_position, target_position, 0.14)
	tween.finished.connect(board._on_projectile_tween_finished.bind(projectile))
