extends Node3D

var time_left := 2.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	scale *= .1
	tween.tween_property(self, "scale", Vector3.ONE, .5).set_trans(Tween.TRANS_BOUNCE)
	$AudioStreamPlayer3D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	
	if time_left <= 0.0:
		queue_free()
