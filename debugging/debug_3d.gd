extends Node

var space_3d: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	space_3d = Node3D.new()
	add_child(space_3d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ping(pos: Vector3) -> void:
	print("pinging")
	var ping_scn := preload("res://debugging/Ping3D.tscn").instantiate()
	space_3d.add_child(ping_scn)
	ping_scn.global_position = pos
