extends MeshInstance3D
# Éste script funciona para todos los elementos de geometría del escenario que sirvan como 
# pisos válidos para charcos

@onready var splot_ref := preload("res://logic/scenes/splot.tscn")

# me costó intentar lo que hace esta función, pero aquí va:
#	como el escenario es suceptible a ser escalado, para spawnear manchas como hijas del piso
#	se necesita transformar las coordenadas globales (que son lo que recibirá de input la función spawn_splot)
#	a coordenadas locales, ésta matriz lo que hace es encontrar la posición relativa de 
@onready var adjustmentMatrix : Transform3D = transform.affine_inverse()  



func _ready() -> void:
	GlobalInfo.rana_impacta.connect(spawn_splot)
	
func spawn_splot(v : Vector3) -> void:
	var nsplot : Node3D = splot_ref.instantiate()
	nsplot.position = v * adjustmentMatrix
	nsplot.position.y += 0.6 # para evitar montonera, hay que implementar una rutina de sobreposición en splot.tscn
	add_child(nsplot)
	
	
