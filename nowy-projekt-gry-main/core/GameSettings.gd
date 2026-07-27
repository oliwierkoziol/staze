extends Node

const AUDIO_BUSES: Array[StringName] = [&"Master", &"Music", &"Effects", &"Dialogue"]
const AUDIO_SETTINGS_PATH := "user://audio_settings.cfg"
const GEORGIA_FONT_PATH := "res://theme/georgia.ttf"
const EMOJI_FONT_PATH := "res://assets/fonts/WindowsEmoji.ttf"
const GEORGIA_THEME_PATH := "res://theme/georgia_theme.tres"

var current_seed: int = 0
var use_custom_seed: bool = false

var skip_turn_button_delay: bool = false

var debug_mode: bool = false
var campaign_ai_difficulty := "sredni"

var _ui_font: Font

func _ready() -> void:
	_ensure_audio_buses()
	_load_audio_settings()
	_ui_font = _build_ui_font()
	if _ui_font:
		ThemeDB.fallback_font = _ui_font
	call_deferred("_apply_root_theme")


func get_ui_font() -> Font:
	return _ui_font


func _build_ui_font() -> Font:
	var georgia_font := load(GEORGIA_FONT_PATH) as Font
	if georgia_font == null:
		push_warning("Nie udało się załadować czcionki Georgia: %s" % GEORGIA_FONT_PATH)
		return null
	var emoji_font := load(EMOJI_FONT_PATH) as Font
	if emoji_font:
		var fallbacks: Array[Font] = georgia_font.fallbacks.duplicate()
		if emoji_font not in fallbacks:
			fallbacks.append(emoji_font)
		georgia_font.fallbacks = fallbacks
	return georgia_font


func _apply_root_theme() -> void:
	if _ui_font == null:
		return
	var georgia_theme := load(GEORGIA_THEME_PATH) as Theme
	if georgia_theme == null:
		return
	var runtime_theme := georgia_theme.duplicate() as Theme
	runtime_theme.default_font = _ui_font
	get_tree().root.theme = runtime_theme


func get_audio_volume(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 100.0
	if AudioServer.is_bus_mute(bus_index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_index)) * 100.0, 0.0, 100.0)


func set_audio_volume(bus_name: StringName, value: float, save := true) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var normalized_value := clampf(value, 0.0, 100.0)
	AudioServer.set_bus_mute(bus_index, normalized_value <= 0.0)
	if normalized_value > 0.0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(normalized_value / 100.0))
	if save:
		_save_audio_settings()


func _ensure_audio_buses() -> void:
	for bus_name in AUDIO_BUSES:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus()
		var bus_index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, bus_name)
		AudioServer.set_bus_send(bus_index, &"Master")


func _load_audio_settings() -> void:
	var config := ConfigFile.new()
	if config.load(AUDIO_SETTINGS_PATH) != OK:
		return
	for bus_name in AUDIO_BUSES:
		set_audio_volume(bus_name, float(config.get_value("audio", String(bus_name), 100.0)), false)


func _save_audio_settings() -> void:
	var config := ConfigFile.new()
	for bus_name in AUDIO_BUSES:
		config.set_value("audio", String(bus_name), get_audio_volume(bus_name))
	var error := config.save(AUDIO_SETTINGS_PATH)
	if error != OK:
		push_warning("Nie udało się zapisać ustawień dźwięku: %s" % error_string(error))
