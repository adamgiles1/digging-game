class_name Inventory extends RefCounted

var stored_rocks: Array[Rock] = []
var total_value: int = 0

func add_rock(rock: Rock) -> bool:
	stored_rocks.append(rock)
	total_value += rock.value
	update_count()
	return true

func clear_rocks() -> void:
	stored_rocks.clear()
	update_count()

func pop_rocks() -> Array[Rock]:
	if len(stored_rocks) == 0:
		return []
	var return_value: Array[Rock] = []
	for i in range(min(5, len(stored_rocks))):
		return_value.append(stored_rocks.pop_front())
	update_count()
	return return_value

func update_count() -> void:
	Debug.log("RocksStored", len(stored_rocks))
	Debug.log("RockValue", total_value)
