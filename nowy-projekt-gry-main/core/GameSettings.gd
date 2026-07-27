extends Node

const AUDIO_BUSES: Array[StringName] = [&"Master", &"Music", &"Effects", &"Dialogue"]
const AUDIO_SETTINGS_PATH := "user://audio_settings.cfg"

var current_seed: int = 0
var use_custom_seed: bool = false

var skip_turn_button_delay: bool = false

var debug_mode: bool = false
var campaign_ai_difficulty := "sredni"

func _ready() -> void:
	_ensure_audio_buses()
	_load_audio_settings()
	var emoji_font = load("res://assets/fonts/WindowsEmoji.ttf")
	if emoji_font:
		var default_font = ThemeDB.fallback_font
		if default_font:
			var fallbacks = default_font.fallbacks
			if not emoji_font in fallbacks:
				fallbacks.append(emoji_font)
			default_font.fallbacks = fallbacks


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
