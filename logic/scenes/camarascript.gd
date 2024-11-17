extends Camera3D
class_name InteraccionesJugador

var v = Vector3()
var currSelection : Node

@export var mop_reference : Mop

var locked : bool = false
var focus_point : Vector3
var cache : String #DEBUG

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("updateDetectionExceptions")
	#GlobalInfo.jugador_atrapado.connect(lock_camera)
	
	#GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
 
func _input(event):
	if event is InputEventMouseMotion:
		mop_reference.rotate_to_camera()
		v.y -= (event.relative.x * 0.2)
		v.x -= (event.relative.y * 0.2)
		v.x = clamp(v.x,-80,90)
		

func _physics_process(_delta):
	if not locked:
		rotation_degrees.x = v.x
		rotation_degrees.y = v.y
	else:
		look_at(focus_point)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $RayCast3D.is_colliding(): 
		currSelection = $RayCast3D.get_collider()
		mop_reference.trapeo_lerp_to($RayCast3D.get_collision_point(), 0)
		
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mop_reference.trapeo_lerp_back(0)


func updateDetectionExceptions() -> void:
	#	wawait get_tree().process_frame
	$RayCast3D.add_exception($"..")
	for node in get_tree().get_nodes_in_group("NodosNavegacion"): # TODO averiguar qué otros nodos necesitan ignorarse
		$RayCast3D.add_exception(node)
	$RayCast3D.add_exception(get_tree().get_first_node_in_group("Trapero"))
	
func lock_camera(p : Vector3) -> void:
	focus_point = p
	#look_at(focus_point)
	locked = true
	v = Vector3.ZERO
	
func free_camera() -> void:
	locked = false
