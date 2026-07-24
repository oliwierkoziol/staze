extends VBoxContainer

signal skill_pressed(index: int)

const HEADER_COLOR := Color(0.86, 0.72, 0.34, 1.0)
const EMPTY_COLOR := Color(0.55, 0.52, 0.48, 1.0)
const ABILITY_CARD_SCENE: PackedScene = preload("res://scenes/ability_card.tscn")
const AbilityCardScript = preload("res://scripts/ability_card.gd")

var _divider_tex: Texture2D = preload("res://assets/ui/divider.png")
var _cards_row: HBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "UMIEJĘTNOŚCI JEDNOSTKI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.add_theme_font_size_override("font_size", 17)
	add_child(title)

	add_child(_make_horizontal_divider())

	_cards_row = HBoxContainer.new()
	_cards_row.add_theme_constant_override("separation", 8)
	_cards_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_cards_row)


func set_skills(skills: Array) -> void:
	_clear_cards()
	if skills.is_empty():
		var empty := Label.new()
		empty.text = "Ta jednostka nie ma umiejętności."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.add_theme_color_override("font_color", EMPTY_COLOR)
		empty.add_theme_font_size_override("font_size", 12)
		_cards_row.add_child(empty)
		return

	for index in skills.size():
		var card: AbilityCardScript = ABILITY_CARD_SCENE.instantiate()
		_cards_row.add_child(card)
		card.setup(skills[index], index)
		card.activated.connect(_on_card_pressed)


func clear() -> void:
	_clear_cards()


func _clear_cards() -> void:
	for child in _cards_row.get_children():
		child.queue_free()


func _make_horizontal_divider() -> TextureRect:
	var divider := TextureRect.new()
	divider.texture = _divider_tex
	divider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	divider.stretch_mode = TextureRect.STRETCH_SCALE
	divider.custom_minimum_size = Vector2(0, 2)
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return divider


func _on_card_pressed(index: int) -> void:
	skill_pressed.emit(index)
