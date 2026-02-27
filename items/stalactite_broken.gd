extends Node3D

@onready var parts: Array[Node3D] = []
var time_left: = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parts.append($"stalactite-damaged/Cube-rigid")
	for i in range(1, 8):
		parts.append(get_node("stalactite-damaged/Cube-rigid-00.tscn" % i))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	if time_left < 0:
		for part in parts:
			var tween = create_tween()
			tween.tween_property(part, "scale", Vector3.ZERO, .5)
		
		await get_tree().create_timer(1.0).timeout
		queue_free()
