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
	navRef.target_position = get_tree().get_nodes_in_group("NodosNavegacion").pick_random().position
	print("Rana : initial target position: ", navRef.target_position)
	

func _physics_process(delta: float) -> void:
	await get_tree().process_frame
	if time <= 1 and is_jumping:
		time += delta
		if (position != jump_bezier(time)):
			position = jump_bezier(time)
		else: #ésto no se está ejecutando: TODO terminar de arreglar la colisión para que la rana pueda
			# dar un paso intermedio antes de llegar a su destino, O, en su defecto, llenar de nodos el mapa,
			# tal vez incluso utilizándolos como vectores de propagación de los charcos
			finished_jump.emit()
		
		
	

func jump_bezier(t : float) -> Vector3: # ésta curva describe el movimiento parabólico de la rana al saltar
	var q0 = starting_position.lerp(jump_peak, t)
	var q1 = jump_peak.lerp(desired_position, t)
	var r = q0.lerp(q1, t)  
	return r
	

func _on_area_entered(area) -> void:
	print(area.name)
	if area.is_in_group("NodosNavegacion"): #termina su recorrido
		#await finished_jump
		navRef.target_position = get_tree().get_nodes_in_group("NodosNavegacion").pick_random().position
		print("Rana: cambio de objetivo")
		is_jumping = false
		time = 0
		timer.start()
	#elif area.is_in_group("Ambiente"): #pisa un lugar que no es su destino final
		#print("choca con geometría")
		#restart_jump()
		
	


func restart_jump() -> void:
	print("Rana: reinicia salto")
	is_jumping = true
	starting_position = position
	jump_peak = jump_direction + ((position + navRef.get_next_path_position()) / 2)
	desired_position = navRef.get_next_path_position()
