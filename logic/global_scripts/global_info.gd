extends Node
class_name GlobalDB

# parametros ambiente
const splot_limit := 100

# info jugador
static var playerPosition : Vector3
var timerPosPJ : Timer
@onready var refPlayer : CharacterBody3D = get_tree().get_nodes_in_group("Jugador").front()

# info UI
@onready var refUI : UI = get_tree().get_first_node_in_group("UI")
@onready var refContBar := get_tree().get_first_node_in_group("ContaminationBar")

signal rana_impacta # emitido desde on_aterrizaje_rana
signal jugador_trapea # utilizada para la señal visual del trapero
signal trapero_limpiado
signal jugador_atrapado 
#signal cambio_saturacion # notificacion para cambiar el brillo del trapero

func _init() -> void:
	#timerPosPJ = Timer.new()
	#timerPosPJ.wait_time = 1
	#timerPosPJ.autostart = true
	#timerPosPJ.connect("timeout", recuperar_posicion_jugador)
	#add_child(timerPosPJ)
	pass

func _process(delta: float) -> void:
	playerPosition = refPlayer.position
	
#func recuperar_posicion_jugador() -> void:
	#playerPosition = refPlayer.position
	#timerPosPJ.start()

func on_aterrizaje_rana(v : Vector3) -> Vector3: #llamado desde rana.gd
	v = GeometricToolbox.y_offset_vector_to_0(v)
	#refUI.update_contamination_bar(3) #valor base de cada charco 
	refContBar.update_contamination_bar(7)
	rana_impacta.emit(v)
	return v

func change_in_mop_saturation() -> void:
	jugador_trapea.emit(Mop.mop_saturation)
	refUI.update_saturation_bar(Mop.mop_saturation)
	#refUI.update_contamination_bar(-0.8) deprecado xq ahora la barra se ve ingame
	refContBar.update_contamination_bar(-0.8)

func reset_in_mop_saturation() -> void:
	trapero_limpiado.emit()
	refUI.update_saturation_bar(Mop.mop_saturation)
	
func squid_hugs_player(squidPosition : Vector3) -> void:
	refUI.show_entrapment_inflicted_sign()
	jugador_atrapado.emit(squidPosition)

func squid_leaves_player() -> void:
	refUI.reset_healty_status()
