extends Area3D

# Éste pulpo, a diferencia de la rana, no utilizará el nodo NavigationRegion, puesto que no toda la superficie
# le está disponible, por el contrario, se moverá con fre

var current_path : PackedVector3Array 
@export var crawl_speed : float
var movement_permission := false

# TODO implementar una state machine para que los pulpos tengan los siguientes estados:
# 1: agarrando al jugador (limitando el movimiento del jugador) (para librarse hay que golpear al pulpo)
# 2: persiguiendo sobre charcos (rapidamente)
# 3: persiguiendo fuera de charcos (lentamente, expandiendo las manchas)
# 4: al borde de la piscina (extendiendo los tentáculos para cualquiera que se acerque)
# 5: saliendo de la piscina

func _ready() -> void:
	NavegacionPulpo.splot_map_updated.connect(assign_path)

func _physics_process(delta: float) -> void:
	if movement_permission:
		if position.distance_squared_to(current_path[0]) < 0.6: # la transición al otro estado puede ser cuando
																# esté más cerca al jugador que al charco?
			current_path.remove_at(0)
		
		if current_path.is_empty():
			assign_path()
		
		position += (current_path[0] - position).normalized() * crawl_speed * delta
		#print("semueve y objetivo es", current_path[0], " a distancia ", position.distance_to(current_path[0]))

func assign_path() -> void:
	current_path = NavegacionPulpo.get_pulpo_path_from_point(position)
	if not movement_permission:
		NavegacionPulpo.splot_map_updated.disconnect(assign_path)
	movement_permission = true


func _on_body_entered(body: Node3D) -> void: # DEBUG
	if body.is_in_group("Jugador"):
		GlobalInfo.squid_hugs_player()
		



func _on_body_exited(body: Node3D) -> void: # DEBUG
	if body.is_in_group("Jugador"):
		GlobalInfo.squid_leaves_player()
