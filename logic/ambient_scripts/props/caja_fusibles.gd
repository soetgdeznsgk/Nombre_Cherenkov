extends StaticBody3D

@export var ref_cables : MeshInstance3D
@onready var blue_outline : StandardMaterial3D = preload("res://logic/ambient_scripts/postprocessing_items/bucket_lever_material.tres")
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

signal player_fixed_cables

func _ready() -> void:
	is_active = false

func activate_fusebox()-> void:
	emisor_chispas_constantes.emitting = true
	emisor_chispoteo.emitting = true
	
func deactivate_fusebox() -> void:
	emisor_chispas_constantes.emitting = false
	emisor_chispoteo.emitting = false
	#GlobalInfo.reset_lights()
	
func squid_interaction(p : Pulpo) -> bool:
	if is_active:
		return false
	
	is_active = true
	light_flicker_coroutine(p)
	return true

func player_interaction() -> void:
	if GlobalInfo.timerInteractionBuffer.is_stopped():
		player_fixes_cables()
		#is_active = false

func light_flicker_coroutine(p) -> void:
	GlobalInfo.force_lights_flickering()
	if p is Pulpo:
		await p.tearing_shit_state_exited
		GlobalInfo.shut_down_lights()
	else:										# es llamada por jugador
		print("esperando fin de arreglo de cables")
		await player_fixed_cables
		print("sacabaron los cables")
		GlobalInfo.reset_lights()
	

func player_fixes_cables() -> void:
	light_flicker_coroutine(0)
	# lógica de arreglar cables
	await get_tree().create_timer(3).timeout # debug
	is_active = false
	player_fixed_cables.emit()

#region Outline

func enter_player_focus() -> void:
	if ref_cables.material_overlay == null:
		ref_cables.material_overlay = blue_outline
	#pass

func exit_player_focus() -> void:
	ref_cables.material_overlay = null
	
#endregion
