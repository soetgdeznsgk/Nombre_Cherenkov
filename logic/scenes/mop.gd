extends Area3D
class_name Mop

static var mop_saturation := 0:
	set(value):
		if value > 100:
			mop_saturation = 100 # para que no se pase de 100 y no haya riesgo de overflow
		else:
			mop_saturation = value

@export var remote_transform_ref : RemoteTransform3D
@export var mop_saturation_pace := 5

func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)

func trapeo_call(selected_node : Node) -> void:
	if selected_node == null:
		return
	#if selected_node.get_parent().is_in_group("Charcos"):
		

func trapeo_lerp(p : Vector3, t : float) -> void:
	remote_transform_ref.global_position.lerp(p, t)
	print(t, "distancia : ", position.distance_to(p))
	if t < 1:
		trapeo_lerp(p, t + 0.01)
	
