extends MeshInstance3D

var material_for_override : StandardMaterial3D
@export var glow_limit : float = 0.5

func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(alter_glow)

func alter_glow(s : float) -> void:
	material_for_override = get_active_material(0)
	material_for_override.emission_energy_multiplier = lerpf(0, glow_limit, s)
	set_surface_override_material(0, material_for_override)
