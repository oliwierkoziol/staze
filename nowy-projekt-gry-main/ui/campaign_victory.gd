extends Control

const MAIN_MENU_SCENE := "res://ui/main_menu.tscn"

const DF_GOLD_TEXT := Color(0.86, 0.72, 0.34, 1.0)
const DF_TEXT := Color(0.92, 0.88, 0.78, 1.0)
const PANEL_TEXTURE: Texture2D = preload("res://turn-base-game/assets/ui/panel.png")

@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var menu_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/MenuButton


func _ready() -> void:
	var ui_font := GameSettings.get_ui_font()
	if ui_font != null:
		if theme == null:
			theme = Theme.new()
		theme.default_font = ui_font
	panel.add_theme_stylebox_override("panel", _panel_style())
	_style_button(menu_button)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	SaveManager.pending_battle.clear()
	SceneTransition.change_scene(MAIN_MENU_SCENE, "MENU GŁÓWNE")


func _panel_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = PANEL_TEXTURE
	style.texture_margin_left = 8
	style.texture_margin_top = 8
	style.texture_margin_right = 8
	style.texture_margin_bottom = 8
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return style


func _style_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(280, 56)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.22, 0.14, 0.035, 0.98)
	normal.border_color = Color(0.68, 0.52, 0.2, 1.0)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(5)
	normal.shadow_color = Color(0, 0, 0, 0.65)
	normal.shadow_size = 4
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.34, 0.23, 0.065, 1.0)
	hover.border_color = Color(0.9, 0.75, 0.34, 1.0)
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.12, 0.075, 0.02, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", DF_TEXT)
	button.add_theme_color_override("font_hover_color", DF_GOLD_TEXT)
	button.add_theme_color_override("font_pressed_color", Color(0.82, 0.7, 0.4, 1.0))
	button.add_theme_font_size_override("font_size", 20)
