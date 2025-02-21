extends Camera3D

# Velocidad de movimiento
@export var velocidad_movimiento: float = 5.0

func _process(delta):
	# Movimiento con teclas WASD
	var movimiento = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):  # Mover hacia adelante
		movimiento.z -= 1
	if Input.is_action_pressed("ui_down"):  # Mover hacia atrás
		movimiento.z += 1
	if Input.is_action_pressed("ui_left"):  # Mover hacia la izquierda
		movimiento.x -= 1
	if Input.is_action_pressed("ui_right"):  # Mover hacia la derecha
		movimiento.x += 1
	if Input.is_action_pressed("ui_page_up"):  # Mover hacia arriba
		movimiento.y += 1
	if Input.is_action_pressed("ui_page_down"):  # Mover hacia abajo
		movimiento.y -= 1

	# Normalizar la dirección y aplicar la velocidad
	movimiento = movimiento.normalized() * velocidad_movimiento * delta

	# Aplicar el movimiento a la cámara
	translate(movimiento)
