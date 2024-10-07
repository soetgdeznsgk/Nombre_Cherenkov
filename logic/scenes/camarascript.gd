extends Camera3D
class_name InteraccionesJugador

var v = Vector3()
var currSelection : Node


# Parametros del trapero
static var mop_saturation := 0:
	set(value):
		if value > 100:
			pass # para que no se pase de 100 y no haya riesgo de overflow
			print("saturación máxima alcanzada")# añadir rutina para mostrar un mensaje ingame
			GlobalDB
		else:
			mop_saturation = value

@export var mop_saturation_pace := 5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	updateDetectionExceptions()
	
	GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
 
func _input(event):
	if event is InputEventMouseMotion:
		v.y -= (event.relative.x * 0.2)
		v.x -= (event.relative.y * 0.2)
		v.x = clamp(v.x,-80,90)
		

func _physics_process(_delta):
	self.rotation_degrees.x = v.x
	rotation_degrees.y = v.y
	
	if Input.is_mouse_button_pressed(1): #codigo horrible que necesita URGENTEMENTE refactorizar
		currSelection = $RayCast3D.get_collider()
		if currSelection != null:			
			#añadir shader de sombreado para la selección
			if currSelection.get_parent().is_in_group("Charcos"): #si se selecciona un charco
				if mop_saturation < 100:
					#print("IMPACTO GLOBAL EN: ",$RayCast3D.get_collision_point(), "---")
					currSelection.get_parent().spawn_hole($RayCast3D.get_collision_point())
					GlobalInfo.change_in_mop_saturation()
				else:
					pass 
					
			if currSelection.is_in_group("Baldes"):
				mop_saturation = 0
				#print("trapero limpiado")
				GlobalInfo.change_in_mop_saturation()
					


func updateDetectionExceptions() -> void:
	await get_tree().process_frame
	$RayCast3D.add_exception($"..")
	for node in get_tree().get_nodes_in_group("NodosNavegacion"): # TODO averiguar qué otros nodos necesitan ignorarse
		$RayCast3D.add_exception(node)
