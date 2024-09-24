extends Node
class_name Geometric_toolbox # convertir ésto en una clase global, pero no sé si se puede en gdscript jeje
	
	
func y_offset_vector_to_0(v : Vector3) -> Vector3:
	return v - (Vector3.UP * v.y)
