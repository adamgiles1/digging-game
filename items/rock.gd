class_name Rock extends RigidBody3D

@export
var value: int = 1

@export
var rock_name: String = "uh oh"

@export
var rock_mesh: MeshInstance3D

var is_dug_close := false
var is_depositing := false
var no_ground_below := false

var minecart_link: Node3D
var minecart_offset: Vector3 = Vector3.ZERO

const xray_visible_time: int = 1
var xray_time_left := 0.0
var xray_on := false
var xray_mat: BaseMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	xray_mat = preload("res://assets/textures/rock-xray-texture.tres").duplicate()

func _physics_process(delta: float) -> void:
	if xray_on:
		xray_time_left -= delta
		if xray_time_left <= 0:
			xray_on = false
			rock_mesh.set_surface_override_material(0, null)
	
	if self.global_position.y < 0:
		Debug.log_error_count("rockOutOfBounds", 1)
		if no_ground_below:
			Debug.log_error_count("rockWouldHaveBeenPrevented", 1)
		queue_free()
	
	if Globals.is_rock_absorber_on && !is_depositing:
		linear_velocity = (Globals.rock_absorber_spot - global_position).normalized()
	
	if is_depositing && minecart_link != null:
		global_position = minecart_link.global_position + minecart_offset

func check_if_dug_out() -> void:
	var query := PhysicsShapeQueryParameters3D.new()
	query.transform = Transform3D(Basis(), global_position)
	query.collision_mask = 0b01
	query.shape = SphereShape3D.new()
	query.shape.radius = .3
	
	var size: int = len(get_world_3d().direct_space_state.intersect_shape(query, 1))
	
	if size == 0:
		fully_dug_out()

func dig_touch() -> void:
	is_dug_close = true
	check_if_dug_out()
	if !Signals.ground_changed.is_connected(check_if_dug_out):
		Signals.ground_changed.connect(check_if_dug_out)

func fully_dug_out() -> void:
	if is_nothing_below():
		return # if no ground is below, then we shouldn't dig out
	freeze = false
	if Signals.ground_changed.is_connected(check_if_dug_out):
		Signals.ground_changed.disconnect(check_if_dug_out)

func collect(inventory: Inventory) -> void:
	print("collecting rock")
	inventory.add_rock(self)
	global_position = Vector3(1000, 1000, 1000)
	freeze = true
	AudioService.play_global_sound_effect("pickup")

func deposit(pos: Vector3) -> void:
	linear_velocity = Vector3.ZERO
	global_position = pos
	freeze = false
	is_depositing = true
	Signals.rock_deposit_finished.connect(finish_deposit)

func finish_deposit() -> void:
	Globals.game_manager.add_money(value)
	AudioService.play_global_sound_effect("money")
	queue_free()

func is_nothing_below() -> bool:
	var world_3d := get_world_3d().direct_space_state
	var from: Vector3 = self.global_position
	var to: Vector3 = self.global_position + Vector3(0, -100, 0)
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	
	var collision := world_3d.intersect_ray(query)
	return collision.is_empty()

func link_to_minecart(minecart: Node3D) -> void:
	freeze = true
	minecart_link = minecart
	minecart_offset = global_position - minecart.global_position

func activate_xray() -> void:
	xray_on = true
	xray_time_left = xray_visible_time
	if rock_mesh != null:
		rock_mesh.set_surface_override_material(0, xray_mat)
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_method(
			lerp_xray,
			0.0,
			1.0,
			.5
		)
		tween.tween_method(
		lerp_xray,
			1.0,
			0.0,
			.5
		)

func lerp_xray(a: float) -> void:
	var col = xray_mat.stencil_color
	col.a = clamp(a, 0.0, 1.0)
	xray_mat.stencil_color = col
