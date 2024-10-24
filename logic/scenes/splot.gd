extends Area3D
class_name Splot

@onready var holes_ref := preload("res://logic/scenes/splot_hole.tscn")
var fatherTransformation : Transform3D

@export var maxHuecos := 10
@export var hueco_cooldown := 0.15

var navigation_id : int


func set_navigation_id(id : int) ->  void:
	navigation_id = id

func _set_geometric_info(t : Transform3D) -> void:
	fatherTransformation = t
	
func _ready() -> void:
	#transform = transform.rotated_local(Vector3.FORWARD, randf() * 4)
	rotate(Vector3.UP, randf() * 4)
	position += Vector3(randf() * 0.01, 0, randf() * 0.01)
	NavegacionPulpo.add_splot_to_registry(self)
	#GlobalInfo.jugador_trapea.connect(spawn_hole) no tiene sentido ya que el método es llamado desde el trapero

func spawn_hole(v: Vector3, size:Vector3) -> void:
	if $MeshInstance3D.get_child_count() < maxHuecos:
		if $Timer.is_stopped():
			GlobalInfo.on_jugador_trapea()
			var hole : CSGMesh3D = holes_ref.instantiate()
			#hole.position = (fatherTransformation * transform).affine_inverse() * v
			
			hole.custom_aabb.size.x = size.x 
			hole.custom_aabb.size.y = size.z
			$MeshInstance3D.add_child(hole)
			hole.global_position = v
			hole.position.z = 0
			$Timer.start(hueco_cooldown)
		else:
			pass
	else:
		queue_free()
		NavegacionPulpo.rmv_splot_from_registry(self)
	
