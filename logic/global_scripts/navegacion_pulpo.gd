extends Node

@onready var pathfinding_map := AStar3D.new()
# Éste singleton va a estar encargado de manejar la actualización de los nodos por los cuales el pulpo será capaz
# de viajar, se ejecutará su contenido cuando haya un cambio en la cantidad de charcos del mapa

var splot_list := PackedVector3Array()

signal splot_map_updated # para que los pulpos esperen a que hayan charcos para moverse

func set_custom_splot_weight(index : int, v : float) -> void:		# BUG, a veces cuando spawnea el pulpo se queda trabado en el primer charco?
	pathfinding_map.set_point_weight_scale(index, v)

func add_splot_to_registry(s : Splot) -> void: # se añaden desde splot.gd
	#splot_list.append(s.global_position)
	var astar_index := randi_range(0, GlobalDB.splot_limit)					# revisar si ésto se bugea cuando hay más charcos que el límite
	s.set_navigation_id(astar_index)
	pathfinding_map.add_point(astar_index, s.global_position)
	
	if Splot.origin_splot != null:
		print(pathfinding_map.get_point_weight_scale(Splot.origin_splot.navigation_id))

	for point_id in pathfinding_map.get_point_ids():
		if pathfinding_map.get_point_position(astar_index)\
		.distance_squared_to(pathfinding_map.get_point_position(point_id)) < 100:
			pathfinding_map.connect_points(astar_index, point_id)
	splot_map_updated.emit()
	
func rmv_splot_from_registry(s : Splot) -> void: # se borran desde splot.gd
	if pathfinding_map.has_point(s.navigation_id):
		pathfinding_map.remove_point(s.navigation_id)
	splot_map_updated.emit()
	
func get_pulpo_path_from_point(pulpo : Pulpo, objetivo : Node3D) -> PackedVector3Array:
	var start_ref : int = pathfinding_map.get_closest_point(pulpo.global_position)
	var end_ref : int = pathfinding_map.get_closest_point(objetivo.global_position)
	
	if start_ref != -1 and end_ref != -1:
		return pathfinding_map.get_point_path(start_ref, end_ref, false)
	return PackedVector3Array()
	
func get_escape_path(pulpo_ref : Pulpo) -> PackedVector3Array:
	if pulpo_ref.position.distance_squared_to(pulpo_ref.origin) < 0.6:
		pulpo_ref.pop_squid()
	var start_ref : int = pathfinding_map.get_closest_point(pulpo_ref.position)
	var end_ref : int = pathfinding_map.get_closest_point(pulpo_ref.origin)
	
	var t : int = pathfinding_map.get_point_weight_scale(Splot.origin_splot.navigation_id)			# Guardar el INF del origen pa que no se pierda
	pathfinding_map.set_point_weight_scale(Splot.origin_splot.navigation_id, 0)
	
	if start_ref != -1 and end_ref != -1:
		var m : PackedVector3Array = pathfinding_map.get_point_path(start_ref, end_ref, false)
		pathfinding_map.set_point_weight_scale(Splot.origin_splot.navigation_id, t)					# Reestablecer el INF
		return m
		
	pathfinding_map.set_point_weight_scale(Splot.origin_splot.navigation_id, t)						# Reestablecer el INF
	return PackedVector3Array()
