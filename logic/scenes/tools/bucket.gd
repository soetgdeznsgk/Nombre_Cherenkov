extends VehicleBody3D
class_name Balde

@onready var mesh_reference : MeshInstance3D = $badleAnimation/Esqueleto_002/Skeleton3D/Balde
var remote_transform_ref : RemoteTransform3D
var anim_time : float
var player_on_range : bool = false

var in_hud : bool = false
var mop_reference : Mop
var mop_stored : bool = false
var bucket_ko : bool = false
const tumbled_over_trigger : float = 0.2

@onready var lever_interaction_node : Area3D = $"Area3D Palanca"
# nuevas variables
var saturation := 0.0

func _physics_process(_delta: float) -> void:
	if not in_hud:
		#steering = get_rotation_needed_towards_player()
		check_bucket_orientation() # A DIFERIR, no vale la pena hacerlo todos los frames, aunque es solo checar un bit, no debe ser fuente de lag
		if engine_force > 1: # solución barata, funciona para frenar entonces lo considero terminado
			engine_force /= 1.05
					
		if global_position.distance_squared_to(GlobalInfo.playerPosition) < 40:
			player_on_range = true
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and $grab_buffer.is_stopped(): 
				$grab_buffer.start()
				#anim_time += _delta
				#lerp_towards_player(anim_time)
				
				if remote_transform_ref == null:
					remote_transform_ref = GlobalInfo.refPlayer.camara_ref.bucket_remote_transform
				remote_transform_ref.remote_path = get_path()
				freeze = true
				$"CollisionShape3D Balde".disabled = true
				
				in_hud = true
				
		else:
			player_on_range = false
			anim_time = 0
	
	else: # TODO refactorizar este codigo horrible
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and $grab_buffer.is_stopped(): 
			if global_position.y > -0.5: # para que no se clipee en el piso
				$grab_buffer.start()
				remote_transform_ref.remote_path = ""
				freeze = false
				$"CollisionShape3D Balde".disabled = false
				in_hud = false
			
		
func rotate_to_camera(horizontal_cam_delta : float):
	if in_hud:
		look_at_from_position(GeometricToolbox.y_offset_vector_to_0(global_position), GeometricToolbox.y_offset_vector_to_0(GlobalInfo.playerPosition))
		#region Rotación del esqueleto
		var inercia = Vector3.LEFT * horizontal_cam_delta
		var centrifuga = Vector3.BACK * abs(horizontal_cam_delta) # TODO esto será afectado por si el balde tiene agua o no
		# TODO también por la velocidad actual del vehículo
	
		
		$steering.target_position = inercia + centrifuga
		$z.target_position = Vector3.BACK
		steering = Vector3.BACK.signed_angle_to(inercia + centrifuga, Vector3.UP)
		engine_force = abs(horizontal_cam_delta) * 5
		#endregion

func get_rotation_needed_towards_player() -> float:
	var angle = transform.basis.x.signed_angle_to(GlobalInfo.playerPosition - position, Vector3.UP) # Frente del carrito
	return angle
	
func lerp_towards_player(time) -> void: # TODO arreglar para que no se vea epileptico
	rotate(Vector3.UP, lerpf(0, steering, time))

#region interacciones con jugador y mundo
func enter_player_focus() -> void:
	if not mop_stored:
		mesh_reference.activate_outline()
		player_on_range = true

func exit_player_focus() -> void:
	mesh_reference.deactivate_outline()
	player_on_range = false

func player_interaction() -> void: #ésta función estará en TODOS los objetos con un efecto especial de interacción
	if GlobalInfo.timerInteractionBuffer.is_stopped():
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
	#if not bucket_ko and transform.basis.y.dot(Vector3.UP) < tumbled_over_trigger:
		#bucket_ko = true
		
func reset_bucket_orientation() -> void:
	bucket_ko = false
	transform.basis = Basis() 
	
func fall_from_collision_in(collider_pos: Vector3) -> void:
	if not bucket_ko and not in_hud:
		var eje = (collider_pos - global_position).cross(Vector3.UP).normalized()
		rotate(eje, 1) # volver una corutina
		bucket_ko = true
		# spawnear un charco
	
	

#endregion

#endregion
