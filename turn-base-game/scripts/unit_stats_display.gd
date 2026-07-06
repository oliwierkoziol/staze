extends VBoxContainer

const STAT_COLOR := Color(0.9, 0.87, 0.78, 1.0)
const ICON_SIZE := Vector2(20, 20)
const ROW_V_PADDING := 10

const ICONS := {
	"hp": preload("res://assets/ui/health.png"),
	"dmg": preload("res://assets/ui/damage.png"),
	"def": preload("res://assets/ui/defence.png"),
	"speed": preload("res://assets/ui/speed.png"),
	"count": preload("res://assets/ui/amount.png"),
	"move": preload("res://assets/ui/speed.png"),
	"action_points": preload("res://assets/ui/upgrades.png"),
	"attack_range": preload("res://assets/ui/damage.png"),
	"resistance": preload("res://assets/ui/resistances.png"),
	"buffs": preload("res://assets/ui/buffs.png"),
	"debuffs": preload("res://assets/ui/debuffs.png"),
}

var _divider_tex: Texture2D = preload("res://assets/ui/divider.png")
var _value_labels: Dictionary = {}


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	_build_rows()


func _build_rows() -> void:
	var rows: Array[Dictionary] = [
		{"id": "hp", "label": "HP"},
		{"id": "dmg", "label": "DMG (pojedynczy atak)"},
		{"id": "def", "label": "DEF"},
		{"id": "speed", "label": "Szybkosc"},
		{"id": "count", "label": "Liczebnosc"},
		{"id": "move", "label": "Ruch"},
		{"id": "action_points", "label": "Punkty akcji"},
		{"id": "attack_range", "label": "Zasieg ataku"},
		{"id": "resistance", "label": "Odpornosci"},
		{"id": "buffs", "label": "Buffy"},
		{"id": "debuffs", "label": "Debuffy"},
	]
	for row in rows:
		_add_divider()
		_add_stat_row(str(row.id), str(row.label), ICONS.get(row.id))


func _add_divider() -> void:
	var divider := TextureRect.new()
	divider.texture = _divider_tex
	divider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	divider.stretch_mode = TextureRect.STRETCH_SCALE
	divider.custom_minimum_size = Vector2(0, 2)
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(divider)


func _add_stat_row(id: String, label_text: String, icon_tex: Texture2D) -> void:
	var row := MarginContainer.new()
	row.add_theme_constant_override("margin_top", ROW_V_PADDING)
	row.add_theme_constant_override("margin_bottom", ROW_V_PADDING)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(hbox)

	var icon := TextureRect.new()
	icon.texture = icon_tex
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(icon)

	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_color_override("font_color", STAT_COLOR)
	hbox.add_child(name_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var value_label := Label.new()
	value_label.text = "-"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", STAT_COLOR)
	hbox.add_child(value_label)

	add_child(row)
	_value_labels[id] = value_label


func set_values(values: Dictionary) -> void:
	for id in _value_labels:
		var value_label: Label = _value_labels[id]
		value_label.text = str(values.get(id, "-"))


func clear_values() -> void:
	for id in _value_labels:
		_value_labels[id].text = "-"
