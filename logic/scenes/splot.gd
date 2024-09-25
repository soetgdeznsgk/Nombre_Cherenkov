extends Node3D

@onready var holes_ref := preload("res://logic/scenes/splot_hole.tscn")

func _ready() -> void:
	transform = transform.rotated_local(Vector3.UP, randf() * 4) 
	#TODO Ésta rotación va a ser un dolor de huevos en adelantel, recordar hacer 
	# la doble multiplicación de matrices para borrar exactamente la parte del charco
	
