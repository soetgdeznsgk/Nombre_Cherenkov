extends Node
class_name GlobalDB

# parametros ambiente
const splot_limit := 100

# info jugador
static var playerPosition : Vector3
var timerPosPJ : Timer
@onready var refPlayer : CharacterBody3D = get_tree().get_nodes_in_group("Jugador").front()

# info UI
@onready var refUI : UI = get_tree().get_nodes_in_group("UI").front()

signal rana_impacta # emitido desde on_aterrizaje_rana
signal jugador_trapea

func _init() -> void:
	timerPosPJ = Timer.new()
	timerPosPJ.wait_time = 1
	timerPosPJ.autostart = true
	timerPosPJ.connect("timeout", recuperar_posicion_jugador)
	add_child(timerPosPJ)

func recuperar_posicion_jugador() -> void:
	playerPosition = refPlayer.position
	timerPosPJ.start()

func on_aterrizaje_rana(v : Vector3) -> Vector3: #llamado desde rana.gd
	v = GeometricToolbox.y_offset_vector_to_0(v)
	refUI.update_contamination_bar(3) #valor base de cada charco 
	rana_impacta.emit(v)
	return v

func on_jugador_trapea() -> void:
	jugador_trapea.emit()
	refUI.update_contamination_bar(-0.8)

func change_in_mop_saturation() -> void:
	refUI.update_saturation_bar(Mop.mop_saturation)
	
func squid_hugs_player() -> void:
	refUI.show_entrapment_inflicted_sign()

func squid_leaves_player() -> void:
	refUI.reset_healty_status()
