extends Node3D

@onready
var minecart: Node3D = $minecart

@onready
var axels: Array[Node3D] = [$minecart/Axel, $minecart/Axel_001]

var last_x_pos: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("deposit", -1, .1)
	if minecart.global_position.x != last_x_pos:
		print("yes")
		rotate_wheels(minecart.global_position.x - last_x_pos)
		last_x_pos = minecart.global_position.x

func rotate_wheels(distance: float) -> void:
	for axel: Node3D in axels:
		axel.rotate_z(distance / 10)
