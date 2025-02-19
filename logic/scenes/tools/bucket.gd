extends VehicleBody3D
class_name Balde

@onready var mesh_reference : MeshInstance3D = $baldeClean/Esqueleto_002/Skeleton3D/Balde
var remote_transform_ref : RemoteTransform3D
var anim_time : float
var player_on_range : bool = false

@export var in_hud : bool = false
var position_delta : Vector3 = Vector3.ZERO
signal bucket_equipped
signal bucket_unequipped
var mop_reference : Mop
var mop_stored : bool = false
var bucket_ko : bool = false
var placeable : bool = true
const tumbled_over_trigger : float = 0.2
const VERTICAL_BUCKET_POSITION_LIMIT = 0.25

@onready var lever_interaction_node : Area3D = $"Area3D Palanca"
# nuevas variables
var saturation := 0.0

func _ready() -> void:
	bucket_equipped.connect(GlobalInfo.bucket_just_equipped)
	bucket_unequipped.connect(GlobalInfo.bucket_just_unequipped)
	remote_transform_ref = GlobalInfo.refPlayer.camara_ref.bucket_remote_transform
	#steering = 0 #trailer

func _physics_process(_delta: float) -> void:
	#if Input.is_key_label_pressed(KEY_0): engine_force = 600 #trailer
	if not in_hud:
		check_bucket_orientation() # A DIFERIR, no vale la pena hacerlo todos los frames, aunque es solo checar un bit, no debe ser fuente de lag
			
		if engine_force > 1: # solución barata, funciona para frenar entonces lo considero terminado
			engine_force /= 1.05
					
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and $grab_buffer.is_stopped() and player_on_range: 
			alternate_on_player_hud()
				
	else: # TODO refactorizar este codigo horrible
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and $grab_buffer.is_stopped() and confirm_placeability():
			alternate_on_player_hud()
		
		position_delta = GeometricToolbox.y_offset_vector_to_0(remote_transform_ref.global_position - global_position)
		global_position.x = remote_transform_ref.global_position.x
		global_position.z = remote_transform_ref.global_position.z
		
func _input(event: InputEvent) -> void:
	if in_hud:
		if event is InputEventMouseMotion or event is InputEventAction:
			# TODO arreglar bug donde el juego se caga encima si se llama a look_at 
			look_at(GeometricToolbox.y_offset_vector_to_0(GlobalInfo.playerPosition)) 
			adjust_forces(event.relative.x)
		elif event is InputEventKey:
			adjust_forces(1)
		
		
		
func get_rotation_needed_towards_player() -> float: # sin uso con la nueva implementación
	var angle = transform.basis.x.signed_angle_to(GlobalInfo.playerPosition - position, Vector3.UP) # Frente del carrito
	return angle
	
func lerp_towards_player(time) -> void: # TODO arreglar para que no se vea epileptico // sin uso
	rotate(Vector3.UP, lerpf(0, steering, time))

#region interacciones con jugador y mundo

#func calculate_position_delta() -> void:
	#return GeometricToolbox.y_offset_vector_to_0(remote_transform_ref.global_position - global_position)

func alternate_on_player_hud() -> void:
	$grab_buffer.start()
	if not in_hud:
		freeze = true
		collision_layer = 0
		bucket_equipped.emit()
		in_hud = true
	
		
	elif global_position.y > -0.5: # para que no se clipee en el piso TODO limitar que no se pueda poner afuera de las paredes también
		freeze = false  # ACÁ ESTÁ EL BUG CUANDO SE COLOCA CERCA EL BALDE, cómo putas se puede arreglar?
		collision_layer = 1
		bucket_unequipped.emit()
		in_hud = false
	

func adjust_forces(horizontal_cam_delta : float) -> void: # mi obra maestra
		var inercia = position_delta.rotated(Vector3.UP, -rotation.y) * Engine.max_fps * 30 / abs(horizontal_cam_delta)
		var centrifuga = Vector3.BACK * abs(horizontal_cam_delta) # TODO esto será afectado por si el balde tiene agua o no
		#$inercia.target_position = inercia
		#$steering.target_position =  centrifuga + inercia 
		#$z.target_position = Vector3.BACK
		#TODO arreglar bug donde no se actualiza automáticamente sino tras 1 segundo
		steering = Vector3.BACK.signed_angle_to(inercia + centrifuga, Vector3.UP)
		if abs(horizontal_cam_delta) + (inercia.length()) > 15:
			engine_force = ( abs(horizontal_cam_delta * 7) + (inercia.length())  )
			#print(engine_force, " = ", abs(horizontal_cam_delta * 5), " + ", inercia.length())

func enter_player_focus() -> void:
	#print("entra a la vision ", Time.get_time_string_from_system())
	if not mop_stored:
		mesh_reference.activate_outline()
		player_on_range = true

func exit_player_focus() -> void:
	mesh_reference.deactivate_outline()
	player_on_range = false

func player_interaction() -> void: #ésta función estará en TODOS los objetos con un efecto especial de interacción
	if GlobalInfo.timerInteractionBuffer.is_stopped() and GlobalInfo.refCamara.mop_reference != null:
		if bucket_ko:
			reset_bucket_orientation()
			
		else:
			if mop_stored:
				# acá ira exprimir() cuando se meta la palanca
				pass
			else:
				place_mop_on_bucket()
				#mop_reference.exprimir() # TEMPORAL
				
#region palanca

func palanca_activada() -> void:
	mop_reference.exprimir()
#endregion

#region in/out trapero
func place_mop_on_bucket() -> void:
	mop_stored = true
	mop_reference = GlobalInfo.refTrapero
	mop_reference.reparent_action(self)
	mop_reference.transform = Transform3D.IDENTITY
	mop_reference.position = $PosicionTrapero.position
	mop_reference.rotate(Vector3.UP, PI/2)
	exit_player_focus()
	lever_interaction_node.activate()

func retrieve_mop() -> void:
	if mop_stored:
		mop_stored = false
		mop_reference.exit_player_focus()
		lever_interaction_node.deactivate()
#endregion

#region estabilidad

func check_bucket_orientation() -> void:
	if transform.basis.y.dot(Vector3.UP) < tumbled_over_trigger:
		if not bucket_ko:
			print("caido")
			#spawnear un charco justo donde cae 
			GlobalInfo.on_aterrizaje_rana(global_position + basis.y)
			bucket_ko = true
			engine_force = 0
			
	else:
		if bucket_ko:
			bucket_ko = false
		
func reset_bucket_orientation() -> void:
	bucket_ko = false
	transform.basis = Basis() 
	
func fall_from_collision_in(collider_pos: Vector3) -> void:
	if not bucket_ko and not in_hud:
		var eje = (collider_pos - global_position).cross(Vector3.UP).normalized()
		rotate(eje, 1) # volver una corutina
		bucket_ko = true
		# spawnear un charco
	
func confirm_placeability() -> bool: # no es infalible, pero requiere dedicación tirar el balde al agua
	var b : bool = true
	for child in $"ground scanner".get_children():
		b = b and child.is_colliding()
	return b

#endregion

#endregion
