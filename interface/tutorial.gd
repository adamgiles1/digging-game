class_name Tutorial extends Node3D

@onready var tutorial_msg: RichTextLabel = $RichTextLabel

var step: int = 0
var step_progress: float = 0.0

var step_messages: Array[String] = [
	"Use mouse to look around",
	"Use WASD to walk",
	"Left click on dirt to dig",
	"Dig until you find a rock and pick it up",
	"You can deposit rocks in the minecart",
	"Save up to buy a better shovel",
	"Buy X-ray and activate by pressing \"e\""
]
var step_types: Array[Signals.TutorialProgress] = [
	Signals.TutorialProgress.LOOK_AROUND, 
	Signals.TutorialProgress.WALK,
	Signals.TutorialProgress.DIG, 
	Signals.TutorialProgress.FIND_ROCK, 
	Signals.TutorialProgress.MINECART, 
	Signals.TutorialProgress.SHOVEL_UPGRADE,
	Signals.TutorialProgress.XRAY
]
var step_thresholds: Array[float] = [
	1,
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
	step_progress = 0.0
	if step >= len(step_messages):
		tutorial_msg.text = "Continue digging!"
		return
	tutorial_msg.text = step_messages[step]
	
	var label_size = tutorial_msg.size
	print("label size ", label_size)
	var viewport_size = get_viewport().get_visible_rect().size
	
	tutorial_msg.scale = Vector2.ONE * 2.0
	tutorial_msg.position = Vector2(
		viewport_size.x / 2.0 - label_size.x / 2.0, 
		(viewport_size.y * .3) - label_size.y / 2.0
	)
	print(tutorial_msg.position)
	await get_tree().create_timer(1.0).timeout
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(tutorial_msg, "position", Vector2(get_viewport().get_visible_rect().size.x - label_size.x / 2.0 - 200, 0.0), 1.0)
	tween.tween_property(tutorial_msg, "scale", Vector2.ONE, 1.0)
