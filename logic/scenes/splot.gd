extends Node3D

@onready var holes_ref := preload("res://logic/scenes/splot_hole.tscn")
var fatherTransformation : Transform3D

@export var maxHuecos := 7
@export var hueco_cooldown := 0.3


func _set_geometric_info(t : Transform3D) -> void:
	fatherTransformation = t
	
func _ready() -> void:
	transform = transform.rotated_local(Vector3.FORWARD, randf() * 4)
	#GlobalInfo.jugador_trapea.connect(spawn_hole) no tiene sentido ya que el método es llamado desde el trapero
	
func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("MoveBackwards"): DEBUG
		#spawn_hole(position)
	pass

func spawn_hole(v: Vector3) -> void:
	if $MeshInstance3D.get_child_count() < maxHuecos:
		if $Timer.is_stopped():
			GlobalInfo.on_jugador_trapea() # con ésto, se puede actualizar el trapero cuando aparece un nuevo hueco
			v = GeometricToolbox.y_offset_vector_to_0(v)
			var hole := holes_ref.instantiate()
			hole.position = (fatherTransformation * transform).affine_inverse() * v
			hole.position.z = 0
			$MeshInstance3D.add_child(hole)
			$Timer.start(hueco_cooldown)
		else:
			pass
	else:
		queue_free()
	
