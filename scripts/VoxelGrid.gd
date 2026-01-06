class_name VoxelGrid extends RefCounted

var array: PackedFloat32Array
var size: int

func _init(_size: int, default_value: float = 1.0) -> void:
	size = _size
	array.resize(size * size * size)
	array.fill(default_value)

func read(x: int, y: int, z: int) -> float:
	return array[x + size * (y + size * z)]

func write(x: int, y: int, z: int, value: float) -> void:
	array[x + size * (y + size * z)] = value
