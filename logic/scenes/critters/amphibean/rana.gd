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
#signal finished_jump

# VFX related variables
@onready var anim_tree_playback : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
var AnimationRegister = {
	"Idle" : "IdleToJumpSpace",
	"Jumping" : "JumpToFallSpace",
	"Falling" : "FallToIdleSpace"
}

var initial_target : Node3D

func with_target(N : Node3D) -> Area3D: # CONSTRUCTOR
	initial_target = N
	return self

func _ready() -> void:
	anim_tree_playback.travel(AnimationRegister.get("Idle"))
	change_target()
	#print("Rana : initial target position: ", navRef.target_position)
	

func _physics_process(delta: float) -> void:
	await get_tree().process_frame #navagent necesita que se calcule primero la geometría y luego si puede utilizarse
	if time <= 1 and is_jumping:
		time += delta
		position = jump_bezier(time)
		

func jump_bezier(t : float) -> Vector3: # ésta curva describe el movimiento parabólico de la rana al saltar
	if t > 0.6:
		anim_tree_playback.travel(AnimationRegister["Falling"])
		if t > 0.9:
			anim_tree_playback.travel(AnimationRegister["Idle"])
			pass
		
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
		GlobalInfo.on_aterrizaje_rana(position)
	
		

func change_target() -> void:
	if navRef.target_position == Vector3.ZERO: # (idealmente) cuando apenas acaba de spawnear
		navRef.target_position = initial_target.position
	else:
		navRef.target_position = get_tree().get_nodes_in_group("NodosNavegacion").pick_random().position
	
	look_at(GeometricToolbox.y_offset_vector_to_0(navRef.target_position)) # BUG cuando se pausa tira infinitos errores
	#print("Rana: cambio de objetivo")

func reset_jump():
	is_jumping = false
	time = 0
	timer.start()

func restart_jump() -> void: # timer llama ésto cuando se agota
	#print("Rana: reinicia salto")
	anim_tree_playback.travel(AnimationRegister["Jumping"])
	is_jumping = true
	starting_position = position
	jump_peak = jump_direction + ((position + navRef.get_next_path_position()) / 2)
	desired_position = GeometricToolbox.y_offset_vector_to_0(navRef.get_next_path_position())
	#print("Rana va a: ",desired_position)
	
