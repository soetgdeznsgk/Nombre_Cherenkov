extends Node3D
class_name Contamination_Ingame_Bar

@onready var contamination_bar : ProgressBar = $SubViewport/Control/GlobalContaminationBar
@onready var texture_sprite : MeshInstance3D = $MeshInstance3D
#region Styleboxes
@onready var style_blue : StyleBoxFlat = preload("res://logic/UI/styleboxes/blue_stylebox.tres")
@onready var style_red : StyleBoxFlat = preload("res://logic/UI/styleboxes/red_stylebox.tres")
@onready var style_yellow : StyleBoxFlat = preload("res://logic/UI/styleboxes/yellow_stylebox.tres")
#endregion
var tmp : ORMMaterial3D

func update_contamination_bar(delta: float) -> void:
	contamination_bar.value += delta
	if contamination_bar.value < 30 and delta < 0:
		color_change(style_blue)
		
	elif contamination_bar.value > 33 and 40 > contamination_bar.value:
		color_change(style_yellow)
		
	elif contamination_bar.value > 66: #and 71 > contamination_bar.value:
		color_change(style_red)
	
	if contamination_bar.value >= 100:
		await get_tree().create_timer(5).timeout
		GlobalInfo.trigger_loss_state()
		
	GlobalInfo.refPlayer.update_geiger(contamination_bar.value / 100)

func get_contamination_value() -> float:
	return contamination_bar.value
	
func color_change(s : StyleBox) -> void:
	contamination_bar.add_theme_stylebox_override("fill", s)
	#tmp = texture_sprite.get_active_material(0)
	#tmp.emission = s.bg_color
	#texture_sprite.set_surface_override_material(0, tmp)
