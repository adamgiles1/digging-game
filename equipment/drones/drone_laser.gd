class_name DroneLaser extends Node3D

@onready var ray: RayCast3D = $RayCast3D

var velocity: Vector3
var exploded := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(pos: Vector3, vel: Vector3) -> void:
	global_position = pos
	velocity = vel
	look_at(self.global_position - velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += velocity * delta
	if ray.is_colliding() && !exploded:
		AudioService.play_3d_sound_effect("explosion", self.global_position, .5)
		Globals.game_manager.dig(ray.get_collision_point(), .25, 1.0)
		queue_free()
		# todo adam add explosion
