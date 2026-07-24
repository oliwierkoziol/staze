extends Node

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
	bg_music.volume_db = -30.0
	add_child(bg_music)
	bg_music.finished.connect(_on_bg_music_finished)

func _create_player(path: String) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	var stream = load(path)
	if stream:
		p.stream = stream
		p.volume_db = -25.0
		add_child(p)
	else:
		push_error("AudioManager: Could not load sound from " + path)
	return p

func play_build() -> void: if build_sound: build_sound.play()
func play_error() -> void: if error_sound: error_sound.play()
func play_heal() -> void: if heal_sound: heal_sound.play()
func play_potions() -> void: if potions_sound: potions_sound.play()
func play_recruit() -> void: if recruit_sound: recruit_sound.play()
func play_temple() -> void: if temple_sound: temple_sound.play()
func play_tree() -> void: if tree_sound: tree_sound.play()
func play_steps() -> void: if steps_sound and not steps_sound.playing: steps_sound.play()
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
		bg_music.volume_db = -80.0
		bg_music.play()
		
		if bg_fade_tween: bg_fade_tween.kill()
		bg_fade_tween = create_tween()
		bg_fade_tween.tween_property(bg_music, "volume_db", -30.0, 2.0)

func _on_bg_music_finished() -> void:
	if not is_bg_playing: return
	current_bg_index = (current_bg_index + 1) % bg_tracks.size()
	_play_current_bg_track()
func play_buy() -> void:
	if buy_sound:
		buy_play_id += 1
		var current_id = buy_play_id
		buy_sound.play()
		await get_tree().create_timer(0.5).timeout
		if buy_play_id == current_id:
			buy_sound.stop()
func play_upgrade() -> void: if upgrade_sound: upgrade_sound.play()
func play_destroyed() -> void: if destroyed_sound: destroyed_sound.play()
