extends Area3D
class_name Mop

static var debug_bool1 : bool = false
static var debug_bool2 : bool = false
static var mop_saturation : float = 0:
	set(value):
		if value > 1:
			mop_saturation = 1
			if not particles_ref.emitting:
				particles_ref.emitting = true
				dripping_sfx_ref.play()
				
			if not debug_bool2:
				#UI.trigger_next_order()
				GlobalInfo.refBalde.show_location_tooltip()
				debug_bool2 = true
			return
		
		elif value == 0:
			UI.clean_mop_order_completed()
			particles_ref.emitting = false
			dripping_sfx_ref.playing = false
			debug_bool2 = false
			mop_saturation = value
		else:
			mop_saturation = value

static var mop_saturation_pace := 0.01

@export var remote_transform_ref : RemoteTransform3D
@onready var camera_ref : InteraccionesJugador = GlobalInfo.refCamara
@onready var balde_ref : Balde = get_tree().get_first_node_in_group("Baldes")
@onready var mesh_ref : MeshInstance3D = $"trapspffas/Esqueleto_001/Skeleton3D/Círculo_002"
@onready var esqueleto_ref : Skeleton3D = $trapspffas/Esqueleto_001/Skeleton3D
static var particles_ref : GPUParticles3D
static var dripping_sfx_ref : SpatialAudioPlayer3D

# animationtree
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var wiggle_resource : DMWBWiggleRotationProperties3D = preload("res://logic/scenes/tools/mop_head_wiggle_material.tres")
enum states {
	Stowed,
	Idle,
	Cleaning
}
var anim_state : int = 0:
	set(v):
		match v:
			states.Idle:
				wiggle_resource.gravity = Vector3(0, -9.81, 0)
				wiggle_resource.linear_scale = 500
			states.Cleaning:
				wiggle_resource.gravity = Vector3.ZERO
				wiggle_resource.linear_scale = 1500
				#anim_tree["parameters/conditions/is_cleaning"] = true
			states.Stowed:
				#anim_tree["parameters/conditions/stowed"] = true
				# TODO encontrar alguna manera de compactar la cabeza, no sirven las animaciones
				pass
		anim_state = v
		#print("nuevo estado: ", anim_state, " mientras mi padre es ", get_parent())

var origin_point_in_HUD : Vector3
var current_point_of_intersection_with_floor : Vector3

@onready var mop_height : float =  $"trapspffas/Esqueleto_001/Skeleton3D/Círculo_002".get_aabb().size.y
@onready var mop_head_size : Vector3 = Vector3.ZERO#$"compound mesh/Sketchfab_model/root/GLTF_SceneRootNode/PSXBroom_0/Object_6".get_aabb().size
var state_stowed : bool = true # xq aparezce guardado
var is_overlapping_with_splots : bool
var current_splot_selected : Splot

func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(increase_saturation)
	remote_transform_ref = GlobalInfo.refCamara.mop_remote_transform
	origin_point_in_HUD = remote_transform_ref.position
	particles_ref = $GPUParticles3D
	dripping_sfx_ref = $Goteo
	
	await get_tree().process_frame
	$TutorialTooltip/AnimationPlayer.play("TutoTooltipUpAndDown")
	#state_stowed = false # DEBUG hasta que se haga para poderse "recoger" en el inicio
	
static func increase_saturation(_o : float) -> void:
	mop_saturation += mop_saturation_pace
	
func _physics_process(_delta: float) -> void:
	if is_overlapping_with_splots:
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
	if anim_state != states.Stowed:
		look_at(GlobalInfo.refPlayer.position)	

func trapeo_lerp_to(p : Vector3, _t : float) -> void:
	if anim_state == states.Idle:
		anim_state = states.Cleaning
	current_point_of_intersection_with_floor = p
	remote_transform_ref.global_position = p 
	
func trapeo_lerp_back(_t : float) -> void:
	remote_transform_ref.position = origin_point_in_HUD
	if anim_state == states.Cleaning:
		anim_state = states.Idle

func _on_area_entered(area: Area3D) -> void:			# primiferia: no es suficientemente responsivo, hacer más chiquito el area3d del charco
	if area.is_in_group("Charcos"):
		if not is_overlapping_with_splots:
			is_overlapping_with_splots = true
		current_splot_selected = area

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Charcos"):
		is_overlapping_with_splots = false
		current_splot_selected = null

static func exprimir() -> void:
		mop_saturation = 0
		GlobalInfo.reset_in_mop_saturation()

func reparent_action(nodo : Node):
	
	if not debug_bool1:
		#UI.trigger_next_order()
		debug_bool1 = true
		$TutorialTooltip.queue_free()
	
	if LevelBuilder.controller_connected:
		Input.start_joy_vibration(0, 0.5, 0, 0.1)
		
	reparent(nodo, false)
	camera_ref.alterMopException(self)
	match nodo.get_groups().front():
		"Jugador":
			remote_transform_ref.remote_path = get_path()
			#state_stowed = false
			anim_state =  states.Idle
			balde_ref.retrieve_mop() # no importa xq la función no hace nada si no tiene el trapero
			camera_ref.mop_reference = self
		"Baldes":
			remote_transform_ref.remote_path = ""
			#state_stowed = true
			anim_state = states.Stowed

		
func enter_player_focus() -> void:
	if anim_state == states.Stowed:#state_stowed:	OK
		#print("outline sirve")
		mesh_ref.activate_outline()
		$ControlTip.visible = true

func exit_player_focus() -> void:
	mesh_ref.deactivate_outline()
	$ControlTip.visible = false

func define_appropiate_gamepad_tooltip(control : bool) -> void:
	if control:
		$"ControlTip".texture = load("res://modelos/textures/sprites/xbox_rt.png")
	else:
		$"ControlTip".texture = load("res://modelos/textures/sprites/left-click.png")

func player_interaction() -> void: # metodo "interfaz"
	if GlobalInfo.timerInteractionBuffer.is_stopped() and anim_state == states.Stowed:#states_stowed: OK
		reparent_action(get_tree().get_first_node_in_group("Jugador"))
		
#func trigger_tooltip() -> void
