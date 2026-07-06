extends NinePatchRect


func _ready() -> void:
	var content := get_child(0) as Control
	content.minimum_size_changed.connect(_sync_minimum_size)
	_sync_minimum_size()


func _sync_minimum_size() -> void:
	var content := get_child(0) as Control
	var content_min := content.get_minimum_size()
	custom_minimum_size.x = maxf(custom_minimum_size.x, content_min.x)
	custom_minimum_size.y = maxf(custom_minimum_size.y, content_min.y)
