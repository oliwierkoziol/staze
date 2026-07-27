extends Node

const BG_MUSIC_BASE_DB := -30.0
const SFX_BASE_DB := -25.0

var build_sound: AudioStreamPlayer
var error_sound: AudioStreamPlayer
var heal_sound: AudioStreamPlayer
var potions_sound: AudioStreamPlayer
var recruit_sound: AudioStreamPlayer
var temple_sound: AudioStreamPlayer
var tree_sound: AudioStreamPlayer
var bg_music: AudioStreamPlayer
var bg_tracks: Array[String] = [
	"res://assets/sounds/bg3.mp3",
	"res://assets/sounds/bgMusic1.mp3",
	"res://assets/sounds/bgMusic2.wav"
]
var current_bg_index: int = 0
var is_bg_playing: bool = false
var bg_fade_tween: Tween

var steps_sound: AudioStreamPlayer
var buy_sound: AudioStreamPlayer
var upgrade_sound: AudioStreamPlayer
var destroyed_sound: AudioStreamPlayer
var buy_play_id: int = 0
var _web_audio_unlocked: bool = not OS.has_feature("web")

func _ready() -> void:
	build_sound = _create_player("res://assets/sounds/builded.mp3")
	error_sound = _create_player("res://assets/sounds/error.mp3")
	heal_sound = _create_player("res://assets/sounds/heal.mp3")
	potions_sound = _create_player("res://assets/sounds/potions.mp3")
	recruit_sound = _create_player("res://assets/sounds/recrut.mp3")
	temple_sound = _create_player("res://assets/sounds/temple.mp3")
	tree_sound = _create_player("res://assets/sounds/tree.mp3")
	
	steps_sound = _create_player("res://assets/sounds/steps.mp3")
	buy_sound = _create_player("res://assets/sounds/buy.mp3")
	upgrade_sound = _create_player("res://assets/sounds/upgrade.mp3")
	destroyed_sound = _create_player("res://assets/sounds/destroyed.mp3")
	
	bg_music = AudioStreamPlayer.new()
	bg_music.bus = &"Music"
	add_child(bg_music)
	GameSettings.register_player_volume(bg_music, BG_MUSIC_BASE_DB)
	bg_music.finished.connect(_on_bg_music_finished)
	if OS.has_feature("web"):
		set_process_input(true)
	GameSettings.audio_volume_changed.connect(_on_audio_volume_changed)


func _on_audio_volume_changed(bus_name: StringName) -> void:
	if bus_name == &"Music" and bg_fade_tween:
		bg_fade_tween.kill()
		bg_fade_tween = null


func _input(event: InputEvent) -> void:
	if _web_audio_unlocked:
		return
	if (event is InputEventMouseButton and event.pressed) \
			or (event is InputEventScreenTouch and event.pressed) \
			or (event is InputEventKey and event.pressed and not event.echo):
		_unlock_web_audio()


func _unlock_web_audio() -> void:
	_web_audio_unlocked = true
	set_process_input(false)
	if is_bg_playing and bg_music and not bg_music.playing:
		_play_current_bg_track()


func _create_player(path: String) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = &"Effects"
	var stream = load(path)
	if stream:
		p.stream = stream
		add_child(p)
		GameSettings.register_player_volume(p, SFX_BASE_DB)
	else:
		push_error("AudioManager: Could not load sound from " + path)
	return p


func _play_sfx(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	GameSettings.apply_player_volume(player, SFX_BASE_DB)
	player.play()


func play_build() -> void: _play_sfx(build_sound)
func play_error() -> void: _play_sfx(error_sound)
func play_heal() -> void: _play_sfx(heal_sound)
func play_potions() -> void: _play_sfx(potions_sound)
func play_recruit() -> void: _play_sfx(recruit_sound)
func play_temple() -> void: _play_sfx(temple_sound)
func play_tree() -> void: _play_sfx(tree_sound)
func play_steps() -> void:
	if steps_sound and not steps_sound.playing:
		_play_sfx(steps_sound)
func stop_steps() -> void: if steps_sound and steps_sound.playing: steps_sound.stop()
func play_bg_music() -> void:
	if not bg_music: return
	is_bg_playing = true
	bg_music.stream_paused = false
	if not bg_music.playing:
		_play_current_bg_track()

func stop_bg_music() -> void:
	is_bg_playing = false
	if bg_music and bg_music.playing:
		if bg_fade_tween: bg_fade_tween.kill()
		bg_fade_tween = create_tween()
		bg_fade_tween.tween_property(bg_music, "volume_db", -80.0, 1.0)
		bg_fade_tween.tween_callback(bg_music.stop)

func pause_bg_music() -> void: if bg_music: bg_music.stream_paused = true
func resume_bg_music() -> void: if bg_music: bg_music.stream_paused = false

func _play_current_bg_track() -> void:
	if bg_tracks.is_empty(): return
	var path = bg_tracks[current_bg_index]
	if not ResourceLoader.exists(path):
		current_bg_index = (current_bg_index + 1) % bg_tracks.size()
		if current_bg_index == 0: return 
		_play_current_bg_track()
		return

	var stream = load(path)
	if stream:
		if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
			stream.loop = false
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
		bg_music.stream = stream
		GameSettings.apply_player_volume(bg_music, BG_MUSIC_BASE_DB)
		bg_music.volume_db = -80.0
		bg_music.play()
		
		if bg_fade_tween: bg_fade_tween.kill()
		bg_fade_tween = create_tween()
		var target_db: float = GameSettings.get_player_volume_db(&"Music", BG_MUSIC_BASE_DB)
		bg_fade_tween.tween_property(bg_music, "volume_db", target_db, 2.0)

func _on_bg_music_finished() -> void:
	if not is_bg_playing: return
	current_bg_index = (current_bg_index + 1) % bg_tracks.size()
	_play_current_bg_track()
func play_buy() -> void:
	if buy_sound:
		buy_play_id += 1
		var current_id = buy_play_id
		_play_sfx(buy_sound)
		await get_tree().create_timer(0.5).timeout
		if buy_play_id == current_id:
			buy_sound.stop()
func play_upgrade() -> void: _play_sfx(upgrade_sound)
func play_destroyed() -> void: _play_sfx(destroyed_sound)
