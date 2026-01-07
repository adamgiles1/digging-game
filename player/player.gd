class_name Player extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D
@onready var interact_ray: RayCast3D = $Camera3D/InteractRay

var game_manager: GameManager

var player_speed = 2
var jump_velocity = 4.5
var dig_size := 1.0

var camera_speed := .001

func init(manager: GameManager, pos: Vector3) -> void:
	game_manager = manager
	global_position = pos

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	### handle movement
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var speed: float = get_current_player_speed()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	### handle inputs
	if Input.is_action_just_pressed("interact") && interact_ray.is_colliding():
		game_manager.dig(interact_ray.get_collision_point(), dig_size)
	
	if Input.is_action_just_pressed("interact_alt"):
		game_manager.dig(global_position - Vector3(0, 1, 0), dig_size * 3)
	if Input.is_action_just_pressed("ui_left"):
		game_manager.throw_object(preload("res://equipment/grenade.tscn"), self.global_position, get_camera_forwards() * 20)
	
	### debug info
	Debug.log("playerPos", global_position)

func get_current_player_speed() -> float:
	if Input.is_key_pressed(KEY_SHIFT):
		return player_speed * 5
	return player_speed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * camera_speed)
		#camera.rotate_y(-event.relative.x * camera_speed)
		camera.rotation.x = clamp(camera.rotation.x + -event.relative.y * camera_speed, -PI/2, PI/2)

func get_camera_forwards() -> Vector3:
	return -camera.global_transform.basis.z
