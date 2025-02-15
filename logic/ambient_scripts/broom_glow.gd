extends MeshInstance3D

# Mop outline properties
var outline_on : bool = false
var outline_overlay : Material = preload("res://logic/ambient_scripts/postprocessing_items/outline_material_mop.tres")
var temp: StandardMaterial3D


# Mop head properties
var material_for_override : StandardMaterial3D
@export var glow_limit : float = 15

func _ready() -> void:
	GlobalInfo.jugador_trapea.connect(alter_glow)
	GlobalInfo.trapero_limpiado.connect(alter_glow.bind(0))

func alter_glow(s : float) -> void:
	#temp = get_active_material(2)#
	#print(temp.resource_name)
#
	##print(get_surface_override_material_count())
	#temp.emission_energy_multiplier = lerpf(0, glow_limit, s**2)
	#set_surface_override_material(2, temp)
	get_surface_override_material(2).emission_energy_multiplier = lerpf(0, glow_limit, s**2)
	
func activate_outline() -> void:
	material_overlay = outline_overlay
	outline_on = true

func deactivate_outline() -> void:
	material_overlay = null
	outline_on = false
