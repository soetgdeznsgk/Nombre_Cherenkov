extends Node3D

@export var emisor_chispas_constantes : GPUParticles3D
@export var emisor_chispoteo : GPUParticles3D 
@export var particle_amount : int 
@export var is_active : bool = false: # este setter es para alterarlo desde el editor
	set(v):
		if v:
			activate_fuse_box()
		else:
			deactivate_fuse_box()

func activate_fuse_box()-> void:
	emisor_chispas_constantes.emitting = true
	emisor_chispoteo.emitting = true
	
func deactivate_fuse_box() -> void:
	emisor_chispas_constantes.emitting = false
	emisor_chispoteo.emitting = false
