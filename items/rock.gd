class_name Rock extends RigidBody3D

var is_dug_close := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)

func _physics_process(delta: float) -> void:
	if self.global_position.y < 0:
		Debug.log_error_count("rockOutOfBounds", 1)
		queue_free()

func check_if_dug_out() -> void:
	print("checking if rock is dug out")
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
	freeze = false
	if Signals.ground_changed.is_connected(check_if_dug_out):
		Signals.ground_changed.disconnect(check_if_dug_out)

func collect() -> void:
	print("collecting rock")
	queue_free()
