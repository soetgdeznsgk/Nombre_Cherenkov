extends Node
class_name GlobalDB

# parametros ambiente
const splot_limit := 100
var splot_count := 0

# info jugador
static var playerPosition : Vector3
@onready var timerInteractionBuffer: Timer = Timer.new()
const NO_INTERACTION_TIME := 0.5

# referencias jugador
@onready var refPlayer : CharacterBody3D = get_tree().get_nodes_in_group("Jugador").front()
@onready var refCamara : InteraccionesJugador = refPlayer.get_camera_ref()
@onready var refTrapero : Mop = get_tree().get_nodes_in_group("Trapero").front()

# info UI
@onready var refUI : UI = get_tree().get_first_node_in_group("UI")
@onready var refContBar : Contamination_Ingame_Bar = get_tree().get_first_node_in_group("ContaminationBar")

signal rana_impacta # emitido desde on_aterrizaje_rana
signal jugador_trapea # utilizada para la señal visual del trapero
signal trapero_limpiado
#signal jugador_atrapado 
#signal cambio_saturacion # notificacion para cambiar el brillo del trapero
var cantidad_ranas : int
var cantidad_pulpos : int

func _ready() -> void:
	add_child(timerInteractionBuffer)
	timerInteractionBuffer.one_shot = true

func _process(_delta: float) -> void:
	playerPosition = refPlayer.position

func on_aterrizaje_rana(v : Vector3) -> Vector3: #llamado desde rana.gd
	v = GeometricToolbox.y_offset_vector_to_0(v)
	#refUI.update_contamination_bar(3) #valor base de cada charco 
	refContBar.update_contamination_bar(7)
	rana_impacta.emit(v)
	splot_count += 1
	#print("Charco #", splot_count)
	return v

func change_in_mop_saturation() -> void:
	jugador_trapea.emit(Mop.mop_saturation)
	refUI.update_saturation_bar(Mop.mop_saturation)
	#refUI.update_contamination_bar(-0.8) deprecado xq ahora la barra se ve ingame
	refContBar.update_contamination_bar(-1)
	#print(refContBar.get_contamination_value())

func reset_in_mop_saturation() -> void:
	trapero_limpiado.emit()
	refUI.update_saturation_bar(Mop.mop_saturation)# actualmente no hay UI entonces no hace nada
	
func squid_hugs_player(squidPosition : Vector3) -> void:
	refUI.show_entrapment_inflicted_sign() # actualmente no hay UI entonces no hace nada
	#jugador_atrapado.emit(squidPosition)
	refPlayer.set_center_of_gravity(squidPosition)

func squid_leaves_player() -> void:
	refUI.reset_healty_status()  # actualmente no hay UI entonces no hace nada
	refPlayer.reset_player_movement_freedom()
	
func start_interaction_buffer() -> void:
	timerInteractionBuffer.start(NO_INTERACTION_TIME)
	
