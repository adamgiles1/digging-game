extends Node3D

@onready
var fell_label: Label = $Control/Label4
@onready
var stay_forever_label: Label = $Control/Label5
@onready
var congrat_label: Label = $Label
@onready
var beat_label: Label = $Label2
@onready
var ending_time_label: Label = $Label3
@onready
var cheat_label: Label = $Label4

var visible_color := Color(1, 1, 1, 1)
var invisible_color := Color(1, 1, 1, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()
	var time_str = ""
	if Globals.game_win_time > 60:
		time_str += "%s minutes, " % floori(Globals.game_win_time / 60)
	time_str += "%s seconds, " % (floori(Globals.game_win_time) % 60)
	time_str += "%s milliseconds" % int(fmod(Globals.game_win_time, int(Globals.game_win_time)) * 1000)
	ending_time_label.text = time_str
	
	fell_label.modulate = invisible_color
	stay_forever_label.modulate = invisible_color
	congrat_label.modulate = invisible_color
	beat_label.modulate = invisible_color
	cheat_label.modulate = invisible_color
	ending_time_label.visible_characters = 0
	$QuitButton.visible = false
	$QuitButton.pressed.connect(func(): get_tree().quit())
	
	var tween = create_tween()
	tween.tween_property($ColorRect2, "modulate", invisible_color, 5.0)
	tween.tween_interval(2.0)
	tween.tween_property(fell_label, "modulate", visible_color, 2.0)
	tween.tween_interval(1.0)
	tween.tween_property(stay_forever_label, "modulate", visible_color, 2.0)
	tween.tween_interval(3.0)
	tween.tween_property($Control, "modulate", invisible_color, 5.0)
	tween.tween_interval(3.0)
	tween.tween_property(congrat_label, "modulate", visible_color, 3.0)
	tween.tween_interval(1.0)
	tween.tween_property(beat_label, "modulate", visible_color, 2.0)
	tween.tween_interval(1.0)
	tween.tween_property(ending_time_label, "visible_characters", len(ending_time_label.text), 5.0)
	tween.tween_method(func(val): $QuitButton.visible = true, 0, 1, .1)
	
	if Globals.is_cheating:
		tween.tween_property(cheat_label, "modulate", visible_color, 3.0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
