extends Node

signal audio_volume_changed(bus_name: StringName)

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
var _player_base_volumes: Dictionary = {}
var _volume_levels: Dictionary = {
	&"Master": 100.0,
	&"Music": 100.0,
	&"Effects": 100.0,
	&"Dialogue": 100.0,
}


func _ready() -> void:
	_ensure_audio_buses()
	if OS.has_feature("web"):
		_ensure_web_master_bus_neutral()
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
	if OS.has_feature("web"):
		return float(_volume_levels.get(bus_name, 100.0))
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 100.0
	if AudioServer.is_bus_mute(bus_index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_index)) * 100.0, 0.0, 100.0)


func get_player_volume_db(bus_name: StringName, base_db: float) -> float:
	if not OS.has_feature("web"):
		return base_db
	var master_linear := float(_volume_levels.get(&"Master", 100.0)) / 100.0
	var category_linear := float(_volume_levels.get(bus_name, 100.0)) / 100.0
	var combined_linear := master_linear * category_linear
	if combined_linear <= 0.0:
		return -80.0
	return base_db + linear_to_db(combined_linear)


func apply_player_volume(player: AudioStreamPlayer, base_db: float) -> void:
	if not is_instance_valid(player):
		return
	if OS.has_feature("web"):
		# Na webie:
		# - dla muzyki dajemy Stream (lepsza aktualizacja w trakcie grania)
		# - dla SFX dajemy Sample (mniej problemów/artefaktów bez wątków)
		# Playback_type: Default=0, Stream=1, Sample=2
		player.playback_type = 1 if player.bus == &"Music" else 2
	player.volume_db = get_player_volume_db(player.bus, base_db)


func register_player_volume(player: AudioStreamPlayer, base_db: float) -> void:
	_player_base_volumes[player.get_instance_id()] = {
		"player": player,
		"base_db": base_db,
	}
	apply_player_volume(player, base_db)


func unregister_player_volume(player: AudioStreamPlayer) -> void:
	_player_base_volumes.erase(player.get_instance_id())


func set_audio_volume(bus_name: StringName, value: float, save := true) -> void:
	var normalized_value := clampf(value, 0.0, 100.0)
	if OS.has_feature("web"):
		_volume_levels[bus_name] = normalized_value
		_ensure_web_master_bus_neutral()
		_refresh_all_web_players(bus_name)
		if save:
			_save_audio_settings()
		audio_volume_changed.emit(bus_name)
		return

	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, normalized_value <= 0.0)
	if normalized_value > 0.0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(normalized_value / 100.0))
	if save:
		_save_audio_settings()
	audio_volume_changed.emit(bus_name)


func _ensure_web_master_bus_neutral() -> void:
	var bus_index := AudioServer.get_bus_index(&"Master")
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, false)
	AudioServer.set_bus_volume_db(bus_index, 0.0)


func _sync_master_bus(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(&"Master")
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, value <= 0.0)
	if value > 0.0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))


func _refresh_all_web_players(changed_bus: StringName) -> void:
	if not OS.has_feature("web"):
		return
	for entry in _player_base_volumes.values():
		var player: AudioStreamPlayer = entry.player
		if not is_instance_valid(player):
			continue

		# Przy Master przeliczamy wszystko, przy innych busach tylko to,
		# co odpowiada wybranemu suwakowi.
		if changed_bus != &"Master" and player.bus != changed_bus:
			continue

		apply_player_volume(player, entry.base_db)

		# W trybie Sample Godot może nie zaktualizować głośności dla
		# już grających odtwarzaczy, więc restartujemy SFX.
		if OS.has_feature("web") and player.playback_type == 2 and player.playing:
			player.stop()
			player.play()


func _ensure_audio_buses() -> void:
	for bus_name in AUDIO_BUSES:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus(AudioServer.bus_count)
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
