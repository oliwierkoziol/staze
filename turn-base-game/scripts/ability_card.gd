class_name AbilityCard
extends Button

signal activated(slot: int)

const NAME_COLOR := Color(0.95, 0.9, 0.78, 1.0)
const DESC_COLOR := Color(0.72, 0.68, 0.6, 1.0)
const CD_COLOR := Color(0.62, 0.58, 0.5, 1.0)
const CD_ACTIVE_COLOR := Color(0.92, 0.55, 0.3, 1.0)

# ponytail: brak dedykowanej ikony w ability_icons — fallback na ability1/2/3.png z tego samego folderu.
const PLACEHOLDER_ICONS: Array[Texture2D] = [
	preload("res://assets/ui/ability_icons/ability1.png"),
	preload("res://assets/ui/ability_icons/ability2.png"),
	preload("res://assets/ui/ability_icons/ability3.png"),
]

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _desc_label: Label = %DescLabel
@onready var _cooldown_label: Label = %CooldownLabel
@onready var _hover_frame: Panel = %HoverFrame
@onready var _select_frame: Panel = %SelectFrame

var _slot: int = -1


func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func setup(skill: Dictionary, slot: int) -> void:
	_slot = slot
	var can_use := bool(skill.get("can_use", false))
	disabled = not can_use
	modulate = Color(0.55, 0.55, 0.55, 1.0) if not can_use else Color.WHITE
	tooltip_text = str(skill.get("tooltip", ""))

	var icon_path: String = str(skill.get("icon", ""))
	if icon_path != "":
		var icon_texture: Resource = load(icon_path)
		if icon_texture is Texture2D:
			_icon.texture = icon_texture
	else:
		_icon.texture = PLACEHOLDER_ICONS[slot % PLACEHOLDER_ICONS.size()]
	_name_label.text = str(skill.get("name", "")).to_upper()

	var description: String = str(skill.get("description", ""))
	_desc_label.visible = description != ""
	if description != "":
		_desc_label.text = description

	_update_cooldown_label(skill)
	_set_selected(bool(skill.get("selected", false)))
	if disabled:
		_hover_frame.visible = false


func _set_selected(selected: bool) -> void:
	_select_frame.visible = selected


func _on_mouse_entered() -> void:
	if not disabled:
		_hover_frame.visible = true


func _on_mouse_exited() -> void:
	_hover_frame.visible = false


func _update_cooldown_label(skill: Dictionary) -> void:
	var cooldown := int(skill.get("cooldown", 0))
	var remaining := int(skill.get("remaining_cooldown", 0))
	if remaining > 0:
		_cooldown_label.text = "CD: %s (za %d)" % [_format_turns(cooldown), remaining]
		_cooldown_label.add_theme_color_override("font_color", CD_ACTIVE_COLOR)
	else:
		_cooldown_label.text = "CD: %s." % _format_turns(cooldown)
		_cooldown_label.add_theme_color_override("font_color", CD_COLOR)


func _on_pressed() -> void:
	activated.emit(_slot)


func _format_turns(turns: int) -> String:
	if turns == 1:
		return "1 tura"
	if turns >= 2 and turns <= 4:
		return "%d tury" % turns
	return "%d tur" % turns
