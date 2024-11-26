extends Node

@onready var refUI : UI = get_tree().get_first_node_in_group("UI")
var paused : bool = true
var boot := true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Engine.time_scale = 0


func _input(event):
	if event is InputEventMouseButton and not boot:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Engine.time_scale = 1
		change_paused_state()
		paused = false
		boot = true
		
func _process(_delta: float) -> void:
	if Input.is_key_label_pressed(KEY_ESCAPE) and not paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Engine.time_scale = 0
		change_paused_state()
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Engine.time_scale = 1
		change_paused_state()
		
func change_paused_state() -> void:
	refUI.alternate_esc_enter()
	paused = not paused
