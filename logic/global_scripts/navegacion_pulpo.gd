extends Node

@onready var pathfinding_map := AStar3D.new()
# Éste singleton va a estar encargado de manejar la actualización de los nodos por los cuales el pulpo será capaz
# de viajar, se ejecutará su contenido cuando haya un cambio en la cantidad de charcos del mapa

var splot_list := PackedVector3Array()
# TODO cambiar ésto por el minheap implementado de nueva manera ya que la actual implementación es On^2
# mientras que el minheap es solo como O(t * n * log_2(n)), lo cual será necesario si se esperan tener más
# de 30 splots cargados al tiempo

# instrucciones:
# inserción de un nuevo splot:
# 1) splotlistMINHEAP.add(NSplot)
# 2) splotlistMINHEAP.heapsort(bajo la operación splot.distancesquaredto(NSplot))
# 3) for i < 6 :
#		astar.add_point(splotlistMINHEAP[i])
#		astar.connect_points(NSplot, splotlistMINHEAP[i])
# eliminación:
# 1) cri cri
# 2) cri cri
# 3) cri cri

func add_splot_to_registry(p : Vector3) -> void:
	splot_list.append(p)
	
func rmv_splot_from_registry(p : Vector3) -> void:
	var tmp := splot_list.find(p)
	if tmp != -1:
		splot_list.remove_at(tmp)
	
