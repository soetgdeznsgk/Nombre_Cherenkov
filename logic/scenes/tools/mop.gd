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
@export var camera_ref : InteraccionesJugador
@onready var balde_ref : Balde = get_tree().get_first_node_in_group("Baldes")
@onready var mesh_parent_ref : Node3D = $"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0"

var origin_point_in_HUD : Vector3
var current_point_of_intersection_with_floor : Vector3

@onready var mop_height : float =  $"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_4".get_aabb().size.y
@onready var mop_head_size : Vector3 = $"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_6".get_aabb().size

var state_stowed : bool = true # xq aparezce guardado
var state_cleaning : bool
var current_splot_selected : Splot


func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(func(_o): mop_saturation += mop_saturation_pace)
	origin_point_in_HUD = remote_transform_ref.position
	state_stowed = false # DEBUG hasta que se haga para poderse "recoger" en el inicio
	
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
		
func rotate_to_camera():
	if not state_stowed:
		look_at(GlobalInfo.refPlayer.position)

func trapeo_lerp_to(p : Vector3, _t : float) -> void:
	#remote_transform_ref.global_position = remote_transform_ref.global_position.lerp(p, t)
	#print(t, " -- distancia : ", remote_transform_ref.global_position.distance_to(p))
	#if t < 1:
		#trapeo_lerp(p, t + 0.1)
	#else:
		#print("rutina terminada")
	#print(remote_transform_ref.global_position.distance_to(p))
	current_point_of_intersection_with_floor = p
	remote_transform_ref.global_position = p + Vector3(0, mop_height / 3, 0) # arreglar
	
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

func _on_body_entered(_body: Node3D) -> void:
	#if body.is_in_group("Baldes"): DEPRECADO: ahora se reinicia con una llamada desde el balde a exprimir()
		#mop_saturation = 0
		#GlobalInfo.reset_in_mop_saturation()
	pass
	
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
			balde_ref.retrieve_mop()
		"Baldes":
			remote_transform_ref.remote_path = ""
			state_stowed = true
		
func enter_player_focus() -> void:
	if state_stowed:
		mesh_parent_ref.activate_outline()
		pass	

func exit_player_focus() -> void:
	mesh_parent_ref.deactivate_outline()

func player_interaction() -> void: # metodo "interfaz"
	if state_stowed:
		reparent_action(get_tree().get_first_node_in_group("Jugador"))
