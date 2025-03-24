extends StaticBody3D

@export var emisor_chispas_constantes : GPUParticles3D
@export var emisor_chispoteo : GPUParticles3D 
@export var particle_amount : int 
@export var is_active : bool: # este setter es para alterarlo desde el editor GRACIAS POR EL COMENTARIO EMILIANO DEL PASADO
	set(v):
		if v:
			#print("se activa ", name)
			activate_fusebox()
		else:
			#print("se desactiva ", name)
			deactivate_fusebox()
			
		is_active = v

func _ready() -> void:
	is_active = false

func activate_fusebox()-> void:
	emisor_chispas_constantes.emitting = true
	emisor_chispoteo.emitting = true
	
func deactivate_fusebox() -> void:
	emisor_chispas_constantes.emitting = false
	emisor_chispoteo.emitting = false
	
func squid_interaction() -> bool:
	if is_active:
		return false
	
	is_active = true
	return true
