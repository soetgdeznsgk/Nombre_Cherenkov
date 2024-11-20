extends Control
class_name UI

@onready var mop_saturation_bar := $SaturationBar
@onready var aviso_atrapamiento := $Aviso_Atrapado
@onready var contamination_bar := $GlobalContaminationBar

#region Styleboxes
@onready var style_blue : StyleBoxFlat = preload("res://logic/UI/styleboxes/blue_stylebox.tres")
@onready var style_red : StyleBoxFlat = preload("res://logic/UI/styleboxes/red_stylebox.tres")
@onready var style_yellow : StyleBoxFlat = preload("res://logic/UI/styleboxes/yellow_stylebox.tres")
#endregion

func _ready() -> void:
	#mop_saturation_bar.modulate(Color.AQUA)
	pass

func update_saturation_bar(val: float) -> void:
	mop_saturation_bar.value = val
	if mop_saturation_bar.max_value == val:
		mop_saturation_bar.add_theme_stylebox_override("fill", style_red)
		
	elif val == 0:
		mop_saturation_bar.add_theme_stylebox_override("fill", style_blue)

func update_contamination_bar(delta: float) -> void:
	contamination_bar.value += delta
	if contamination_bar.value < 30 and delta < 0:
		contamination_bar.add_theme_stylebox_override("fill", style_blue)
	elif contamination_bar.value > 33 and 40 > contamination_bar.value:
		contamination_bar.add_theme_stylebox_override("fill", style_yellow)
	elif contamination_bar.value > 66:
		contamination_bar.add_theme_stylebox_override("fill", style_red)

func reset_healty_status() -> void:
	aviso_atrapamiento.visible = false
	
func show_entrapment_inflicted_sign() -> void:
	aviso_atrapamiento.visible = true
	
func alternate_esc_enter() -> void: # PAUSA PARA LA BUILD DE ITCH
	$"../aviso_esc".visible = not $"../aviso_esc".visible
	$"../aviso_enter".visible = not 	$"../aviso_enter".visible
	#print("esc: ", $"../aviso_esc".visible, "enter: ", $"../aviso_enter".visible)

func disappear_main_sign() -> void:
	$"../aviso_inicio".visible = false
	$"../aviso_esc".visible = true
