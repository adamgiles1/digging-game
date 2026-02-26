class_name Stalactite extends Node3D

@onready var model: Node3D = $stalactite/Cube
@onready var raycast: RayCast3D = $RayCast3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

const max_speed := 10.0
const gravity := 2.0
var velocity := 0.0
var break_radius: float

var is_broken := false
var is_falling := false
var time_left_to_fall: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left_to_fall -= delta
	if time_left_to_fall < 0:
		start_falling()

func _physics_process(delta: float) -> void:
	if is_falling && ! is_broken:
		velocity = min(velocity + delta * gravity, max_speed)
		global_position.y -= velocity * delta
		if raycast.is_colliding():
			hit_ground(raycast.get_collision_point())

func hit_ground(point: Vector3) -> void:
	Globals.game_manager.dig(point, break_radius)
	model.visible = false
	is_broken = true
	# todo unfreeze rigid bodies
	await get_tree().create_timer(1.0).timeout
	queue_free()

func start_falling():
	is_falling = true
	anim_player.play("falling")

func init(time: float, radius: float) -> void:
	spawn_animation()
	time_left_to_fall = time
	break_radius = radius
	
func spawn_animation() -> void:
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING)
	var squish_amt: float = .0
	var duration: float = .75
	model.scale.y = squish_amt
	model.position.y = 1 - squish_amt
	tween.tween_property(model, "scale:y", 1.0, duration)
	tween.tween_property(model, "position:y", 0, duration)
