extends Control
class_name UI

@onready var mop_saturation_bar := $SaturationBar
@onready var aviso_atrapamiento := $Aviso_Atrapado
@onready var contamination_bar := $GlobalContaminationBar
@onready var ost_player_ref : AudioStreamPlayer = $OST
static var aviso_pausa : Label 
static var aviso_despausa : Label 
static var objetivo_actual : Label

# Objetivos:
static var listaObjetivos : Array = ["Presiona el botón rojo", "Agarra el trapero", "Sobrevive hasta las 6 am!", "Exprime el trapero", "Sal del edificio!"]
static var punteroObjetivo : int = 0

#region Styleboxes
@onready var style_blue : StyleBoxFlat = preload("res://logic/UI/styleboxes/blue_stylebox.tres")
@onready var style_red : StyleBoxFlat = preload("res://logic/UI/styleboxes/red_stylebox.tres")
@onready var style_yellow : StyleBoxFlat = preload("res://logic/UI/styleboxes/yellow_stylebox.tres")
#endregion

func _ready() -> void:
	#mop_saturation_bar.modulate(Color.AQUA)
	aviso_pausa = $"../aviso_pausar"
	aviso_despausa = $"../aviso_despausar"
	objetivo_actual = $aviso_objetivo
	objetivo_actual.text = listaObjetivos[punteroObjetivo]
	
	await get_tree().process_frame
	
func start() -> void:
	ost_player_ref.play()

func define_appropiate_gamepad_tooltip(control : bool) -> void:
	if control:
		aviso_pausa.text = "Start para pausar"
		aviso_despausa.text = "Start para despausar"
	else:
		aviso_pausa.text = "ESC para pausar"
		aviso_despausa.text = "ESC para despausar"
	
	

func update_saturation_bar(val: float) -> void:
	mop_saturation_bar.value = val
	if mop_saturation_bar.max_value == val:
		mop_saturation_bar.add_theme_stylebox_override("fill", style_red)
		
	elif val == 0:
		mop_saturation_bar.add_theme_stylebox_override("fill", style_blue)

func update_contamination_bar(delta: float) -> void:
	contamination_bar.value += delta
	if contamination_bar.value < 30 and delta < 0:		# esta linea si hace bien su trabajo? o impide devolver la contaminación?
		contamination_bar.add_theme_stylebox_override("fill", style_blue)
	elif contamination_bar.value > 33 and 40 > contamination_bar.value:
		contamination_bar.add_theme_stylebox_override("fill", style_yellow)
	elif contamination_bar.value > 66:
		contamination_bar.add_theme_stylebox_override("fill", style_red)

func reset_healty_status() -> void:
	aviso_atrapamiento.visible = false
	
func show_entrapment_inflicted_sign() -> void:
	aviso_atrapamiento.visible = true
	
static func alternate_esc_enter() -> void: # PAUSA PARA LA BUILD DE ITCH
	aviso_pausa.visible = not aviso_pausa.visible
	aviso_despausa.visible = not aviso_despausa.visible
	#print(aviso_pausa.visible, " y ", aviso_despausa.visible)
	
static func trigger_next_order() -> void:
	punteroObjetivo += 1
	objetivo_actual.text = listaObjetivos[punteroObjetivo]
	
static func clean_mop_order_completed() -> void:
	punteroObjetivo = 2
	objetivo_actual.text = listaObjetivos[punteroObjetivo]

func win_state_sequence() -> void:
	# TODO hacer un fade in y out más bonito
	ost_player_ref.playing = false
	objetivo_actual.text = listaObjetivos[4]

func game_over_sequence() -> void:
	#ost_player_ref.playing = false
	$GameOverSFX.play(2)
