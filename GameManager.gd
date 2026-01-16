class_name GameManager extends Node3D

var rock_scn: PackedScene = preload("res://items/rock.tscn")

var voxel_ground: MarchingCubes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game_manager = self
	
	var player: Player = preload("res://player/Player.tscn").instantiate()
	add_child(player)
	player.init(self, Vector3(1, 60, 1))
	init_world()

func dig(pos: Vector3, radius: float, strength = 5.0) -> void:
	print("digging with radius: ", radius)
	# dig out terrain
	var time_start := Time.get_unix_time_from_system()
	voxel_ground.remove_at_spot(pos, randf_range(radius * .8, radius * 1.2), strength)
	var time_end := Time.get_unix_time_from_system()
	Debug.log("digTimeMs", (time_end - time_start) * 1000)

	# unfreeze rocks
	var rocks := get_rocks_by_sphere(pos, radius)
	for rock in rocks:
		rock.dig_touch()

func init_world() -> void:
	for x in range(-10, 10):
		for y in range(-10, -1):
			for z in range(-10, 10):
				spawn_thing(Vector3(x, y, z))
	
	voxel_ground = preload("res://scripts/MarchingCubesGenerator.tscn").instantiate()
	add_child(voxel_ground)
	voxel_ground.initial_generate()

func spawn_thing(pos: Vector3) -> void:
	var rock: Rock = rock_scn.instantiate()
	add_child(rock)
	rock.global_position = pos

func spawn_drone(pos: Vector3) -> Drone:
	var drone: Drone = preload("res://equipment/drones/drone1.tscn").instantiate()
	add_child(drone)
	drone.init(self, pos)
	return drone

func spawn_drone_laser(pos: Vector3, vel: Vector3) -> void:
	var laser: DroneLaser = preload("res://equipment/drones/drone-laser.tscn").instantiate()
	add_child(laser)
	laser.init(pos, vel)

func throw_object(object_scn: PackedScene, pos: Vector3, vel: Vector3) -> Node3D:
	var thrown: RigidBody3D = object_scn.instantiate()
	add_child(thrown)
	thrown.global_position = pos
	thrown.linear_velocity = vel
	return thrown

func get_rocks_by_sphere(pos: Vector3, radius: float) -> Array[Rock]:
	print("checking with radius: ", radius)
	var query := PhysicsShapeQueryParameters3D.new()
	query.transform = Transform3D(Basis(), pos)
	print("query location: ", query.transform)
	query.collision_mask = 4
	query.shape = SphereShape3D.new()
	query.shape.radius = radius
	
	var rocks = get_world_3d().direct_space_state.intersect_shape(query, 100)
	
	print("found ", len(rocks), " rocks")
	if len(rocks) > 0:
		print(rocks[0])
	
	var mapped_array: Array[Rock]
	for thing in rocks:
		if thing["collider"] is Rock:
			mapped_array.append(thing["collider"])
		else:
			print("was something else: ", thing)
	
	return mapped_array
	
