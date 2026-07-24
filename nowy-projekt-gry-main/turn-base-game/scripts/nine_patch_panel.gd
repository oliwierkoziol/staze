extends NinePatchRect

var _base_minimum_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	_base_minimum_size = custom_minimum_size
	var content := get_child(0) as Control
	content.minimum_size_changed.connect(_sync_minimum_size)
	_sync_minimum_size()


func _sync_minimum_size() -> void:
	var content := get_child(0) as Control
	var content_min := content.get_minimum_size()
	custom_minimum_size.x = maxf(_base_minimum_size.x, content_min.x)
	custom_minimum_size.y = maxf(_base_minimum_size.y, content_min.y)
