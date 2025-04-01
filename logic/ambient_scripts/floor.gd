extends CSGMesh3D
class_name Floor
# Éste script funciona para todos los elementos de geometría del escenario que sirvan como 
# pisos válidos para charcos

@onready var splot_ref := preload("res://logic/ambient_scripts/puddles/splot.tscn")
@onready var adjustmentMatrix : Transform3D = transform.affine_inverse()  
static var splot_count : int = 0


func _ready() -> void:
	GlobalInfo.rana_impacta.connect(spawn_splot)
	
func spawn_splot(v : Vector3) -> void:
	var nsplot : Node3D = splot_ref.instantiate()
	#nsplot._set_geometric_info(transform)
	nsplot.position = (v * adjustmentMatrix)
	nsplot.position.y += 0.6 # para evitar montonera, hay que implementar una rutina de sobreposición en splot.tscn
	add_child(nsplot)
	#if splot_count == 0: nsplot.global_position.y = -2
	splot_count += 1
	
	
