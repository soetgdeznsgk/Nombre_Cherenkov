extends StaticBody3D

@export var emisor_chispas_constantes : GPUParticles3D
@export var emisor_chispoteo : GPUParticles3D 
@export var particle_amount : int 
@export var is_active : bool = false: # este setter es para alterarlo desde el editor GRACIAS POR EL COMENTARIO EMILIANO DEL PASADO
	set(v):
		if v:
			activate_fusebox()
		else:
			deactivate_fusebox()

func activate_fusebox()-> void:
	print("se activa el fusebox ", name)
	emisor_chispas_constantes.emitting = true
	emisor_chispoteo.emitting = true
	
func deactivate_fusebox() -> void:
	emisor_chispas_constantes.emitting = false
	emisor_chispoteo.emitting = false
