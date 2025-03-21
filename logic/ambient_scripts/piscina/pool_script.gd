extends CSGCylinder3D
class_name Pool
# Éste script tendrá que spawnear a los enemigos, para el prototipo, sólo se tiene 

@onready var rana_ref := preload("res://logic/scenes/critters/amphibean/rana.tscn")
@onready var pulpo_ref := preload("res://logic/scenes/critters/octopod/squid.tscn")
@export var first_frog_target : Node3D


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

func _on_rana_spawner_timer_timeout() -> void:
	if get_tree().get_first_node_in_group("RanaManager").get_child_count() < 10:
		var rana = rana_ref.instantiate().with_target(first_frog_target)
		rana.position = global_position
		rana.position += (height) * Vector3.DOWN
		get_tree().get_first_node_in_group("RanaManager").add_child(rana)
		GlobalInfo.cantidad_ranas += 1
	else:
		pass


func _on_pulpo_spawner_timer_timeout() -> void: 
	# BUG en itch, al tener 3 ranas, cuando spawnea el tercer pulpo, la pantalla se va a blanco y el juego
	# sigue corriendo
	if get_tree().get_first_node_in_group("PulpoManager").get_child_count() < 4: #and GlobalInfo.cantidad_ranas > 1:
		var pulpo : Pulpo = pulpo_ref.instantiate()#.set_origin(global_position)
		pulpo.position = global_position
		pulpo.set_origin()
		get_tree().get_first_node_in_group("PulpoManager").add_child(pulpo)
		GlobalInfo.cantidad_pulpos += 1

func get_center() -> Vector3:
	return global_position
