class_name BuyButton extends Node3D

@export
var trigger_event: Signals.ButtonAction

var time_till_clickable := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_clickable -= delta

func click() -> void:
	if time_till_clickable > 0.0:
		print("button already clicked")
		return
	print("button clicked, purchasing %s" % trigger_event)
	Signals.purchase_button_pressed.emit(trigger_event)
	$AnimationPlayer.play("press")
	time_till_clickable = 1.0
