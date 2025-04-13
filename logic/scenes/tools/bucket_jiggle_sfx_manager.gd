extends Node3D

@export var balde : Balde 
var b : bool = false

func _process(delta: float) -> void:
	if not b: return 					# workaround xq el balde no deja de vibrar apenas spawnea
	if balde.in_hud:
		$Ruedas.volume_db = linear_to_db(balde.position_delta.length_squared() * 16)
	else:								# prob eliminar angular_velocity de acá, ya que voltearse es otro sonido
		$Ruedas.volume_db = linear_to_db((balde.angular_velocity.length_squared() + balde.linear_velocity.length_squared()) / 2)

func _on_bucket_equipped() -> void:
	b = true
