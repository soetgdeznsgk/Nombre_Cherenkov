extends Node3D

var outline_on : bool = false
var overlay : Material = preload("res://logic/ambient_scripts/postprocessing_items/outline_material_mop.tres")

func activate_outline() -> void:
	for child in get_children():
		child.material_overlay = overlay
		#child.material_overlay.grow_amount = -0.1
	outline_on = true
	
func deactivate_outline() -> void:
	for child in get_children():
		child.material_overlay = null
	outline_on = false
