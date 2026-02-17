class_name Drone extends CharacterBody3D

const speed = 3.0
const ROTATION_SPEED = 1.0

@onready var fans: Array[Node3D] = [$drone/Leg/Fan, $drone/Leg_001/Fan_001, $drone/Leg_002/Fan_002, $drone/Leg_003/Fan_004]
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound

enum DroneMode {SPAWNING, MOVING, TURNING}

var game_manager: GameManager
var time_till_next_decision: float = .1
var actual_movement: Vector3 = Vector3.ZERO
var rotate_towards_point: Vector2 = Vector2.ZERO
var time_till_laser: float = .5
var patrol_height: float = 0.0

var starting_turn_rotation: float = 0.0
var time_turning: float = 0.0

var mode: DroneMode = DroneMode.SPAWNING :
	set(value):
		mode = value

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
			actual_movement *= .1
			time_till_next_decision = make_decision()
		else:
			time_till_next_decision = .01
	# if in patrol mode, make decisions on interval
	elif mode == DroneMode.MOVING:
		if time_till_next_decision <= 0:
			time_till_next_decision = make_decision()
	elif mode == DroneMode.TURNING:
		time_turning += delta
		var finished_rotating = rotate_towards()
		if finished_rotating:
			mode = DroneMode.MOVING
	
	# if turning, dampen speed. Otherwise move
	if mode == DroneMode.TURNING:
		actual_movement = lerp(actual_movement, Vector3.ZERO, delta * 3.0)
	elif mode == DroneMode.SPAWNING:
		actual_movement = lerp(actual_movement, Vector3.DOWN * 10.0, delta)
	elif mode == DroneMode.MOVING:
		actual_movement = lerp(actual_movement, Vector3(0, 0, 3).rotated(Vector3.UP, rotation.y), delta)
	
	if actual_movement:
		velocity = actual_movement
		move_and_slide()
	
	Debug.log("droneMode", mode)
	Debug.log("droneTillDecision", time_till_next_decision)
	Debug.log("droneTillLazer", time_till_laser)
	if mode != DroneMode.SPAWNING && time_till_laser <= 0:
		shoot_laser()
	
	# spin fans
	for fan: Node3D in fans:
		fan.rotate_y(PI * 7.0 * delta)

func make_decision() -> float:
	var dirt_spot := game_manager.get_random_coordinate_of_dirt()
	var destination := Vector3(dirt_spot.x, patrol_height, dirt_spot.y)
	Debug3D.ping(destination)
	
	time_turning = 0.0
	starting_turn_rotation = rotation.y
	rotate_towards_point = (Vector2(destination.x, destination.z) - Vector2(global_position.x, global_position.z))
	
	mode = DroneMode.TURNING
	return randf_range(4.0, 7.0)

func rotate_towards() -> bool:
	var towards: float = atan2(rotate_towards_point.x, rotate_towards_point.y)
	var percent_turn := time_turning / 2.0
	Debug.log("percentTurn", percent_turn)
	rotation.y = lerp(starting_turn_rotation, towards, clampf(percent_turn, 0.0, 1.0))
	return percent_turn >= 1.0

func shoot_laser() -> void:
	time_till_laser = randf_range(.8, 1.2)
	
	# start shooting down and randomly offset
	var direction := Vector3.DOWN \
		.rotated(Vector3.RIGHT, randf_range(-.5, .5)) \
		.rotated(Vector3.FORWARD, randf_range(-.5, .5)) \
		* 10.0
	game_manager.spawn_drone_laser(self.global_position, direction)
	shoot_sound.play()
