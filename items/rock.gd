class_name Rock extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func dig_touch() -> void:
	#print("dug up rock")
	freeze = false
	#$MeshInstance3D2.visible = true
	#$MeshInstance3D.visible = false
