extends Node

@export var Camera : Camera3D
@export var gameOverShakeStrenght : float = 0.5
@export var buttonPressShakeStrenght : float = 0.25
@export var shakeFade : float
const SHAKE_FADE_BUTTON_PRESS = 1.5
const SHAKE_FADE_GAME_OVER = 0.1

var shake_strength : float = 0.0

func _ready() -> void:
	Camera = get_parent()

func start() -> void:
	start_screen_shake_button_press()

func start_screen_shake_game_over():
	shake_strength = gameOverShakeStrenght
	shakeFade = SHAKE_FADE_GAME_OVER
	shake_coroutine()

func start_screen_shake_button_press():
	shake_strength = buttonPressShakeStrenght
	shakeFade = SHAKE_FADE_BUTTON_PRESS
	shake_coroutine()
	
func shake_coroutine():
	Camera.h_offset = randf_range(-shake_strength,shake_strength)
	Camera.v_offset = randf_range(-shake_strength,shake_strength)
	
	shake_strength = lerpf(shake_strength, 0, shakeFade * get_process_delta_time())
	await get_tree().process_frame
	shake_coroutine()

	
