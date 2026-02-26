class_name GameManager extends Node3D

# markers
@onready var dirt_x_pos_edge: float = $Markers/XPos.global_position.x
@onready var dirt_x_neg_edge: float = $Markers/XNeg.global_position.x
@onready var dirt_z_pos_edge: float = $Markers/ZPos.global_position.z
@onready var dirt_z_neg_edge: float = $Markers/ZNeg.global_position.z
var dirt_top_height: float = 25.0
@onready var spawn_point: Marker3D = $Markers/SpawnPoint
@onready var drone_height: Marker3D = $Markers/DroneHeight

var rock_scenes: Array[PackedScene] = [preload("res://items/RockGrey.tscn"), preload("res://items/RockBrown.tscn"), preload("res://items/RockBlue.tscn")]

var voxel_ground: MarchingCubes



var player_money: int = 0

var tutorial: Tutorial

# shovel fields
var shovel_size: float = .3

# stalactite fields
var stalactites_active := true
var stalactite_cd := 0.0
var stalactite_delay := 10.0
var stalactite_radius: float = .5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game_manager = self
	
	# connect signals
	Signals.purchase_button_pressed.connect(handle_purchase_button)
	
	# spawn player
	var player: Player = preload("res://player/Player.tscn").instantiate()
	add_child(player)
	player.init(self, spawn_point.global_position)
	init_world()

func _process(delta: float) -> void:
	if stalactites_active:
		stalactite_cd -= delta
		if stalactite_cd < 0:
			stalactite_cd = stalactite_delay
			spawn_stalactite(drone_height.global_position)

func dig(pos: Vector3, radius: float, strength = 5.0) -> void:
	# dig out terrain
	var time_start := Time.get_unix_time_from_system()
	voxel_ground.remove_at_spot(pos, radius, strength)
	var time_end := Time.get_unix_time_from_system()
	Debug.log("digTimeMs", (time_end - time_start) * 1000)

	# unfreeze rocks
	var rocks := get_rocks_by_sphere(pos, radius)
	for rock in rocks:
		rock.dig_touch()
	
	Signals.tutorial_progress.emit(Signals.TutorialProgress.DIG, 1)

func init_world() -> void:
	### place rocks
	var start = Time.get_unix_time_from_system()
	for x in range(dirt_x_neg_edge, dirt_x_pos_edge):
		for y in range(20, dirt_top_height):
			for z in range(dirt_z_neg_edge, dirt_z_pos_edge):
				if randi_range(0, 2) == 0:
					var offset := Vector3(randf_range(-.5, .5), randf_range(-.25, .25), randf_range(-.5, .5))
					spawn_rock(Vector3(x, y, z) + offset, Vector3(randf_range(0, TAU), randf_range(0, TAU), randf_range(0, TAU)))
	var end = Time.get_unix_time_from_system()
	print("took ", (end - start), " seconds to place rocks")
	
	voxel_ground = preload("res://scripts/MarchingCubesGenerator.tscn").instantiate()
	add_child(voxel_ground)
	voxel_ground.initial_generate()
	
	# init tutorial
	tutorial = preload("res://interface/Tutorial.tscn").instantiate()
	add_child(tutorial)

func spawn_rock(pos: Vector3, rot: Vector3) -> void:
	var rock: Rock = rock_scenes.pick_random().instantiate()
	add_child(rock)
	rock.global_position = pos
	rock.rotation = rot

func spawn_drone() -> Drone:
	var drone: Drone = preload("res://equipment/drones/drone1.tscn").instantiate()
	add_child(drone)
	drone.init(self, spawn_point.global_position, drone_height.global_position.y)
	return drone

func spawn_drone_laser(pos: Vector3, vel: Vector3) -> void:
	var laser: DroneLaser = preload("res://equipment/drones/drone-laser.tscn").instantiate()
	add_child(laser)
	laser.init(pos, vel)

func spawn_light_at(pos: Vector3, normal: Vector3) -> void:
	var light: Node3D = preload("res://items/lighting/PlaceableLight.tscn").instantiate()
	add_child(light)
	light.global_position = pos
	light.look_at(pos + normal)

func spawn_stalactite(pos: Vector3) -> void:
	var stalactite: Stalactite = preload("res://items/Stalactite.tscn").instantiate()
	add_child(stalactite)
	stalactite.global_position = pos
	stalactite.init(3.0, stalactite_radius)

func get_random_coordinate_of_dirt() -> Vector2:
	return Vector2(randf_range(dirt_x_neg_edge, dirt_x_pos_edge), randf_range(dirt_z_neg_edge, dirt_z_pos_edge))

func throw_object(object_scn: PackedScene, pos: Vector3, vel: Vector3) -> Node3D:
	var thrown: RigidBody3D = object_scn.instantiate()
	add_child(thrown)
	thrown.global_position = pos
	thrown.linear_velocity = vel
	return thrown

func get_rocks_by_sphere(pos: Vector3, radius: float) -> Array[Rock]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.transform = Transform3D(Basis(), pos)
	query.collision_mask = 4
	query.shape = SphereShape3D.new()
	query.shape.radius = radius - .1
	
	var rocks = get_world_3d().direct_space_state.intersect_shape(query, 100)
	
	if len(rocks) > 0:
		print(rocks[0])
	
	var mapped_array: Array[Rock]
	for thing in rocks:
		if thing["collider"] is Rock:
			mapped_array.append(thing["collider"])
		else:
			print("was something else: ", thing)
	
	return mapped_array

func handle_purchase_button(button_pressed: Signals.ButtonAction) -> void:
	match (button_pressed):
		Signals.ButtonAction.BUY_DRONE:
			spawn_drone()
		Signals.ButtonAction.BUY_SHOVEL_UPGRADE:
			print("shovel size increasing")
			shovel_size += .3
			Signals.tutorial_progress.emit(Signals.TutorialProgress.SHOVEL_UPGRADE, 1.0)
		Signals.ButtonAction.TOGGLE_TRACTOR_BEAM:
			print("rock gravity toggled")
			Globals.is_rock_absorber_on = !Globals.is_rock_absorber_on

func add_money(amt: int) -> void:
	player_money += amt
	Debug.log("money", player_money)
