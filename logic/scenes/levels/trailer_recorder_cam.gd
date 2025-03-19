extends Camera3D
# TODO darle movimiento a la camara del trailer?

# Called when the node enters the scene tree for the first time.

func _init() -> void:
	queue_free()
	pass
	
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	if Input.is_key_label_pressed(KEY_C):
		if not current:
			make_current()
		else:
			clear_current()
	if Input.is_key_label_pressed(KEY_P):
		$AnimationPlayer.play("TravellingAntecámara")
		pass
