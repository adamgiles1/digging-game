class_name Minecart extends Node3D

@onready
var minecart: Node3D = $minecart

@onready
var axels: Array[Node3D] = [$minecart/Axel, $minecart/Axel_001]

@onready
var deposit_point: Marker3D = $DepositPoint

@onready
var minecart_lid: StaticBody3D = $minecart/MinecartLid

var last_x_pos: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# disable by setting to a high collision layer (I hope I don't accidently use this layer later)
	minecart_lid.collision_layer = 0b100000000000000000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if minecart.global_position.x != last_x_pos:
		print("yes")
		rotate_wheels(minecart.global_position.x - last_x_pos)
		last_x_pos = minecart.global_position.x

func deposit(inventory: Inventory) -> void:
	print("depositing")
	# spawn each rock on a delay over minecart
	for rock: Rock in inventory.stored_rocks:
		rock.deposit(deposit_point.global_position)
		await get_tree().create_timer(1.0).timeout
	
	minecart_lid.collision_layer = 0b1
	inventory.clear_rocks()
	$AnimationPlayer.play("deposit", -1, .5)

func _handle_deposit_finished() -> void:
	print("rocks finished depositing")
	Signals.rock_deposit_finished.emit()

func rotate_wheels(distance: float) -> void:
	for axel: Node3D in axels:
		axel.rotate_z(distance)
