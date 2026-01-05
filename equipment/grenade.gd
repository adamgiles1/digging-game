class_name Grenade extends RigidBody3D

var time_till_explode: float = 2.0
var exploded := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_explode -= delta
	if time_till_explode <= 0 && !exploded:
		explode()

func explode() -> void:
	exploded = true
	$grenade.visible = false
	
	$FragmentationParticle.emitting = true
	$ExplosionParticle.emitting = true
	
	Globals.game_manager.dig(global_position, 4.0)
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
