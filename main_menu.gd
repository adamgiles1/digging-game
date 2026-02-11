extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/Button.pressed.connect(start_game)

func start_game() -> void:
	print("starting game")
	get_tree().change_scene_to_file("res://Game.tscn")
