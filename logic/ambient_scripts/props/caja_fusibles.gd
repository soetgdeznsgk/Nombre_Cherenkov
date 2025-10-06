extends StaticBody3D

@export var ref_cables : MeshInstance3D
@onready var blue_outline : StandardMaterial3D = preload("res://logic/ambient_scripts/postprocessing_items/bucket_lever_material.tres")

@export_category("Partículas")
@export var emisor_chispas_constantes : GPUParticles3D
@export var emisor_chispoteo : GPUParticles3D 
@export var particle_amount : int 
@export_category("SFX")
@export var BUZZING_VOLUME : int = 5

@onready var interaction_prompt : Sprite3D = $Tooltip

@export var is_active : bool: # este setter es para alterarlo desde el editor GRACIAS POR EL COMENTARIO EMILIANO DEL PASADO
	set(v):
		if v:
			#print("se activa ", name)
			activate_fusebox()
		else:
			#print("se desactiva ", name)
			deactivate_fusebox()
		
		is_active = v
		$TutoTooltip.visible = v

signal player_fixed_cables

func _ready() -> void:
	$TutoTooltip/AnimationPlayer.play("new_animation")
	is_active = false

func activate_fusebox()-> void:
	emisor_chispas_constantes.emitting = true
	emisor_chispoteo.emitting = true
	
func deactivate_fusebox() -> void:
	emisor_chispas_constantes.emitting = false
	emisor_chispoteo.emitting = false
	#GlobalInfo.reset_lights()
	
func squid_interaction(p : Pulpo) -> bool:
	if GlobalInfo.power_outage or p.health == 0:
		return false
	
	$Zumbido.play()
	#start_buzzing_sfx()
	light_flicker_coroutine(p)
	is_active = true
	return true

func player_interaction() -> void:
	if GlobalInfo.timerInteractionBuffer.is_stopped():
		player_fixes_cables()
		#is_active = false

func light_flicker_coroutine(p) -> void:
	GlobalInfo.force_lights_flickering()
	if p is Pulpo:
		await p.tearing_shit_state_exited
		GlobalInfo.mute_alarm_sound(5)
		$Zumbido.stop()
		$ShutDownSFX.play()
		GlobalInfo.shut_down_lights()
		GlobalInfo.power_outage = true
	else:										# es llamada por jugador
		# dar más "juice"
		await player_fixed_cables
		GlobalInfo.reset_lights()
		GlobalInfo.unmute_alarm_sound()
	

func player_fixes_cables() -> void:
	light_flicker_coroutine(0)
	$Zumbido.stop()
	# lógica de arreglar cables
	await get_tree().create_timer(3).timeout # debug
	is_active = false
	player_fixed_cables.emit()

#region Outline

func enter_player_focus() -> void:
	if is_active:
		if ref_cables.material_overlay == null:
			ref_cables.material_overlay = blue_outline
		if not interaction_prompt.visible:
			interaction_prompt.visible = true
	#pass

func exit_player_focus() -> void:
	ref_cables.material_overlay = null
	if interaction_prompt.visible:
		interaction_prompt.visible = false
	
func define_appropiate_gamepad_tooltip(control : bool) -> void:
	if control:
		interaction_prompt.texture = load("res://modelos/textures/sprites/xbox_rt.png")
	else:
		interaction_prompt.texture = load("res://modelos/textures/sprites/left-click.png")
#endregion

func start_buzzing_sfx() -> void:
	$Zumbido.play() # encontrar una manera de lerpearlo para que no tape al SHUTDOWNSFX
	##if not $Zumbido.playing:
		##$Zumbido.play()
		#
	#if $Zumbido.volume_db >= BUZZING_VOLUME:
		#return
	#
	#$Zumbido.volume_db += 3
	#await get_tree().process_frame
	#start_buzzing_sfx()

#func _process(delta: float) -> void:
	#if is_active:
		#print($Zumbido.volume_db)
