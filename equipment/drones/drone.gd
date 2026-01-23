class_name Drone extends CharacterBody3D

const speed = 3.0
const ROTATION_SPEED = 2.0

@onready var fans: Array[Node3D] = [$drone/Leg/Fan, $drone/Leg_001/Fan_001, $drone/Leg_002/Fan_002, $drone/Leg_003/Fan_004]
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound

enum DroneMode {SPAWNING, MOVING, TURNING}

var game_manager: GameManager
var time_till_next_decision: float = .1
var movement: Vector3 = Vector3.ZERO
var actual_movement: Vector3 = Vector3.ZERO
var rotate_towards_angle: float = 0.0
var time_till_laser: float = .5
var patrol_height: float = 0.0
var mode: DroneMode = DroneMode.SPAWNING :
	set(value):
		mode = value
		print("value set to: %s" % value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(manager: GameManager, pos: Vector3, _patrol_height: float) -> void:
	game_manager = manager
	global_position = pos
	patrol_height = _patrol_height
	mode = DroneMode.SPAWNING

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_next_decision -= delta
	time_till_laser -= delta
	
	# if spawning, then go down
	if mode == DroneMode.SPAWNING:
		if global_position.y <= patrol_height:
			time_till_next_decision = make_decision()
		else:
			movement = Vector3.DOWN * 10.0
			time_till_next_decision = .2
	# if in patrol mode, make decisions on interval
	elif mode == DroneMode.MOVING:
		if time_till_next_decision <= 0:
			time_till_next_decision = make_decision()
	elif mode == DroneMode.TURNING:
		rotation.y = lerp(rotation.y, rotate_towards_angle, ROTATION_SPEED * delta)
		if is_equal_approx(rotation.y, rotate_towards_angle):
			mode = DroneMode.MOVING
	
	actual_movement = lerp(actual_movement, movement, delta)
	
	if actual_movement:
		velocity = actual_movement
		move_and_slide()
	
	if mode == DroneMode.MOVING && time_till_laser <= 0:
		shoot_laser()
	
	# spin fans
	for fan: Node3D in fans:
		fan.rotate_y(PI * 5.0 * delta)

func make_decision() -> float:	
	var dirt_spot := game_manager.get_random_coordinate_of_dirt()
	var destination := Vector3(dirt_spot.x, patrol_height, dirt_spot.y)
	var direction := (destination - global_position).normalized()
	
	rotate_towards_angle = direction.y
	movement = direction * speed
	
	print("rotating towards: %s\nmovement: %s" % [rotate_towards_angle, movement])
	mode = DroneMode.TURNING
	return randf_range(2.0, 3.0)

func shoot_laser() -> void:
	time_till_laser = .5
	
	# start shooting down and randomly offset
	var direction := Vector3.DOWN \
		.rotated(Vector3.RIGHT, randf_range(-.5, .5)) \
		.rotated(Vector3.FORWARD, randf_range(-.5, .5)) \
		* 10.0
	game_manager.spawn_drone_laser(self.global_position, direction)
	shoot_sound.play()
