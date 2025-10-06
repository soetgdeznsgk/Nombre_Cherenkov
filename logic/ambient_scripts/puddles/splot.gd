extends Area3D
class_name Splot

@onready var holes_ref := preload("res://logic/ambient_scripts/puddles/splot_hole.tscn")
var overlapping_splots : Array[Splot]

@export var maxHuecos := 10
@export var hueco_cooldown := 0.10

var navigation_id : int

static var origin_splot : Splot

var counter = 0 # DEBUG

func set_navigation_id(id : int) ->  void:
	navigation_id = id
	
func _ready() -> void:	
	rotate(Vector3.UP, randf() * 4)
	position += Vector3(randf() * 0.01, 0, randf() * 0.01)
	if Floor.splot_count == 0:
		global_position.y = -3
	await NavegacionPulpo.add_splot_to_registry(self)
	if Floor.splot_count == 0:
		origin_splot = self
		NavegacionPulpo.set_custom_splot_weight(navigation_id, INF)
		self.name = "Origin Splot"
		#print(global_position.y)

func spawn_hole(v: Vector3, size:Vector3) -> void:
	if $MeshInstance3D.get_child_count() < maxHuecos:
		if $Timer.is_stopped():
			GlobalInfo.change_in_mop_saturation()
			var hole : CSGMesh3D = holes_ref.instantiate()
			#hole.position = (fatherTransformation * transform).affine_inverse() * v
			#hole.custom_aabb.size.x = size.x TODO a implementar escalado del hueco con respecto a la forma intersecante 
			#hole.custom_aabb.size.y = size.z
			$MeshInstance3D.add_child(hole)
			hole.global_position = v
			hole.position.z = 0
			$Timer.start(hueco_cooldown)
			#propagate_holes(v, size)
		else:
			pass
	else:
		#eliminate_references_in_overlapping_splots()
		queue_free()
		NavegacionPulpo.rmv_splot_from_registry(self)
