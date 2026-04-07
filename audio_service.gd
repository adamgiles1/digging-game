extends Node

var placeholder_sounds = {
	"explosion": [preload("res://audio/effects/explosion-placeholder.ogg")],
	"shovel-dig": [preload("res://audio/effects/shovel-placeholder.ogg")],
	"buy": [preload("res://audio/effects/buy-placeholder.ogg")],
	"fail-buy": [preload("res://audio/effects/fail-buy-placeholder.ogg")],
	"xray": [preload("res://audio/effects/xray-placeholder.ogg")],
	"step": [preload("res://audio/effects/step-placeholder.ogg"), preload("res://audio/effects/step2-placeholder.ogg"), preload("res://audio/effects/step3-placeholder.ogg")],
	"jump": [preload("res://audio/effects/jump-placeholder.ogg")],
	"tutorial": [preload("res://audio/effects/tutorial-placeholder.ogg")],
	"money": [preload("res://audio/effects/money-placeholder.ogg")],
	"magnet": [preload("res://audio/effects/magnet-placeholder.ogg")],
	"magnet-off": [preload("res://audio/effects/magnet-placeholder.ogg")],
	"magnet-pulse": [preload("res://audio/effects/magnet-pulse-placeholder.ogg")],
	"pickup": [preload("res://audio/effects/rock-pickup-placeholder.ogg")],
	"light": [preload("res://audio/effects/light-placeholder.ogg")],
	"stalactite": [preload("res://audio/effects/stalactite-placeholder.ogg")],
	"land": [preload("res://audio/effects/land-placeholder.ogg")],
}

var real_sounds = {
	"explosion": [preload("res://audio/effects/explosion.wav")],
	"shovel-dig": [preload("res://audio/effects/shovel.wav")],
	"buy": [preload("res://audio/effects/buy.wav")],
	"fail-buy": [preload("res://audio/effects/fail-buy.wav")],
	"xray": [preload("res://audio/effects/xray.wav")],
	"step": [preload("res://audio/effects/step.wav"), preload("res://audio/effects/step2.wav")],# preload("res://audio/effects/step3.wav")],
	"jump": [preload("res://audio/effects/jump.wav")],
	"tutorial": [preload("res://audio/effects/tutorial.wav")],
	"money": [preload("res://audio/effects/money.mp3")],
	"magnet": [preload("res://audio/effects/magnet.wav")],
	"magnet-off": [preload("res://audio/effects/magnet-off.wav")],
	"magnet-pulse": [preload("res://audio/effects/magnet-pulse.wav")],
	"pickup": [preload("res://audio/effects/rock-pickup.wav")],
	"light": [preload("res://audio/effects/light.wav")],
	"stalactite": [preload("res://audio/effects/stalactite.wav")],
	"land": [preload("res://audio/effects/land.wav")],
	"laser": [preload("res://audio/effects/laser.wav")]
}

const AUDIO_POOL_SIZE = 16
var audio_pool: Array[AudioStreamPlayer3D] = []
var pool_next_idx: int = 0

var audio_pool_global: Array[AudioStreamPlayer] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Initializing audio pools")
	audio_pool.resize(AUDIO_POOL_SIZE)
	for i in range(0, AUDIO_POOL_SIZE):
		var player := AudioStreamPlayer3D.new()
		add_child(player)
		audio_pool[i] = player
	audio_pool_global.resize(AUDIO_POOL_SIZE)
	for i in range(0, AUDIO_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		add_child(player)
		audio_pool_global[i] = player
	print("done initializing audio pools")

func current_sounds() -> Dictionary:
	if Globals.use_placeholder_audio:
		return placeholder_sounds
	return real_sounds

func play_3d_sound_effect(type: String, pos: Vector3, volume: float = 1.0) -> void:
	var sounds = current_sounds()
	if sounds.has(type):
		var streams: Array = sounds[type]
		var stream: AudioStream = streams.pick_random()
		var audio: AudioStreamPlayer3D = audio_pool[pool_next_idx]
		audio.global_position = pos
		audio.stream = stream
		audio.pitch_scale = randf_range(.9, 1.1)
		audio.volume_linear = volume
		audio.play()
		increment_index()
	else:
		print("sound effect not found: ", type)

func play_global_sound_effect(type: String, volume: float = 1.0, variance: float = .1) -> void:
	var sounds = current_sounds()
	if sounds.has(type):
		var streams: Array = sounds[type]
		var stream: AudioStream = streams.pick_random()
		var audio: AudioStreamPlayer = audio_pool_global[pool_next_idx]
		audio.stream = stream
		audio.pitch_scale = randf_range(1.0 - variance, 1.0 + variance)
		audio.volume_linear = volume
		audio.play()
		increment_index()
	else:
		print("sound effect not found")

func increment_index() -> void:
	pool_next_idx += 1
	if pool_next_idx >= AUDIO_POOL_SIZE:
		pool_next_idx = 0
