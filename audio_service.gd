extends Node

var sounds := {
	"explosion": [preload("res://audio/effects/explosion-placeholder.wav")],
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

func play_3d_sound_effect(type: String, pos: Vector3, volume: float = 1.0) -> void:
	if sounds.has(type):
		var streams: Array = sounds[type]
		var stream: AudioStreamWAV = streams.pick_random()
		var audio: AudioStreamPlayer3D = audio_pool[pool_next_idx]
		audio.global_position = pos
		audio.stream = stream
		audio.pitch_scale = randf_range(.9, 1.1)
		audio.volume_linear = volume
		audio.play()
		increment_index()
	else:
		print("sound effect not found")

func play_global_sound_effect(type: String) -> void:
	if sounds.has(type):
		var streams: Array = sounds[type]
		var stream: AudioStreamWAV = streams.pick_random()
		var audio: AudioStreamPlayer = audio_pool_global[pool_next_idx]
		audio.stream = stream
		audio.pitch_scale = randf_range(.9, 1.1)
		audio.play()
		increment_index()
	else:
		print("sound effect not found")

func increment_index() -> void:
	pool_next_idx += 1
	if pool_next_idx >= AUDIO_POOL_SIZE:
		pool_next_idx = 0
