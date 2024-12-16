extends VehicleBody3D
class_name Balde

@onready var mesh_reference := $badleAnimation/Esqueleto_002/Skeleton3D/Balde
var anim_time : float
var player_on_range : bool = false

var mop_reference : Mop
var mop_stored : bool = false
var bucket_ko : bool = false
const tumbled_over_trigger : float = 0.2

# nuevas variables
var saturation := 0.0

func _physics_process(_delta: float) -> void:
	check_bucket_orientation() # A DIFERIR, no vale la pena hacerlo todos los frames, aunque es solo checar un bit, no debe ser fuente de lag
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)): # DEBUG
		steering = get_rotation_needed_towards_player()
		engine_force = 300
		anim_time += _delta
		lerp_towards_player(anim_time)
	else:
		engine_force = 0
		anim_time = 0
		
func get_rotation_needed_towards_player() -> float:
	var angle = transform.basis.x.signed_angle_to(GlobalInfo.playerPosition - position, Vector3.UP) # Frente del carrito
	#print(angle)
	return angle
	
func change_which_wheels_will_traction() -> void:
	pass #TODO averiguar como darle más estabilidad al carro para que no se caiga
	
func lerp_towards_player(time) -> void:
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
				mop_reference.exprimir() # TEMPORAL
				mop_stored = true
				


#region in/out trapero
func place_mop_on_bucket() -> void:
	mop_reference = GlobalInfo.refTrapero
	mop_reference.reparent_action(self)
	$mop.transform = Transform3D.IDENTITY
	$mop.position = $PosicionTrapero.position
	$mop.rotate(Vector3.UP, PI/2)
	exit_player_focus()

func retrieve_mop() -> void:
	mop_stored = false
	mop_reference.exit_player_focus()
#endregion

#region estabilidad

func check_bucket_orientation() -> void:
	if transform.basis.y.dot(Vector3.UP) < tumbled_over_trigger:
		if not bucket_ko:
			bucket_ko = true
			
	else:
		if bucket_ko:
			bucket_ko = false
	#if not bucket_ko and transform.basis.y.dot(Vector3.UP) < tumbled_over_trigger:
		#bucket_ko = true
		
func reset_bucket_orientation() -> void:
	bucket_ko = false
	transform.basis = Basis() 
	
func fall_from_collision_in(collider_pos: Vector3) -> void:
	if not bucket_ko:
		var eje = (collider_pos - global_position).cross(Vector3.UP).normalized()
		rotate(eje, 1) # volver una corutina
		bucket_ko = true
		# spawnear un charco
	
	

#endregion

#endregion
