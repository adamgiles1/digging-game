class_name Inventory extends RefCounted

var capacity: int = 5
var stored_rocks: Array[String] = []
var total_value: int = 0

func add_rock(rock: Rock) -> bool:
	if len(stored_rocks) >= capacity:
		return false
	
	stored_rocks.append(rock.rock_name)
	total_value += rock.value
	Debug.log("RocksStored", len(stored_rocks))
	Debug.log("RockValue", total_value)
	return true
