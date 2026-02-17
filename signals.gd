extends Node

enum ButtonAction {BUY_DRONE, SHOVEL_UPGRADE}
signal purchase_button_pressed(button_action: ButtonAction)

signal ground_changed

signal rock_deposit_finished
