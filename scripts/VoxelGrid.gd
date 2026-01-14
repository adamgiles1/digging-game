class_name VoxelGrid extends RefCounted

var array: PackedFloat32Array
var size: int

func _init(_size: int, default_value: float = 1.0) -> void:
	size = _size
	array.resize(size * size * size)
	array.fill(default_value)

func read(x: int, y: int, z: int) -> float:
	var idx = x + size * (y + size * z)
	if idx > len(array) - 1:
		return 0.0
	return array[idx]

func write(x: int, y: int, z: int, value: float) -> void:
	var idx = x + size * (y + size * z)
	if idx <= len(array):
		array[idx] = value

func minus(x: int, y: int, z: int, value: float) -> void:
	var val := read(x, y, z)
	write(x, y, z, val - value)

func add(x: int, y: int, z: int, value: float) -> void:
	var val := read(x, y, z)
	write(x, y, z, val + value)
