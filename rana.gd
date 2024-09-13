extends Area3D

@onready var navRef : NavigationAgent3D = $NavigationAgent3D
var direction : Vector3
var velocity := 0.01

func _process(delta: float) -> void:
	navRef.target_position = GlobalDB.playerPosition
	direction = navRef.get_next_path_position()
	position -= direction.normalized() * velocity
	
func jump() -> void:
	pass

func updateTarget() -> void:
	pass
