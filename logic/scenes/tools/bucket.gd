extends VehicleBody3D
class_name Balde

@onready var mesh_reference := $Sketchfab_Scene/Sketchfab_model/SM_kzhang3_bucket_obj_cleaner_materialmerger_gles/Object_2
var anim_time : float
var player_on_range : bool = false

var mop_reference : Mop
var mop_stored : bool = false

# nuevas variables
var saturation := 0.0

func _physics_process(_delta: float) -> void:
	steering = get_rotation_needed_towards_player()
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)): # DEBUG
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

func enter_player_focus() -> void:
	if not mop_stored:
		mesh_reference.activate_outline()
		player_on_range = true

func exit_player_focus() -> void:
	mesh_reference.deactivate_outline()
	player_on_range = false

func player_interaction() -> void: #ésta función estará en TODOS los objetos con un efecto especial de interacción
	if not mop_stored:
		place_mop_on_bucket()
		mop_stored = true
	else:
		mop_reference.exprimir()

func place_mop_on_bucket() -> void:
	mop_reference = GlobalInfo.refTrapero
	mop_reference.reparent_action(self)
	$mop.transform = Transform3D.IDENTITY
	$mop.position = $PosicionTrapero.position
	$mop.rotate(Vector3.UP, PI/2)
	exit_player_focus()

func retrieve_mop() -> void:
	mop_stored = false
