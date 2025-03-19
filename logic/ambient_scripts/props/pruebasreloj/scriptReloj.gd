extends Node3D
class_name InGameClock

@export var horas_decena: Array[MeshInstance3D]
@export var horas_unidad: Array[MeshInstance3D]
@export var minutos_decena: Array[MeshInstance3D]
@export var minutos_unidad: Array[MeshInstance3D]
@export var segundos_decena: Array[MeshInstance3D]
@export var segundos_unidad: Array[MeshInstance3D]

# Multiplicador de velocidad: x1 = tiempo real, x60 = tiempo ingame
static var escala_de_tiempo: float = 1 
static var hora_inicial : Vector3i = Vector3i(0,58,0) 	# para que empiece a las 12:58

var tiempo_simulado : float = 0.0

func _ready() -> void:
	tiempo_simulado += (hora_inicial.x * 3600) + (hora_inicial.y * 60) + (hora_inicial.z)
	actualizar_reloj()

func start() -> void:
	escala_de_tiempo = 60

func actualizar_reloj() -> void:	
	var tiempo_transcurrido_en_segundos = int(tiempo_simulado)
	
	var segundos : int = (tiempo_transcurrido_en_segundos % 60)
	var minutos : int = ((tiempo_transcurrido_en_segundos / 60) % 60)
	var horas : int = ((tiempo_transcurrido_en_segundos / 3600) % 24)
	
	# Actualizar los dígitos de las horas
	actualizar_digitos(horas_decena, horas / 10)
	actualizar_digitos(horas_unidad, horas % 10)

	# Actualizar los dígitos de los minutos
	actualizar_digitos(minutos_decena, minutos / 10)
	actualizar_digitos(minutos_unidad, minutos % 10)

	# Actualizar los dígitos de los segundos
	actualizar_digitos(segundos_decena, segundos / 10)
	actualizar_digitos(segundos_unidad, segundos % 10)

func actualizar_digitos(digitos: Array[MeshInstance3D], valor: int):
	# Desactivar todos los dígitos
	for digito in digitos:
		digito.visible = false

	# Activar el dígito correspondiente al valor
	if valor >= 0 and valor < digitos.size():
		digitos[valor].visible = true

func _process(delta):
	tiempo_simulado += delta * escala_de_tiempo
	
	# Actualizar el reloj cada segundo SIMULADO
	if int(tiempo_simulado) % 1 == 0:
		actualizar_reloj()
