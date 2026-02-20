class_name Minecart extends Node3D

@onready
var minecart: Node3D = $minecart
@onready
var axels: Array[Node3D] = [$minecart/Axel, $minecart/Axel_001]
@onready
var deposit_point: Marker3D = $DepositPoint
@onready
var anim_player: AnimationPlayer = $AnimationPlayer

var last_x_pos: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if minecart.global_position.x != last_x_pos:
		print("yes")
		rotate_wheels(minecart.global_position.x - last_x_pos)
		last_x_pos = minecart.global_position.x

func deposit(inventory: Inventory) -> void:
	print("depositing")
	if !is_minecart_interactable():
		return
	# spawn each rock on a delay over minecart
	for rock: Rock in inventory.stored_rocks:
		if rock != null:
			rock.deposit(deposit_point.global_position)
			await get_tree().create_timer(1.0).timeout
	
	for rock: Rock in inventory.stored_rocks:
		if rock != null:
			rock.link_to_minecart(minecart)
	inventory.clear_rocks()
	anim_player.play("deposit", -1, 1.0)
	Signals.tutorial_progress.emit(Signals.TutorialProgress.MINECART, 1.0)

func _handle_deposit_finished() -> void:
	print("rocks finished depositing")
	Signals.rock_deposit_finished.emit()

func rotate_wheels(distance: float) -> void:
	for axel: Node3D in axels:
		axel.rotate_z(distance)

func is_minecart_interactable() -> bool:
	return !anim_player.is_playing()
