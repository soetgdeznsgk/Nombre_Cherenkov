extends Node3D

@onready var holes_ref := preload("res://logic/scenes/splot_hole.tscn")
var fatherTransformation : Transform3D
# Para los huecos, TODO es implementar una respuesta a 

func _set_geometric_info(t : Transform3D) -> void:
	fatherTransformation = t
	
func _ready() -> void:
	transform = transform.rotated_local(Vector3.UP, randf() * 4) 
	GlobalInfo.jugador_trapea.connect(spawn_hole)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("MoveBackwards"):
		spawn_hole(position)

func spawn_hole(v: Vector3) -> void:
	v = GeometricToolbox.y_offset_vector_to_0(v)
	var hole := holes_ref.instantiate()
	hole.position = fatherTransformation * transform.affine_inverse() * v # TODO no está apareciendo donde debe, arreglar
	print(position.distance_to(v))
	$MeshInstance3D.add_child(hole)
	
