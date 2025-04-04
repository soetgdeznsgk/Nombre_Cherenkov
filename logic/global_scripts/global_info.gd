extends Node
class_name GlobalDB

# parametros ambiente
const splot_limit := 100
var splot_count := 0
@export var lightbulb_max_energy : int = 1
var meltdown_triggered : bool = false
var winning_secuence :bool = false

# info jugador
static var playerPosition : Vector3
@onready var timerInteractionBuffer: Timer = Timer.new()
const NO_INTERACTION_TIME := 0.3

# referencias jugador
@onready var refPlayer : CharacterBody3D = get_tree().get_nodes_in_group("Jugador").front()
@onready var refCamara : InteraccionesJugador
@onready var refTrapero : Mop = get_tree().get_nodes_in_group("Trapero").front()

@onready var refBalde : Balde = get_tree().get_first_node_in_group("Baldes")

# info UI
@onready var refUI : UI = get_tree().get_first_node_in_group("UI")
@onready var refContBar : Contamination_Ingame_Bar = get_tree().get_first_node_in_group("ContaminationBar")

@onready var refPiscina : Pool = get_tree().get_first_node_in_group("Piscinas")

signal rana_impacta # emitido desde on_aterrizaje_rana
signal jugador_trapea # utilizada para la señal visual del trapero
signal trapero_limpiado
#signal jugador_atrapado 
#signal cambio_saturacion # notificacion para cambiar el brillo del trapero
var cantidad_ranas : int
var cantidad_pulpos : int
var debug_bool : bool = false

func _ready() -> void:
	add_child(timerInteractionBuffer)
	timerInteractionBuffer.one_shot = true
	await refPlayer.ready
	refCamara = refPlayer.get_camera_ref()

func _process(_delta: float) -> void:
	playerPosition = refPlayer.position

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Debug_Exec"):
		print("jiji")
		#trigger_win_state()
		
		#for n in get_tree().get_nodes_in_group("CajasFusibles"):
			#if debug_bool == false:
				#get_tree().get_first_node_in_group("CajasFusibles").squid_interaction(0)
			#else:
				#get_tree().get_first_node_in_group("CajasFusibles").player_interaction()
		#debug_bool = not debug_bool
			
	

func on_aterrizaje_rana(v : Vector3) -> Vector3: #llamado desde rana.gd
	v = GeometricToolbox.y_offset_vector_to_0(v)
	#refUI.update_contamination_bar(3) #valor base de cada charco 
	refContBar.update_contamination_bar(3)
	rana_impacta.emit(v)
	splot_count += 1
	return v

func change_in_mop_saturation() -> void:
	jugador_trapea.emit(Mop.mop_saturation)
	refUI.update_saturation_bar(Mop.mop_saturation)
	refContBar.update_contamination_bar(-0.7)

func reset_in_mop_saturation() -> void:
	trapero_limpiado.emit()
	refUI.update_saturation_bar(Mop.mop_saturation)# actualmente no hay UI entonces no hace nada
	UI.clean_mop_order_completed()
	
func squid_hugs_player(squidPosition : Vector3) -> void:
	refUI.show_entrapment_inflicted_sign() # actualmente no hay UI entonces no hace nada
	#jugador_atrapado.emit(squidPosition)
	refPlayer.set_center_of_gravity(squidPosition)

func squid_leaves_player() -> void:
	refUI.reset_healty_status()  # actualmente no hay UI entonces no hace nada
	refPlayer.reset_player_movement_freedom()
	
func start_interaction_buffer() -> void:
	timerInteractionBuffer.start(NO_INTERACTION_TIME)

func bucket_just_equipped() -> void:
	refPlayer.realentizacion_balde = true
	refCamara.interaction_raycast.enabled = false

func bucket_just_unequipped() -> void:
	refPlayer.realentizacion_balde = false
	refCamara.interaction_raycast.enabled = true
	
func start_reactor_meltdown() -> void:
	if not meltdown_triggered:
		meltdown_triggered = true
		await get_tree().create_timer(0.5).timeout
		get_tree().call_group("Alarmables", "start")
		if LevelBuilder.controller_connected:
			Input.start_joy_vibration(0, 0.5, 0.5, 1.5)
		
#region Manejo de fuentes de luz

func force_lights_flickering() -> void:
	for light in get_tree().get_nodes_in_group("BombillasApagables"):
		light.force_flicker()
	
func shut_down_lights() -> void:
	for light in get_tree().get_nodes_in_group("BombillasApagables"):
		light.force_off()
		#añadir sfx de apagado de luz
	
func reset_lights() -> void:
	for light in get_tree().get_nodes_in_group("BombillasApagables"):
		light.reset_light()
		#añadir sfx de prendido de luz

#endregion

#region ENDINGS
func trigger_loss_state() -> void:
	if winning_secuence:
		return
	get_tree().get_first_node_in_group("GameOverTriggerables").start_screen_shake_game_over() # tocará abstraer ésta función para llamar a todos los objetos con similitudes
	refPiscina.trigger_white_out()
	if LevelBuilder.controller_connected:
		Input.start_joy_vibration(0, 0.5, 0.5, 5)
	await get_tree().create_timer(5).timeout
	get_tree().quit()
	
func trigger_win_state() -> void:
	winning_secuence = true
	UI.trigger_win_sign()
	get_tree().get_first_node_in_group("WinStateTriggerables").play("Door_Open")
	#await get_tree().create_timer(10).timeout
	#get_tree().quit()
	
func force_quit() -> void:
	get_tree().quit()
#endregion
