class_name MainMenuCamera extends Camera3D

var is_dropping := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_dropping:
		rotate_y(-delta * .13)

func drop_down_hole() -> void:
	if is_dropping:
		return
	is_dropping = true
	var tween = create_tween()
	tween.tween_property(self, "position", self.position - Vector3(0, 30, 0), 1.0)
