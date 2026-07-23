extends Control

@onready var gra: Control = owner


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ESCAPE:
		if gra != null:
			gra._on_pause_resume_pressed()
		get_viewport().set_input_as_handled()
