class_name Drone extends CharacterBody3D

const speed = 3.0

@onready var fans: Array[Node3D] = [$drone/Leg/Fan, $drone/Leg_001/Fan_001, $drone/Leg_002/Fan_002, $drone/Leg_003/Fan_004]
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound

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
	
	# spin fans
	for fan: Node3D in fans:
		fan.rotate_y(PI * 5.0 * delta)

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
	
	# start shooting down and randomly offset
	var direction := Vector3.DOWN \
		.rotated(Vector3.RIGHT, randf_range(-.5, .5)) \
		.rotated(Vector3.FORWARD, randf_range(-.5, .5)) \
		* 10.0
	game_manager.spawn_drone_laser(self.global_position, direction)
	shoot_sound.play()
