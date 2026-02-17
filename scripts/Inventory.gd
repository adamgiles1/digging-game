class_name Inventory extends RefCounted

var capacity: int = 5
var stored_rocks: Array[Rock] = []
var total_value: int = 0

func add_rock(rock: Rock) -> bool:
	if len(stored_rocks) >= capacity:
		return false
	
	stored_rocks.append(rock)
	total_value += rock.value
	update_count()
	return true

func clear_rocks() -> void:
	stored_rocks.clear()
	update_count()

func update_count() -> void:
	Debug.log("RocksStored", len(stored_rocks))
	Debug.log("RockValue", total_value)
