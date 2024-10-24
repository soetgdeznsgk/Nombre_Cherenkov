extends Area3D
class_name Mop

static var mop_saturation : float = 0.0:
	set(value):
		if value > 1:
			mop_saturation = 1 
		else:
			mop_saturation = value
@export var mop_saturation_pace := 0.05

@export var remote_transform_ref : RemoteTransform3D
@export var camera_ref : Camera3D

var origin_point_in_HUD : Vector3
var current_point_of_intersection_with_floor : Vector3

@onready var mop_height : float =  $"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_4".get_aabb().size.y
@onready var mop_head_size : Vector3 = $"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_6".get_aabb().size
@onready var debug_position_squid := preload("res://logic/scenes/squid.tscn")

var state_cleaning : bool
var current_splot_selected : Splot

func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(func(): mop_saturation += mop_saturation_pace)
	origin_point_in_HUD = remote_transform_ref.position
	
func _physics_process(delta: float) -> void:
	if state_cleaning:
		if mop_saturation < 1:
			current_splot_selected.spawn_hole(current_point_of_intersection_with_floor, \
			mop_head_size) 
			GlobalInfo.change_in_mop_saturation()

	
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
	current_point_of_intersection_with_floor = p
	remote_transform_ref.global_position = p + Vector3(0, mop_height / 3, 0) # arreglar
	
func trapeo_lerp_back(t : float) -> void:
	remote_transform_ref.position = origin_point_in_HUD

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Charcos"):
		state_cleaning = true
		current_splot_selected = area
		#area.spawn_hole(current_point_of_intersection_with_floor, \
		#GeometricToolbox.y_offset_vector_to_0(mop_head_size))

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Charcos"):
		state_cleaning = false
		current_splot_selected = null
