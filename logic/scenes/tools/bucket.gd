extends VehicleBody3D

@onready var targetOnPlayer : Marker3D = $player_axis/Marker3D # para tener un objeto que sepa siempre donde está el jugador y visualizar un raycast

func _physics_process(_delta: float) -> void:
	#$x_axis.target_position = transform.basis.x
	#targetOnPlayer.global_position = GlobalInfo.playerPosition
	#$player_axis.target_position = GeometricToolbox.y_offset_vector_to_0(targetOnPlayer.position).normalized() * 2
	steering = get_rotation_needed_towards_player()
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)):
		engine_force = 300
	else:
		engine_force = 0
		
		
func get_rotation_needed_towards_player() -> float:
	var angle = transform.basis.x.signed_angle_to(GlobalInfo.playerPosition - position, Vector3.UP) # Frente del carrito
	#print(angle)
	return angle
	
func change_which_wheels_will_traction() -> void:
	pass #TODO averiguar como darle más estabilidad al carro para que no se caiga
	#$FrontR
	#$BackR
	#$FrontL
	#$BackL
