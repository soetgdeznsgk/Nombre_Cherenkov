extends Camera3D
class_name InteraccionesJugador

var v = Vector3()
var currSelection : Node

@export var mop_reference : Mop

# Parametros del trapero
#static var mop_saturation := 0:
	#set(value):
		#if value > 100:
			#mop_saturation = 100 # para que no se pase de 100 y no haya riesgo de overflow
		#else:
			#mop_saturation = value
#
#@export var mop_saturation_pace := 5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	updateDetectionExceptions()
	GlobalInfo.jugador_atrapado.connect(lock_camera)
	
	#GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
 
func _input(event):
	if event is InputEventMouseMotion:
		mop_reference.rotate_to_camera()
		v.y -= (event.relative.x * 0.2)
		v.x -= (event.relative.y * 0.2)
		v.x = clamp(v.x,-80,90)
		

func _physics_process(_delta):
	self.rotation_degrees.x = v.x
	rotation_degrees.y = v.y
	
	if Input.is_mouse_button_pressed(1) and $RayCast3D.is_colliding(): #codigo horrible que necesita URGENTEMENTE refactorizar
		currSelection = $RayCast3D.get_collider()
		# llamada a lerpear el trapero
		mop_reference.trapeo_lerp_to($RayCast3D.get_collision_point(), 0)
			#if currSelection.is_in_group("Baldes"):
				#mop_saturation = 0
				##print("trapero limpiado")
				#GlobalInfo.change_in_mop_saturation()
	elif not Input.is_mouse_button_pressed(1):
		mop_reference.trapeo_lerp_back(0)


func updateDetectionExceptions() -> void:
	await get_tree().process_frame
	$RayCast3D.add_exception($"..")
	for node in get_tree().get_nodes_in_group("NodosNavegacion"): # TODO averiguar qué otros nodos necesitan ignorarse
		$RayCast3D.add_exception(node)
	$RayCast3D.add_exception(get_tree().get_first_node_in_group("Trapero"))
	
func lock_camera(p : Vector3) -> void:
	#v = position - p TODO loquear la camara al pulpo
	pass
