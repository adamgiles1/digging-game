extends Node3D

@onready var model: Node3D = $stalactite/Cube

const max_speed = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		spawn_animation()
	
func spawn_animation() -> void:
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_ELASTIC)
	var squish_amt: float = .05
	var duration: float = .75
	model.scale.y = squish_amt
	model.position.y = 1 - squish_amt
	tween.tween_property(model, "scale:y", 1.0, duration)
	tween.tween_property(model, "position:y", 0, duration)
