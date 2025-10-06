extends Node
class_name Level_Builder

var paused : bool = false
var boot := true
static var controller_connected : bool 				# falso si teclado, verdadero si hay control
static var controller_sensitivity : float = 5
var pauseBuffer : Timer

signal level_built

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	InputMap.action_set_deadzone("LookD", 0.1)
	InputMap.action_set_deadzone("LookL", 0.1)
	InputMap.action_set_deadzone("LookR", 0.1)
	InputMap.action_set_deadzone("LookU", 0.1)
	Engine.max_fps = 60
	Input.joy_connection_changed.connect(_on_gamepad_connection_status_changed)
	#print(Input.get_connected_joypads())
	#setup_user_tooltips()
	


func _input(event : InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventKey:
		if Input.is_action_just_pressed("PauseGame"):
			change_paused_state()

func _on_gamepad_connection_status_changed(device_id, connected : bool) -> void:
	setup_user_tooltips()
		
func setup_user_tooltips() -> void:
	controller_connected = not Input.get_connected_joypads().is_empty()
	await get_tree().create_timer(1).timeout
	#print(get_tree().get_nodes_in_group("HasUserTooltip"))
	for node in get_tree().get_nodes_in_group("HasUserTooltip"):
		node.define_appropiate_gamepad_tooltip(controller_connected)
	 

func change_paused_state() -> void:
	GlobalInfo.refUI.alternate_esc_enter()
	paused = not paused
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Engine.time_scale = 0
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Engine.time_scale = 1
