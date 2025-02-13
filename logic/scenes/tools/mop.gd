extends Area3D
class_name Mop

static var mop_saturation : float = 0.0:
	set(value):
		if value > 1:
			mop_saturation = 1
		else:
			#print(value)
			mop_saturation = value
@export var mop_saturation_pace := 0.01

@export var remote_transform_ref : RemoteTransform3D
@onready var camera_ref : InteraccionesJugador = GlobalInfo.refCamara
@onready var balde_ref : Balde = get_tree().get_first_node_in_group("Baldes")
@onready var mesh_ref : MeshInstance3D = $"mopAniText/Esqueleto_001/Skeleton3D/Círculo_002"
@onready var esqueleto_ref : Skeleton3D = $mopAniText/Esqueleto_001/Skeleton3D

# huesos
@onready var base_bone_idx : int = esqueleto_ref.find_bone("Bone.002") # base se rota hacia adelante y atrás
@onready var intermediate_bone_idx : int = esqueleto_ref.find_bone("Bone.003") # medio se rota hacia los lados
@onready var tip_bone_idx : int = esqueleto_ref.find_bone("Bone.005")

var origin_point_in_HUD : Vector3
var current_point_of_intersection_with_floor : Vector3

@onready var mop_height : float =  $"mopAniText/Esqueleto_001/Skeleton3D/Círculo_002".get_aabb().size.y
@onready var mop_head_size : Vector3 = Vector3.ZERO#$"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_6".get_aabb().size
var state_stowed : bool = true # xq aparezce guardado
var state_cleaning : bool
var current_splot_selected : Splot


func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(func(_o): mop_saturation += mop_saturation_pace)
	remote_transform_ref = GlobalInfo.refCamara.mop_remote_transform
	origin_point_in_HUD = remote_transform_ref.position
	#state_stowed = false # DEBUG hasta que se haga para poderse "recoger" en el inicio
	
	
func _physics_process(_delta: float) -> void:
	if state_cleaning:
		if mop_saturation < 1:
			paint_holes_in_splots()
			
func paint_holes_in_splots() -> void:
	for area in get_overlapping_areas():
		if area.is_in_group("Charcos"):
			area.spawn_hole(current_point_of_intersection_with_floor, \
			mop_head_size)# servirá para adaptar la forma del hueco al área de intersección, no funciona


func trapeo_call(selected_node : Node) -> void:
	if selected_node == null:
		return
		
func rotate_to_camera(mouse_movement_delta : Vector2):
	if not state_stowed:
		look_at(GlobalInfo.refPlayer.position)	
		#print("baseY: ", global_basis.y, " to ", Vector3.DOWN, " -> ", (-global_basis.y).signed_angle_to(Vector3.DOWN, Vector3.RIGHT))
		#region Rotación del esqueleto
		# Rotación producto de la gravedad y la fuerza centrífuga
		
		esqueleto_ref.set_bone_pose_rotation(base_bone_idx, Quaternion(Vector3.RIGHT, 
						(-global_basis.y).signed_angle_to(Vector3.DOWN, basis.x)
						- abs(mouse_movement_delta.x / 130))) # centrífuga 
		
		# Rotación producto del momento de rotación
		esqueleto_ref.set_bone_pose_rotation(intermediate_bone_idx, Quaternion(Vector3.FORWARD, 
						mouse_movement_delta.x / 100)) # TODO averiguar como hacerlo "mas fluido"
						
		esqueleto_ref.set_bone_pose_rotation(tip_bone_idx, Quaternion(Vector3.FORWARD,
						mouse_movement_delta.x / 130))
		#endregion
		
func normalize_mesh_perturbation() -> void:
	#esqueleto_ref.set_bone_pose_rotation(base_bone_idx, Quaternion(basis.x, 
						#(-basis.y).signed_angle_to(Vector3.DOWN, basis.x)))
	#esqueleto_ref.set_bone_rest(base_bone_idx, Basis.IDENTITY)
	pass # TODO reiniciar la rotación de los huesos cuando esté en el balde

func trapeo_lerp_to(p : Vector3, _t : float) -> void:
	#remote_transform_ref.global_position = remote_transform_ref.global_position.lerp(p, t)
	#print(t, " -- distancia : ", remote_transform_ref.global_position.distance_to(p))
	#if t < 1:
		#trapeo_lerp(p, t + 0.1)
	#else:
		#print("rutina terminada")
	#print(remote_transform_ref.global_position.distance_to(p))
	current_point_of_intersection_with_floor = p
	var deb := mop_height /5
	remote_transform_ref.global_position = p + Vector3(0, deb / 5, 0) # arreglar
	
func trapeo_lerp_back(_t : float) -> void:
	#TODO animar estavaina
	remote_transform_ref.position = origin_point_in_HUD

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Charcos"):
		state_cleaning = true
		current_splot_selected = area
		#print(area.name)
		#area.spawn_hole(current_point_of_intersection_with_floor, \
		#GeometricToolbox.y_offset_vector_to_0(mop_head_size))

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Charcos"):
		state_cleaning = false
		current_splot_selected = null

func exprimir() -> void:
		mop_saturation = 0
		GlobalInfo.reset_in_mop_saturation()

func reparent_action(nodo : Node):
	reparent(nodo, false)
	camera_ref.alterMopException(self)
	match nodo.get_groups().front():
		"Jugador":
			remote_transform_ref.remote_path = get_path()
			state_stowed = false
			balde_ref.retrieve_mop() # no importa xq la función no hace nada si no tiene el trapero
			camera_ref.mop_reference = self
		"Baldes":
			remote_transform_ref.remote_path = ""
			state_stowed = true
			normalize_mesh_perturbation()

		
func enter_player_focus() -> void:
	if state_stowed:
		mesh_ref.activate_outline()

func exit_player_focus() -> void:
	mesh_ref.deactivate_outline()

func player_interaction() -> void: # metodo "interfaz"
	if state_stowed and GlobalInfo.timerInteractionBuffer.is_stopped():
		reparent_action(get_tree().get_first_node_in_group("Jugador"))
