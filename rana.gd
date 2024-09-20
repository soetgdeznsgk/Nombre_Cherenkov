extends Area3D

@onready var navRef : NavigationAgent3D = $NavigationAgent3D
@onready var timer : Timer = $Timer

# Jump related variables and signals
static var velocity := 0.1
static var jump_direction := Vector3.UP * 10
var starting_position : Vector3
var jump_peak : Vector3
var desired_position : Vector3
var is_jumping := false
var time : float
signal finished_jump


func _ready() -> void:
	change_target()
	print("Rana : initial target position: ", navRef.target_position)
	

func _physics_process(delta: float) -> void:
	await get_tree().process_frame #navagent necesita que se calcule primero la geometría y luego si puede utilizarse
	if time <= 1 and is_jumping:
		time += delta
		position = jump_bezier(time)
		
		
	

func jump_bezier(t : float) -> Vector3: # ésta curva describe el movimiento parabólico de la rana al saltar
	var q0 = starting_position.lerp(jump_peak, t)
	var q1 = jump_peak.lerp(desired_position, t)
	var r = q0.lerp(q1, t)  
	return r
	

func _on_area_entered(area) -> void:
	if area.is_in_group("NodosNavegacion"): #termina su recorrido
		change_target()
		reset_jump()
	
func _on_body_entered(body: Node3D) -> void: # xq el escenario es un staticbody
	if body.is_in_group("Ambiente"):
		reset_jump()

func change_target() -> void:
	navRef.target_position = get_tree().get_nodes_in_group("NodosNavegacion").pick_random().position
	print("Rana: cambio de objetivo")

func reset_jump():
	is_jumping = false
	time = 0
	timer.start()

func restart_jump() -> void: # timer llama ésto cuando se agota
	print("Rana: reinicia salto")
	is_jumping = true
	starting_position = position
	jump_peak = jump_direction + ((position + navRef.get_next_path_position()) / 2)
	desired_position = GeometricToolbox.y_offset_vector_to_0(navRef.get_next_path_position())
	print(desired_position)
	
