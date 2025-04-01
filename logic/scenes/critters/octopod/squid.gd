extends Area3D
class_name Pulpo
# Éste pulpo, a diferencia de la rana, no utilizará el nodo NavigationRegion, puesto que no toda la superficie
# le está disponible, por el contrario, se moverá con fre

@export var current_state : int
var target_retriever : Callable
var origin : Vector3

enum states {
	Idle, # ko
	Pursuing, # pursuing será también utilizado para la rutina de escape al ser golpeados
	ReachingOut,
	Grabbing,
	TearingShitApart
}

enum targets {
	FuseBox,
	Player
}

# Variables de persecución
var current_target
var current_path : PackedVector3Array 
@export_category("Persecución")
@export var crawl_speed : float
var escaping : bool = false

# Variables de reaching
@export_category("Reaching Out")
@export var reaching_state_duration : float

# Variables de agarre
@export_category("Agarre")
@onready var arm_span : CollisionShape3D = $arm_span/CollisionShape3D
@export var health : int = 3:
	set(v):
		if v <= 0:
			enter_idle_state()
			target_retriever = NavegacionPulpo.get_escape_path.bind(self)
			escaping = true
			health = 0
		else:
			health = v

# Variables idle
@export_category("Idle")
@export var idle_state_duration : float

signal tearing_shit_state_exited


@onready var anim_player : AnimationPlayer = $AnimationPlayer

#func set_origin() -> void: # CONSTRUCTOR
	#origin = position


func _ready() -> void:
	choose_target(targets.Player)#targets.values().pick_random())
	origin = Splot.origin_splot.global_position
	enter_reaching_state()
	escaping = false
	#enter_pursuing_state()
	
func choose_target(new_target : int) -> void:
	current_target = new_target
	match current_target:
		targets.FuseBox:
			var caja_fusible = get_tree().get_nodes_in_group("CajasFusibles").pick_random()
			print(caja_fusible)
			target_retriever = NavegacionPulpo.get_pulpo_path_from_point.bind(self, caja_fusible)
		targets.Player:
			target_retriever = NavegacionPulpo.get_pulpo_path_from_point.bind(self, GlobalInfo.refPlayer)

func _physics_process(delta: float) -> void:
	look_at(GeometricToolbox.y_offset_vector_to_0(GlobalInfo.playerPosition))
	match current_state:
		states.ReachingOut:
			reaching_pp(delta)
		states.Pursuing:				# cuando se queda vibrando, está en pursuing
			pursuing_pp(delta)
		states.Grabbing:
			grabbing_pp(delta)
		
		

#region State physics_process + enter/exit

# PERSECUSIÓN

func pursuing_pp(delta: float) -> void:
	if not current_path.is_empty():
		if position.distance_squared_to(current_path[0]) < 0.6: 
			# la transición al otro estado puede ser cuando esté más cerca al jugador que al charco?
			current_path.remove_at(0)
			if current_path.is_empty():
				assign_path(target_retriever)
				return
		
		position += (current_path[0] - position).normalized() * crawl_speed * delta # BUG cuando no hay charcos, BUG cuando es una distancia muy cercana
		if not escaping and position.distance_to(GlobalInfo.playerPosition) < position.distance_to(current_path[0]):
			enter_reaching_state()
	else:
		assign_path(target_retriever)

func enter_pursuing_state() -> void:
	current_state = states.Pursuing
	anim_player.play("Pursuing")
	#print("current target : ", current_target, " y target retriever : ", target_retriever.get_object().name)
	assign_path(target_retriever)
	#print("entra a pursuing")

# EXTENSIÓN DE BRAZOS

func reaching_pp(_delta: float) -> void:
	pass
	
func enter_reaching_state() -> void:
	$"Reaching State Timer".start(reaching_state_duration) # timeout está conectado a enter_pursuing
	anim_player.play("Reaching Out")
	current_state = states.ReachingOut
	call_deferred("change_arm_monitoring_state", false)
	#print("entra a reaching")

# AGARRE DE JUGADOR

func grabbing_pp(_delta : float) -> void:
	pass

func enter_grabbing_state() -> void:
	#$"Grabbing State Timer".start(grabbing_state_duration)
	call_deferred("change_arm_monitoring_state", true)
	current_state = states.Grabbing
	anim_player.play("Grabbing")
	
# IDLE

func idle_pp(_delta: float) -> void:
	pass

func enter_idle_state() -> void:
	$"Idle State Timer".start()
	current_state = states.Idle
	# anim
	GlobalInfo.squid_leaves_player()
	
# TEARING SHIT APART

func tearing_shit_pp(_delta: float) -> void:
	pass

func enter_tearing_shit_state() -> void:
	current_state = states.TearingShitApart
	$"Tearing State Timer".start()
	#GlobalInfo.force_lights_flickering()
	
	await $"Tearing State Timer".timeout
	
	#GlobalInfo.shut_down_lights()
	choose_target(targets.Player)
	tearing_shit_state_exited.emit()
	enter_pursuing_state()
#endregion

#region Magia con los colliders


func _on_area_entered(area: Area3D) -> void:
	#if area.is_in_group("Trapero"):
		#health -= 1
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Baldes"):
		tumble_bucket(body)
	elif body.is_in_group("CajasFusibles"):		# Puede que esto tenga que cambiarse, si tengo que cambiarle el tipo a la caja de fusibles
		# también puede hacerse más general con un "has_method(squid_interaction)"
		if body.squid_interaction(self):			# osea, si el pulpo puede interactuar con la caja
			enter_tearing_shit_state()

func _on_body_exited(body: Node3D) -> void: # DEBUG
	#if body.is_in_group("Jugador"):
		#GlobalInfo.squid_leaves_player()
	pass


func _on_arm_span_body_entered(body: Node3D) -> void:
	if body.is_in_group("Jugador"):
		force_stop_state_timers()
		enter_grabbing_state()
		GlobalInfo.squid_hugs_player(position)
	elif body.is_in_group("Baldes"):
		tumble_bucket(body)


func _on_arm_span_body_exited(body: Node3D) -> void:
	if body.is_in_group("Jugador"):	# TODO arreglar ésta función para que, alejándose del pulpo, se pueda escapar
		#print("jugador exita brazos")
		#GlobalInfo.squid_leaves_player()
		pass

func player_interaction() -> void:
	if GlobalInfo.timerInteractionBuffer.is_stopped() and GlobalInfo.refTrapero.anim_state != GlobalInfo.refTrapero.states.Stowed:
		#print("squid lee interaction")
		health -= 1

#endregion

func assign_path(Origen : Callable) -> void: # estar seguro de que SIEMPRE haya por lo menos un charco 
	current_path = Origen.call()
	#if not movement_permission:
		#NavegacionPulpo.splot_map_updated.disconnect(assign_path)
	#movement_permission = true

func force_stop_state_timers() -> void:
	for timer in get_tree().get_nodes_in_group("TimersPulpo"):
		timer.stop()

func change_arm_monitoring_state(b : bool) -> void:
	arm_span.disabled = b
	
func tumble_bucket(balde: Balde) -> void:
	balde.fall_from_collision_in(global_position)

func pop_squid() -> void:
	queue_free()
