extends Node

const DF_GOLD_TEXT := Color(0.86, 0.72, 0.34, 1.0)
const DF_TEXT := Color(0.92, 0.88, 0.78, 1.0)

var _layer: CanvasLayer
var _overlay: Control
var _message: Label
var _busy := false
var _transition_id := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)

	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.visible = false
	_layer.add_child(_overlay)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.02, 0.04, 0.94)
	_overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(360, 0)
	column.add_theme_constant_override("separation", 12)
	center.add_child(column)

	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 22)
	_message.add_theme_color_override("font_color", DF_GOLD_TEXT)
	column.add_child(_message)

	var hint := Label.new()
	hint.text = "Proszę czekać…"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(DF_TEXT.r, DF_TEXT.g, DF_TEXT.b, 0.7))
	column.add_child(hint)


func change_scene(path: String, message := "WCZYTYWANIE") -> Error:
	if _busy:
		return ERR_BUSY
	if not ResourceLoader.exists(path):
		return ERR_FILE_NOT_FOUND
	_busy = true
	_transition_id += 1
	_message.text = message
	_overlay.modulate.a = 1.0
	_overlay.visible = true
	_finish_change.call_deferred(path, _transition_id)
	return OK


func _finish_change(path: String, transition_id: int) -> void:
	await get_tree().process_frame
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		_overlay.visible = false
		_busy = false
		push_error("Nie można zmienić sceny: %s" % error_string(error))
		return
	_busy = false
	await get_tree().process_frame
	if transition_id == _transition_id:
		_overlay.visible = false
