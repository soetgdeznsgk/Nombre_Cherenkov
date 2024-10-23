extends Area3D
class_name Mop

static var mop_saturation := 0:
	set(value):
		if value > 100:
			mop_saturation = 100 # para que no se pase de 100 y no haya riesgo de overflow
		else:
			mop_saturation = value

@export var remote_transform_ref : RemoteTransform3D
@export var camera_ref : Camera3D
@export var mop_saturation_pace := 5
@onready var mop_height : float =  $"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_4".get_aabb().size.y
var origin_point_in_HUD : Vector3

func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
	origin_point_in_HUD = remote_transform_ref.position
	
func trapeo_call(selected_node : Node) -> void:
	if selected_node == null:
		return
	#if selected_node.get_parent().is_in_group("Charcos"):
		
func rotate_to_camera():
	look_at(GlobalInfo.refPlayer.position)
	
func trapeo_lerp_to(p : Vector3, t : float) -> void:
	#remote_transform_ref.global_position = remote_transform_ref.global_position.lerp(p, t)
	#print(t, " -- distancia : ", remote_transform_ref.global_position.distance_to(p))
	#if t < 1:
		#trapeo_lerp(p, t + 0.1)
	#else:
		#print("rutina terminada")
	#print(remote_transform_ref.global_position.distance_to(p))
	remote_transform_ref.global_position = p + Vector3(0, mop_height / 2, 0)
	
func trapeo_lerp_back(t : float) -> void:
	remote_transform_ref.position = origin_point_in_HUD
