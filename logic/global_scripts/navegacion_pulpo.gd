extends Node

@onready var pathfinding_map := AStar3D.new()
# Éste singleton va a estar encargado de manejar la actualización de los nodos por los cuales el pulpo será capaz
# de viajar, se ejecutará su contenido cuando haya un cambio en la cantidad de charcos del mapa

var splot_list := PackedVector3Array()

signal splot_map_updated # para que los pulpos esperen a que hayan charcos para moverse

func add_splot_to_registry(s : Splot) -> void: # se añaden desde splot.gd
	#splot_list.append(s.global_position)
	var astar_index := randi_range(0, GlobalDB.splot_limit)
	s.set_navigation_id(astar_index)
	pathfinding_map.add_point(astar_index, s.global_position)
	
	for point_id in pathfinding_map.get_point_ids():
		if pathfinding_map.get_point_position(astar_index)\
		.distance_squared_to(pathfinding_map.get_point_position(point_id)) > 6:
			pathfinding_map.connect_points(astar_index, point_id)
	splot_map_updated.emit()
	
func rmv_splot_from_registry(s : Splot) -> void: # se borran desde splot.gd
	if pathfinding_map.has_point(s.navigation_id):
		pathfinding_map.remove_point(s.navigation_id)
	splot_map_updated.emit()
	
func get_pulpo_path_from_point(pulpo_pos : Vector3) -> PackedVector3Array:
	var start_ref : int = pathfinding_map.get_closest_point(pulpo_pos)
	var end_ref : int = pathfinding_map.get_closest_point(GlobalInfo.playerPosition)

	if start_ref != -1 and end_ref != -1:
		return pathfinding_map.get_point_path(start_ref, end_ref, true)
	return PackedVector3Array()
	
func get_escape_path(pulpo_ref : Pulpo) -> PackedVector3Array:
	var start_ref : int = pathfinding_map.get_closest_point(pulpo_ref.position)
	var end_ref : int = pathfinding_map.get_closest_point(pulpo_ref.origin)

	if start_ref != -1 and end_ref != -1:
		return pathfinding_map.get_point_path(start_ref, end_ref, true)
	return PackedVector3Array()
