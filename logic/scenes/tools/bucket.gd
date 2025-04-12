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
const tumbled_over_trigger : float = 0.4
const VERTICAL_BUCKET_POSITION_LIMIT = 0.25
#@export var DEBUG_CALL : bool = false
	

@onready var lever_interaction_node : Area3D = $"Area3D Palanca"
# nuevas variables
var saturation := 0.0

func _ready() -> void:
	bucket_equipped.connect(GlobalInfo.bucket_just_equipped)
	bucket_unequipped.connect(GlobalInfo.bucket_just_unequipped)
	remote_transform_ref = GlobalInfo.refPlayer.camara_ref.bucket_remote_transform
	
	await get_tree().process_frame
	if LevelBuilder.controller_connected:
		$ControlTipRT.texture = load("res://modelos/textures/sprites/xbox_rt.png")
		$ControlTipLT.texture = load("res://modelos/textures/sprites/xbox_lt.png")
	#steering = 0 #trailer

func _physics_process(_delta: float) -> void:
	#if Input.is_key_label_pressed(KEY_0): engine_force = 600 #trailer
	if not in_hud:
		check_bucket_orientation() # A DIFERIR, no vale la pena hacerlo todos los frames, aunque es solo checar un bit, no debe ser fuente de lag
			
		if engine_force > 1: # solución barata, funciona para frenar entonces lo considero terminado
			engine_force /= 1.05
		else:
			wheels_moving_sound()
					
		if Input.is_action_pressed("SecondaryInteraction") and $grab_buffer.is_stopped() and player_on_range: 
			alternate_on_player_hud()
				
	else: # TODO refactorizar este codigo horrible
		if Input.is_action_pressed("SecondaryInteraction") and $grab_buffer.is_stopped() and confirm_placeability():
			alternate_on_player_hud()
		
		position_delta = GeometricToolbox.y_offset_vector_to_0(remote_transform_ref.global_position - global_position)
		global_position.x = remote_transform_ref.global_position.x
		global_position.z = remote_transform_ref.global_position.z
		wheels_moving_sound()
		
func _input(event: InputEvent) -> void:
	if in_hud:
		look_at(GeometricToolbox.y_offset_vector_to_0(GlobalInfo.playerPosition)) 
		if event is InputEventMouseMotion or event is InputEventAction:
			adjust_forces(event.relative.x)
		else:
			adjust_forces(1)
		
		
func get_rotation_needed_towards_player() -> float: # sin uso con la nueva implementación
	var angle = transform.basis.x.signed_angle_to(GlobalInfo.playerPosition - position, Vector3.UP) # Frente del carrito
	return angle
	
#func lerp_towards_player(time) -> void: # TODO arreglar para que no se vea epileptico // sin uso
	#rotate(Vector3.UP, lerpf(0, steering, time))

#region interacciones con jugador y mundo

func alternate_on_player_hud() -> void:
	if LevelBuilder.controller_connected:
		Input.start_joy_vibration(0, 0.5, 0, 0.1)
	$grab_buffer.start()
	if not in_hud:
		reset_bucket_orientation()
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
		#TODO arreglar bug donde no se actualiza automáticamente sino tras 1 segundo
		steering = Vector3.BACK.signed_angle_to(inercia + centrifuga, Vector3.UP)
		if abs(horizontal_cam_delta) + (inercia.length()) > 15:
			engine_force = ( abs(horizontal_cam_delta * 7) + (inercia.length())  )
			#print(engine_force, " = ", abs(horizontal_cam_delta * 5), " + ", inercia.length())

func enter_player_focus() -> void:
	#print("entra a la vision ", Time.get_time_string_from_system())
	if not mop_stored:
		if GlobalInfo.refTrapero.anim_state != GlobalInfo.refTrapero.states.Stowed:
			$ControlTipRT.visible = true
		$ControlTipLT.visible = true
		mesh_reference.activate_outline()
		player_on_range = true

func exit_player_focus() -> void:
	$ControlTipRT.visible = false
	$ControlTipLT.visible = false
	mesh_reference.deactivate_outline()
	player_on_range = false
	
func define_appropiate_gamepad_tooltip(control : bool) -> void:
	if control:
		$ControlTipRT.texture = load("res://modelos/textures/sprites/xbox_rt.png")
		$ControlTipLT.texture = load("res://modelos/textures/sprites/xbox_lt.png")
	else:
		$ControlTipRT.texture = load("res://modelos/textures/sprites/left-click.png")
		$ControlTipLT.texture = load("res://modelos/textures/sprites/middle-click.png")

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
	$SFX/TraperoLimpiado.play()
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
		print("se cae")
		fall_coroutine(collider_pos, eje, 0)
		bucket_ko = true
		# spawnear un charco

func fall_coroutine(punto_colision : Vector3, eje : Vector3, t : float) -> void:
	if t > 0.3: 
		return
	rotate(eje, lerpf(0, 0.4, t))
	position.y += 2*get_physics_process_delta_time()
	position -= (punto_colision-global_position)*get_physics_process_delta_time()		# se ve como una solución enredad
	await get_tree().process_frame														# pero no debería traer problemas
	fall_coroutine(punto_colision, eje, t + get_physics_process_delta_time())
	
func confirm_placeability() -> bool: # no es infalible, pero requiere dedicación tirar el balde al agua
	var b : bool = true
	for child in $"ground scanner".get_children():
		b = b and child.is_colliding()
	return b

#endregion

#endregion

#region Sonido
func wheels_moving_sound() -> void:		# TODO arreglar éste sonido asqueroso
	if not $SFX/Ruedas.playing and position_delta.length_squared() > 0.1:
		$SFX/Ruedas.play()
	elif $SFX/Ruedas.playing and engine_force < 1.5:
		$SFX/Ruedas.stop()
#endregion
