extends Camera3D
class_name InteraccionesJugador

var v = Vector3()
var currSelection : Node

@export var mop_reference : Mop
@onready var bucket_reference : Balde = get_tree().get_first_node_in_group("Baldes")
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
var temp_vx 

@onready var interaction_raycast : RayCast3D = $RayCast3D
@onready var bucket_remote_transform : RemoteTransform3D = $RemoteTransform3D_bucket
@onready var mop_remote_transform : RemoteTransform3D = $RemoteTransform3D_mop
var bucket_RT_dereferenced : bool = false
var last_collision : Node

func _ready():
	call_deferred("updateDetectionExceptions")
	#ignoringMop = true # CAMBIAR CUANDO YA ESTÉ LA RUTINA DE INICIO
	#GlobalInfo.jugador_atrapado.connect(lock_camera)
	
	#GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
 
func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		v.y -= (event.relative.x * 0.2)
		v.x -= (event.relative.y * 0.2)
		if mop_reference != null:
			mop_reference.rotate_to_camera(event.relative)
		#bucket_reference.rotate_to_camera(event.relative.x) # no se necesita todos los frames
		v.x = clamp(v.x,-80,90)
		
func apply_controller_rotation() -> void:
	if not LevelBuilder.controller_connected: return
	var axis_vector : Vector2 = Vector2.ZERO
	axis_vector.x = Input.get_axis("LookL", "LookR")
	axis_vector.y = Input.get_axis("LookU", "LookD")
	get_parent().rotate_y(deg_to_rad(-axis_vector.x) * LevelBuilder.controller_sensitivity)
	rotate_x(deg_to_rad(-axis_vector.y) * LevelBuilder.controller_sensitivity)
	rotation.x = clamp(rotation.x, deg_to_rad(-75), deg_to_rad(75))

func _physics_process(delta):
	if UI.paused:
		return
	if locked:
		time_locked += delta
		get_parent().look_at((global_position - pre_grab_camera_direction).lerp(focus_point, time_locked))
		look_at((global_position - pre_grab_camera_direction).lerp(focus_point, time_locked))
		if mop_reference != null: 
			mop_reference.rotate_to_camera(Vector2.ZERO)
	
	elif LevelBuilder.controller_connected:
		apply_controller_rotation()
	else:
		rotation_degrees.x = v.x
		rotation_degrees.y = v.y
		
	#region Codigo para los outlines para los interactuables (radioactivo)
	if interaction_raycast.is_colliding():	
		
		if last_collision != interaction_raycast.get_collider():
			if last_collision != null and last_collision.has_method("exit_player_focus"):
				last_collision.exit_player_focus()
			last_collision = interaction_raycast.get_collider()
		
		if last_collision != null and last_collision.has_method("enter_player_focus"):
			last_collision.enter_player_focus()
			
	elif last_collision != null and last_collision.has_method("exit_player_focus"):
		last_collision.exit_player_focus()
		last_collision = null
	#endregion
	
	#region Código de interacción con objetos
	if Input.is_action_pressed("PrimaryInteraction") and interaction_raycast.is_colliding(): 
		if last_collision != null: #and last_collision.name != "ColisiónJugador": TODO hacer algo pa que no se pueda quedar unx atascado por un pulpo dentro de la piscina 
			if mop_reference != null and not last_collision.is_in_group("Trapero") and GlobalInfo.timerInteractionBuffer.is_stopped():
				mop_reference.trapeo_lerp_to(interaction_raycast.get_collision_point(), 0)
				#print(last_collision)
	
			if  last_collision.has_method("player_interaction"):
				last_collision.player_interaction()
				GlobalInfo.start_interaction_buffer()
			
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mop_reference != null:
		mop_reference.trapeo_lerp_back(0)
	#endregion


func updateDetectionExceptions() -> void:
	#	wawait get_tree().process_frame
	interaction_raycast.add_exception($"..")
	for node in get_tree().get_nodes_in_group("NodosNavegacion"): # TODO averiguar qué otros nodos necesitan ignorarse
		interaction_raycast.add_exception(node)
	#interaction_raycast.add_exception(get_tree().get_first_node_in_group("Trapero")) # con la secuencia de inicio, esto se trata con alterMopException

func alterMopException(n : Mop) -> void:
	if ignoringMop:
		interaction_raycast.remove_exception(n)
		ignoringMop = false
	else:
		interaction_raycast.add_exception(n)
		ignoringMop = true

func lock_camera(p : Vector3) -> void:
	pre_grab_camera_direction = global_basis.z
	focus_point = p
	#look_at(focus_point)
	locked = true
	v = Vector3.ZERO
	if LevelBuilder.controller_connected:
		Input.start_joy_vibration(0, 0.5, 0.3)
	
func free_camera() -> void:
	get_parent().transform.basis = Basis()
	locked = false
	if LevelBuilder.controller_connected:
		Input.stop_joy_vibration(0)
	
func get_interaction_raycast_ref() -> RayCast3D:
	return interaction_raycast
