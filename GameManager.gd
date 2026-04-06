class_name GameManager extends Node3D

# markers
@onready var dirt_x_pos_edge: float = $Markers/XPos.global_position.x
@onready var dirt_x_neg_edge: float = $Markers/XNeg.global_position.x
@onready var dirt_z_pos_edge: float = $Markers/ZPos.global_position.z
@onready var dirt_z_neg_edge: float = $Markers/ZNeg.global_position.z
var dirt_top_height: float = 25.0
@onready var spawn_point: Marker3D = $Markers/SpawnPoint
@onready var drone_height: Marker3D = $Markers/DroneHeight
@onready var stalactite_height: Marker3D = $Markers/StalactiteHeight
@onready var buy_menu: VBoxContainer = $Menu/PanelContainer/VBoxContainer

var rock_scenes: Array[PackedScene] = [preload("res://items/RockGrey.tscn"), preload("res://items/RockBrown.tscn"), preload("res://items/RockBlue.tscn")]

var voxel_ground: MarchingCubes

var is_menu_open := false

var player_money: int = 0

var tutorial: Tutorial

var time_played := 0.0

# stalactite fields
var stalactites_active := false
var stalactite_cd := 0.0
var stalactite_delay := 7.0
var stalactite_radius: float = .5

# levels
var xray_size: float = 0.0
var xray_level: int = 0
var xray_cost: Array[int] = [5, 30, 60, 300]

var shovel_level: int = 1
var shovel_size: float = .3
var shovel_cost: Array[int] = [0, 5, 20, 50, 200]

var drone_level: int = 0
var drone_cost: Array[int] = [5, 10, 15, 20, 25, 30, 40, 50]

var stalactite_level: int = 0
var stalactite_cost: Array[int] = [5, 10, 15, 20, 25, 30, 40, 50]
var stalactite_delays: Array[float] = [7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, .5]

var money_mult_level: int = 0
var money_mult: int = 1
var money_mult_cost: Array[int] = [10, 100]

var magnet_level: int = 0
var magnet_cost: Array[int] = [30]

var minecart_level: int = 1
var minecart_cost: Array[int] = [5, 15, 30, 50]

var world_generate := true

var magnet_pulse_cd := .5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game_manager = self
	
	# connect signals
	Signals.purchase_button_pressed.connect(handle_purchase_button)
	
	# spawn player
	var player: Player = preload("res://player/Player.tscn").instantiate()
	add_child(player)
	player.init(self, spawn_point.global_position)
	
	init_buy_menu()

func _process(delta: float) -> void:
	if world_generate:
		world_generate = false
		init_world()
	
	if stalactites_active:
		stalactite_cd -= delta
		if stalactite_cd < 0:
			stalactite_cd = stalactite_delay
			spawn_stalactite()
	
	if Globals.is_rock_absorber_on:
		magnet_pulse_cd -= delta
		if magnet_pulse_cd <= 0:
			AudioService.play_global_sound_effect("magnet-pulse")
			magnet_pulse_cd = 1.0
	
	### UI
	if Input.is_action_just_pressed("open_menu"):
		is_menu_open = !is_menu_open
		$Menu.visible = is_menu_open
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_menu_open else Input.MOUSE_MODE_CAPTURED
	
	time_played += delta
	Debug.log("timePlayed", time_played)

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

func enter_void() -> void:
	Globals.game_win_time = time_played
	get_tree().change_scene_to_file("res://Ending.tscn")

func init_world() -> void:
	### place rocks
	var start = Time.get_unix_time_from_system()
	for x in range(dirt_x_neg_edge, dirt_x_pos_edge):
		for y in range(5, dirt_top_height):
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
	Signals.tutorial_progress.emit(Signals.TutorialProgress.PLACE_LIGHT, 1.0)
	var light: Node3D = preload("res://items/lighting/PlaceableLight.tscn").instantiate()
	add_child(light)
	light.global_position = pos
	light.look_at(pos + normal)
	AudioService.play_global_sound_effect("light")

func spawn_stalactite() -> void:
	var pos2d := get_random_coordinate_of_dirt()
	
	#ray cast to get roof position
	var query = PhysicsRayQueryParameters3D.new()
	query.from = Vector3(pos2d.x, stalactite_height.global_position.y, pos2d.y)
	query.to = query.from + Vector3(0, 50, 0)
	#Debug3D.ping(query.from)
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if !collision:
		print("couldn't place stalactite")
		return
	
	var stalactite: Stalactite = preload("res://items/Stalactite.tscn").instantiate()
	add_child(stalactite)
	stalactite.global_position = collision["position"]
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
	var is_bought := false
	match (button_pressed):
		Signals.ButtonAction.BUY_DRONE:
			if drone_level < len(drone_cost) && player_money >= drone_cost[drone_level]:
				player_money -= drone_cost[drone_level]
				drone_level += 1
				spawn_drone()
				is_bought = true
		Signals.ButtonAction.STALACTITE:
			if stalactite_level < len(stalactite_cost) && player_money >= stalactite_cost[stalactite_level]:
				player_money -= stalactite_cost[stalactite_level]
				stalactite_delay = stalactite_delays[stalactite_level]
				stalactites_active = true
				stalactite_level += 1
				Debug.log("stalactiteDelay", stalactite_delay)
				is_bought = true
		Signals.ButtonAction.BUY_SHOVEL_UPGRADE:
			if shovel_level < len(shovel_cost) && player_money >= shovel_cost[shovel_level]:
				print("shovel size increasing")
				player_money -= shovel_cost[shovel_level]
				shovel_size += .15
				shovel_level += 1
				Signals.tutorial_progress.emit(Signals.TutorialProgress.SHOVEL_UPGRADE, 1.0)
				is_bought = true
		Signals.ButtonAction.BUY_MAGNET:
			if magnet_level == 0 && player_money >= magnet_cost[magnet_level]:
				print("buying magnet")
				player_money -= magnet_cost[magnet_level]
				magnet_level += 1
				is_bought = true
		Signals.ButtonAction.TOGGLE_TRACTOR_BEAM:
			if magnet_level > 0:
				print("rock gravity toggled")
				Globals.is_rock_absorber_on = !Globals.is_rock_absorber_on
				is_bought = true
				AudioService.play_global_sound_effect("magnet")
		Signals.ButtonAction.XRAY_UPGRADE:
			if xray_level < len(xray_cost) && player_money >= xray_cost[xray_level]:
				print("upgrading xray")
				xray_size += 3.0
				xray_level += 1
				Signals.xray_levelup.emit(xray_size)
				is_bought = true
		Signals.ButtonAction.MULTIPLIER:
			if money_mult_level < len(money_mult_cost) && player_money >= money_mult_cost[money_mult_level]:
				print("upgrading multiplier")
				money_mult_level += 1
				money_mult = 2 ** money_mult_level
				is_bought = true
		Signals.ButtonAction.MINECART:
			if minecart_level < len(minecart_cost) && player_money >= minecart_cost[minecart_level]:
				print("upgrading minecart")
				minecart_level += 1
				Signals.minecart_levelup.emit(minecart_level)
				is_bought = true
	
	if is_bought:
		AudioService.play_global_sound_effect("buy")
	else:
		AudioService.play_global_sound_effect("fail-buy")
	
	update_buy_menu()

func add_money(amt: int) -> void:
	player_money += amt * money_mult
	Debug.log("money", player_money)

func init_buy_menu() -> void:
	$Menu.visible = false
	buy_menu.get_node("HBoxShovel/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.BUY_SHOVEL_UPGRADE)
	)
	buy_menu.get_node("HBoxXray/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.XRAY_UPGRADE)
	)
	buy_menu.get_node("HboxMoneyMult/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.MULTIPLIER)
	)
	buy_menu.get_node("HBoxMinecart/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.MINECART)
	)
	buy_menu.get_node("HBoxMagnet/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.BUY_MAGNET)
	)
	buy_menu.get_node("HBoxDrone/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.BUY_DRONE)
	)
	buy_menu.get_node("HBoxStalactite/Button").pressed.connect(func(): 
		Signals.purchase_button_pressed.emit(Signals.ButtonAction.STALACTITE)
	)
	
	$Menu/QuitButton.pressed.connect(func(): get_tree().quit())
	$Menu/RespawnButton.pressed.connect(func(): Signals.respawn.emit())
	$Menu/AudioSwapButton.pressed.connect(func(): 
		Globals.use_placeholder_audio = !Globals.use_placeholder_audio
		$Menu/AudioSwapButton.text = "Use " + ("Normal" if Globals.use_placeholder_audio else "Placeholder") + " Audio"
	)
	
	$Menu/VolumeSlider.value_changed.connect(func(val):
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), val)
	)
	
	update_buy_menu()

func update_buy_menu() -> void:
	# shovel
	buy_menu.get_node("HBoxShovel/Label2").text = str(shovel_level)
	update_button_cost(buy_menu.get_node("HBoxShovel/Button"), shovel_cost, shovel_level)
	
	# xray
	buy_menu.get_node("HBoxXray/Label2").text = str(xray_level)
	update_button_cost(buy_menu.get_node("HBoxXray/Button"), xray_cost, xray_level)
	
	# drone
	buy_menu.get_node("HBoxDrone/Label2").text = str(drone_level)
	update_button_cost(buy_menu.get_node("HBoxDrone/Button"), drone_cost, drone_level)
	
	# stalactite
	buy_menu.get_node("HBoxStalactite/Label2").text = str(stalactite_level)
	update_button_cost(buy_menu.get_node("HBoxStalactite/Button"), stalactite_cost, stalactite_level)
	
	# money mult
	buy_menu.get_node("HboxMoneyMult/Label2").text = str(money_mult_level)
	update_button_cost(buy_menu.get_node("HboxMoneyMult/Button"), money_mult_cost, money_mult_level)
	
	# magnet
	buy_menu.get_node("HBoxMagnet/Label2").text = str(magnet_level)
	update_button_cost(buy_menu.get_node("HBoxMagnet/Button"), magnet_cost, magnet_level)
	
	# minecart
	buy_menu.get_node("HBoxMinecart/Label2").text = str(minecart_level)
	update_button_cost(buy_menu.get_node("HBoxMinecart/Button"), minecart_cost, minecart_level)
	

func update_button_cost(node: Button, cost_array: Array[int], level: int) -> void:
	if level >= len(cost_array):
		node.disabled = true
		node.text = "Max Level"
	else:
		node.text = "Level Up $" + str(cost_array[level])

func update_inventory(inventory: Inventory) -> void:
	var rock_label: Label = $Inventory/VBoxContainer/RockLabel
	var rock_value_label: Label = $Inventory/VBoxContainer/RockValueLabel
	var money_label: Label = $Inventory/VBoxContainer/MoneyLabel
	rock_label.text = "Rocks held: " + str(len(inventory.stored_rocks))
	rock_value_label.text = "Value of rocks: " + str(inventory.total_value * money_mult)
	money_label.text = "Money: " + str(player_money)
	
