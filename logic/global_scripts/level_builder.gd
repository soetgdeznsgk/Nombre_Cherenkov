extends Node
class_name Level_Builder

@onready var refUI : UI = get_tree().get_first_node_in_group("UI")
var paused : bool = true
var boot := true
static var controller_connected : bool 				# falso si teclado, verdadero si hay control
static var controller_sensitivity : float = 5
var pauseBuffer : Timer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	InputMap.action_set_deadzone("LookD", 0.1)
	InputMap.action_set_deadzone("LookL", 0.1)
	InputMap.action_set_deadzone("LookR", 0.1)
	InputMap.action_set_deadzone("LookU", 0.1)
	Engine.time_scale = 0
	Engine.max_fps = 60
	Input.joy_connection_changed.connect(_on_gamepad_connection_status_changed)


func _input(event : InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventKey:
		if Input.is_action_just_pressed("PauseGame"):
			change_paused_state()
			
	

func _on_gamepad_connection_status_changed(device_id, connected : bool) -> void:
	controller_connected = connected

func change_paused_state() -> void:
	refUI.alternate_esc_enter()
	paused = not paused
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Engine.time_scale = 0
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Engine.time_scale = 1
