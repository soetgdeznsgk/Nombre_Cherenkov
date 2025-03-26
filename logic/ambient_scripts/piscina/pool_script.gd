extends CSGCylinder3D
class_name Pool
# Éste script tendrá que spawnear a los enemigos, para el prototipo, sólo se tiene 

@onready var rana_ref := preload("res://logic/scenes/critters/amphibean/rana.tscn")
@onready var pulpo_ref := preload("res://logic/scenes/critters/octopod/squid.tscn")
@export var first_frog_target : Node3D
@export var MAX_FROG_AMOUNT : int = 5
@export var MAX_SQUID_AMOUNT : int = 1


func _ready() -> void:
	#_on_rana_spawner_timer_timeout()
	#_on_pulpo_spawner_timer_timeout()
	pass

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Debug_Exec"):
		#_on_pulpo_spawner_timer_timeout()
	return
		
func start() -> void:
	$PulpoSpawnerTimer.start()
	$RanaSpawnerTimer.start()
	_on_rana_spawner_timer_timeout()

func _on_rana_spawner_timer_timeout() -> void:
	if get_tree().get_first_node_in_group("RanaManager").get_child_count() < MAX_FROG_AMOUNT:
		var rana = rana_ref.instantiate().with_target(first_frog_target)
		rana.position = global_position
		rana.position += (height) * Vector3.DOWN
		get_tree().get_first_node_in_group("RanaManager").add_child(rana)
		GlobalInfo.cantidad_ranas += 1


func _on_pulpo_spawner_timer_timeout() -> void: 
	# BUG en itch, al tener 3 ranas, cuando spawnea el tercer pulpo, la pantalla se va a blanco y el juego
	# sigue corriendo
	if get_tree().get_first_node_in_group("PulpoManager").get_child_count() < MAX_SQUID_AMOUNT: #and GlobalInfo.cantidad_ranas > 1:
		var pulpo : Pulpo = pulpo_ref.instantiate()#.set_origin(global_position)
		pulpo.position = global_position
		pulpo.set_origin()
		get_tree().get_first_node_in_group("PulpoManager").add_child(pulpo)
		GlobalInfo.cantidad_pulpos += 1

func get_center() -> Vector3:
	return global_position

func trigger_white_out() -> void:
	if $OmniLight3D.omni_attenuation <= -15:
		return
	
	for source in get_tree().get_nodes_in_group("BombillasApagables"):
		source.omni_attenuation -= 0.01
		GlobalInfo.reset_lights()
	$OmniLight3D.omni_attenuation -= 0.01
	
	await get_tree().process_frame
	trigger_white_out()
