class_name Tutorial extends Node3D

@onready var tutorial_msg: RichTextLabel = $Control/RichTextLabel
@onready var tutorial_cont: Control = $Control

var step: int = 0
var step_progress: float = 0.0

var step_messages: Array[String] = [
	"Use mouse to look around",
	"Use WASD to walk",
	"Left click on dirt to dig",
	"Dig until you find a rock and pick it up",
	"You can deposit rocks in the minecart",
	"Save up to buy a better shovel",
]
var step_types: Array[Signals.TutorialProgress] = [
	Signals.TutorialProgress.LOOK_AROUND, 
	Signals.TutorialProgress.WALK,
	Signals.TutorialProgress.DIG, 
	Signals.TutorialProgress.FIND_ROCK, 
	Signals.TutorialProgress.MINECART, 
	Signals.TutorialProgress.SHOVEL_UPGRADE
]
var step_thresholds: Array[float] = [
	1,
	1,
	1,
	1,
	1,
	1,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.tutorial_progress.connect(handle_tutorial_progress)
	step = -1
	advance_step()

func handle_tutorial_progress(progress: Signals.TutorialProgress, amt: float) -> void:
	if step >= len(step_messages):
		return
	if step_types[step] == progress:
		step_progress += amt
		if step_progress >= step_thresholds[step]:
			advance_step()

func advance_step() -> void:
	step += 1
	if step >= len(step_messages):
		tutorial_msg.text = "Continue digging!"
		return
	tutorial_msg.text = step_messages[step]
	
	tutorial_msg.scale = Vector2.ONE * 2
	tutorial_cont.position = Vector2(get_viewport().get_visible_rect().size.x / 2.0, get_viewport().get_visible_rect().size.y * .4)
	print(tutorial_cont.position)
	await get_tree().create_timer(1.0).timeout
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(tutorial_cont, "position", Vector2(get_viewport().get_visible_rect().size.x, 0.0), 1.0)
	tween.tween_property(tutorial_msg, "scale", Vector2.ONE, 1.0)
