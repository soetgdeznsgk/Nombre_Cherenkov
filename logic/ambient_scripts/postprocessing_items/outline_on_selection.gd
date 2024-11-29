extends MeshInstance3D

var outline_on : bool = false

var overlay : Material = preload("res://logic/ambient_scripts/postprocessing_items/outline_material.tres")

func activate_outline() -> void:
	if not outline_on:
		material_overlay = overlay
	outline_on = true
	
func deactivate_outline() -> void:
	if outline_on:
		material_overlay = null
	outline_on = false
