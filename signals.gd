extends Node

enum ButtonAction {BUY_DRONE, BUY_SHOVEL_UPGRADE, TOGGLE_TRACTOR_BEAM, XRAY_UPGRADE, MULTIPLIER, MINECART, STALACTITE}
signal purchase_button_pressed(button_action: ButtonAction)

signal ground_changed

signal rock_deposit_finished

signal minecart_levelup(val: float)
signal shovel_levelup(val: float)
signal xray_levelup(val: float)

enum TutorialProgress {LOOK_AROUND, WALK, DIG, FIND_ROCK, MINECART, SHOVEL_UPGRADE, XRAY}
signal tutorial_progress(step: TutorialProgress)
