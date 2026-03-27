extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/Button.pressed.connect(start_game)

func start_game() -> void:
	print("starting game")
	
	$Control/Button.visible = false
	$Camera3D.drop_down_hole()
	
	await get_tree().create_timer(1.0).timeout
	var tween = create_tween()
	tween.tween_property($MeshInstance2D, "modulate", Color(0, 0, 0, 1.0), .4)
	
	await get_tree().create_timer(.5).timeout
	get_tree().change_scene_to_file("res://Game.tscn")
