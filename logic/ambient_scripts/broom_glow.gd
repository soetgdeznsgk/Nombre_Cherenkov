extends MeshInstance3D

var material_for_override : StandardMaterial3D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("MoveL"): # Falta cambiar el trigger para que utilice el resto de señales del trapero
		material_for_override = get_active_material(0)
		material_for_override.emission_energy_multiplier += 0.1
		set_surface_override_material(0, material_for_override)
