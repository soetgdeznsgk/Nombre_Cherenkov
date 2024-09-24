extends Node
class_name GlobalDB
static var playerPosition : Vector3
@onready var refPlayer : CharacterBody3D = get_tree().get_nodes_in_group("Jugador").front()
var timerPosPJ : Timer

signal rana_impacta

func _init() -> void:
	timerPosPJ = Timer.new()
	timerPosPJ.wait_time = 1
	timerPosPJ.autostart = true
	timerPosPJ.connect("timeout", recuperar_posicion_jugador)
	add_child(timerPosPJ)

func recuperar_posicion_jugador() -> void:
	playerPosition = refPlayer.position
	timerPosPJ.start()

func on_aterrizaje_rana(v : Vector3) -> Vector3:
	v = GeometricToolbox.y_offset_vector_to_0(v)
	rana_impacta.emit(v)
	return v
	
