extends Control
class_name UI

@onready var mop_saturation_bar := $ProgressBar
@onready var aviso_atrapamiento := $Aviso_Atrapado
@onready var contamination_bar := $GlobalContaminationBar

#region Styleboxes
@onready var style_blue : StyleBoxFlat = preload("res://logic/UI/styleboxes/blue_stylebox.tres")
@onready var style_red : StyleBoxFlat = preload("res://logic/UI/styleboxes/red_stylebox.tres")
#endregion

func _ready() -> void:
	#mop_saturation_bar.modulate(Color.AQUA)
	pass

func update_saturation_bar(val: int) -> void:
	mop_saturation_bar.value = val
	if mop_saturation_bar.max_value == val:
		mop_saturation_bar.add_theme_stylebox_override("fill", style_red)
		
	elif val == 0:
		mop_saturation_bar.add_theme_stylebox_override("fill", style_blue)

func update_contamination_bar(delta: float) -> void:
	contamination_bar.value += delta
	

func reset_healty_status() -> void:
	aviso_atrapamiento.visible = false
	
func show_entrapment_inflicted_sign() -> void:
	aviso_atrapamiento.visible = true
