extends CSGBox3D

# Éste script tendrá que spawnear a los enemigos, para el prototipo, sólo se tiene 

@onready var rana_ref := preload("res://logic/scenes/rana.tscn")
@export var first_frog_target : Node3D

func _ready() -> void:
	_on_rana_spawner_timer_timeout()

func _on_rana_spawner_timer_timeout() -> void:
	if get_tree().get_first_node_in_group("RanaManager").get_child_count() < 4:
		var rana = rana_ref.instantiate().with_target(first_frog_target)
		rana.position = global_position
		rana.position += (size.y) * Vector3.DOWN
		get_tree().get_first_node_in_group("RanaManager").add_child(rana)
	else:
		pass
