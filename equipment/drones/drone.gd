class_name Drone extends CharacterBody3D

const speed = 3.0

@onready var ray: RayCast3D = $RayCast3D

var game_manager: GameManager
var time_till_next_decision: float = .1
var movement: Vector3 = Vector3.ZERO
var rotation_speed: float
var time_till_laser: float = .5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(manager: GameManager, pos: Vector3) -> void:
	game_manager = manager
	global_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_next_decision -= delta
	time_till_laser -= delta
	
	if time_till_next_decision <= 0:
		time_till_next_decision = make_decision()
	
	if rotation_speed != 0.0:
		rotate_y(rotation_speed * delta)
	
	if movement:
		velocity = movement.rotated(Vector3.UP, self.rotation.y)
		move_and_slide()
	
	if time_till_laser <= 0:
		shoot_laser()

func make_decision() -> float:
	rotation_speed = 0.0
	movement = Vector3.ZERO
	if randi() % 2:
		# todo adam pick a random spot that is inside the bounds and rotate towards it
		rotation_speed = randf_range(-.5, .5)
		return .5
	else:
		movement = Vector3(0, 0, speed * randf_range(.5, 1.5))
		return randf_range(.5, 1.5)

func shoot_laser() -> void:
	time_till_laser = .5
	
	if ray.is_colliding():
		var point = ray.get_collision_point()
		game_manager.dig(point, .25)
