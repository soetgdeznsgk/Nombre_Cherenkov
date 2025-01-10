extends Area3D

var highlight : bool = false
var enabled : bool = false
var winding : bool = false
@export var z_rotation_target : float = 75
var origin_local : Vector3
var delta_time : float
var time_total : float = 0

@onready var skeleton_ref : Skeleton3D = $"../baldeClean/Esqueleto_002/Skeleton3D"
@onready var lever_bone_idx : int = skeleton_ref.find_bone("Bone.003")
@onready var mesh_ref : MeshInstance3D = $"../baldeClean/Esqueleto_002/Skeleton3D/Balde"
@onready var material : Material = preload("res://logic/ambient_scripts/postprocessing_items/blue_override_bucket_lever.tres")


@onready var timer_ref : Timer = $TimerUnavailable
var wind_up_time : float = 1

signal lever_activated
	
func _ready():
	origin_local = position

func _physics_process(delta: float) -> void:
	delta_time =  delta
	if winding:
		reset_lerp(time_total)

func enter_player_focus() -> void:
	if enabled and not highlight:
		mesh_ref.set_surface_override_material(1, material) # 1 es la palanca del balde
		highlight = true
		
func exit_player_focus() -> void:
	if highlight:
		mesh_ref.set_surface_override_material(1, null)
		highlight = false	
	
func deactivate() -> void:
	$CollisionShape3D.disabled = true
	exit_player_focus()
	enabled = false
	reset_rotation()
	
func activate() -> void:
	$CollisionShape3D.disabled = false
	enabled = true

func reset_rotation():
	time_total = 0
	winding = true

func action_lerp():
	var n_z : float = lerp(rotation_degrees.z, z_rotation_target, time_total)
	
	rotation_degrees.z = n_z
	position += Vector3.BACK * delta_time * (1 - time_total) # TODO arreglar para que no se aleje tanto
	skeleton_ref.set_bone_pose_rotation(lever_bone_idx, Quaternion(Vector3.FORWARD, -n_z * PI/180 * 0.5))
	if time_total > 0.8: 
		lever_activated.emit()
		time_total = 0
		winding = true
	# rotar el mesh
	
func reset_lerp(delta : float):
	var n_z : float = lerp(rotation_degrees.z, 0.0, delta)
	
	rotation_degrees.z = n_z
	position = origin_local
	skeleton_ref.set_bone_pose_rotation(lever_bone_idx, Quaternion(Vector3.FORWARD, -n_z * PI/180 * 0.5))
	time_total += delta_time
	# devolver la rotación del mesh
	if time_total > 1:
		time_total = 0
		winding = false

func player_interaction() -> void:
	#if GlobalInfo.refCamara.get_interaction_raycast_ref().get_collider() == self:
	if not winding:
		time_total += delta_time
		action_lerp()
	
