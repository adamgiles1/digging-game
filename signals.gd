extends Node

enum ButtonAction {BUY_DRONE, BUY_SHOVEL_UPGRADE, TOGGLE_TRACTOR_BEAM}
signal purchase_button_pressed(button_action: ButtonAction)

signal ground_changed

signal rock_deposit_finished
