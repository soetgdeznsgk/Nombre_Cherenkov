extends Camera3D
class_name InteraccionesJugador

var v = Vector3()
var currSelection : Node

@export var mop_reference : Mop
var ignoringMop := false 

var locked : bool = false
var time_locked : float = 0: #para el lerp de la camara cunado se atrapa
	set(v):
		if v >= 1:
			time_locked = 1
		else:
			time_locked = v

var pre_grab_camera_direction : Vector3
var focus_point : Vector3

var last_collision : Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("updateDetectionExceptions")
	ignoringMop = true # CAMBIAR CUANDO YA ESTÉ LA RUTINA DE INICIO
	#GlobalInfo.jugador_atrapado.connect(lock_camera)
	
	#GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
 
func _input(event):
	if event is InputEventMouseMotion:
		mop_reference.rotate_to_camera()
		v.y -= (event.relative.x * 0.2)
		v.x -= (event.relative.y * 0.2)
		v.x = clamp(v.x,-80,90)
		

func _physics_process(delta):
	if not locked:
		rotation_degrees.x = v.x
		rotation_degrees.y = v.y
	else:
		time_locked += delta
		look_at((global_position - pre_grab_camera_direction).lerp(focus_point, time_locked))
		mop_reference.rotate_to_camera()
	
	#region Codigo para los outlines para los interactuables
	if $RayCast3D.is_colliding():	
		last_collision = $RayCast3D.get_collider()
		if last_collision != null and last_collision.has_method("enter_player_focus"):
			last_collision.enter_player_focus()
	elif last_collision != null and last_collision.has_method("exit_player_focus"):
		last_collision.exit_player_focus()
		last_collision = null
	#endregion
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $RayCast3D.is_colliding(): 
		mop_reference.trapeo_lerp_to($RayCast3D.get_collision_point(), 0)
		#print($RayCast3D.get_collider())
		if last_collision != null and last_collision.has_method("player_interaction"):
			last_collision.player_interaction()
		
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mop_reference.trapeo_lerp_back(0)


func updateDetectionExceptions() -> void:
	#	wawait get_tree().process_frame
	$RayCast3D.add_exception($"..")
	for node in get_tree().get_nodes_in_group("NodosNavegacion"): # TODO averiguar qué otros nodos necesitan ignorarse
		$RayCast3D.add_exception(node)
	$RayCast3D.add_exception(get_tree().get_first_node_in_group("Trapero")) # con la secuencia de inicio, esto se trata con alterMopException

func alterMopException(n : Mop) -> void:
	if ignoringMop:
		$RayCast3D.remove_exception(n)
		ignoringMop = false
	else:
		$RayCast3D.add_exception(n)
		ignoringMop = true

func lock_camera(p : Vector3) -> void:
	pre_grab_camera_direction = global_basis.z
	focus_point = p
	#look_at(focus_point)
	locked = true
	v = Vector3.ZERO
	
func free_camera() -> void:
	locked = false
