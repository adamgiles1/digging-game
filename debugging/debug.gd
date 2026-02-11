extends Control

var label: Label

var values: Dictionary[String, String] = {}

var error_count_dict: Dictionary[String, int] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var debug_info = preload("res://debugging/DebugInfo.tscn").instantiate()
	add_child(debug_info)
	label = debug_info.get_node("Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var text = ""
	for key: String in values.keys():
		text += str(key, ": ", values[key], "\n")
	
	label.text = text

func log(name: String, value: Variant) -> void:
	values[name] = str(value)

func log_error_count(name: String, amt: int) -> void:
	var old: int = error_count_dict.get_or_add(name, 0)
	error_count_dict[name] = old + amt
	Debug.log(name, old + amt)
