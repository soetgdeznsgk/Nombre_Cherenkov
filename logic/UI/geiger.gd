extends Node3D

# lo admito, esto lo hizo la IA >:(

@export_range(0, 1) var intensity: float = 0.0:
	set(value):
		intensity = clamp(value, 0.0, 1.0)

@export var min_wait: float = 0.05    # Fastest click interval
@export var max_wait: float = 2.0     # Slowest click interval
@export var randomness: float = 0.2   # Timing variation (0-1)

@export var _players: Array[SpatialAudioPlayer3D]

@onready var timer: Timer = $ClickTimer

func start() -> void:
	timer.start()

func start_next_click():
	# Calculate interval with intensity and randomness
	var actual_interval = lerp(max_wait, min_wait, intensity) * randf_range(1.0 - randomness, 1.0 + randomness)
	
	timer.wait_time = actual_interval
	timer.start()

	_players.pick_random().play()

func _on_click_timer_timeout():
	if not GlobalInfo.winning_secuence:
		start_next_click()
