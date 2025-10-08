extends Node

signal phase_changed(new_phase)

enum Phase { CHECK_IN, EXPLORE, DELIVERY }

@onready var audio: Node = $AudioManager
@onready var events: Node = $EventManager
@onready var tasks: Node = $TaskManager
@onready var inventory: Node = $InventoryManager
@onready var ui_layer: CanvasLayer = $UILayer

var current_phase: Phase = Phase.CHECK_IN
var day:int = 1
var hotel_rating: float = 3.0 # 1–5 for end screen

func _ready() -> void:
	# Boot splash: load Lobby and start check-in music
	_change_phase(Phase.CHECK_IN)
	audio.play_bgm("lobby")


func _process(delta: float) -> void:
	# Optional global hotkeys for jam debugging
	if Input.is_action_just_pressed("ui_page_up"):
		_next_phase()
	elif Input.is_action_just_pressed("ui_page_down"):
		_prev_phase()


func _next_phase() -> void:
	var next := (int(current_phase) + 1) % Phase.size()
	_change_phase(next)


func _prev_phase() -> void:
	var prev := int(current_phase) - 1
	if prev < 0:
		prev = Phase.size() - 1
		_change_phase(prev)


func _change_phase(new_phase: int) -> void:
	current_phase = new_phase
	emit_signal("phase_changed", current_phase)
	match current_phase:
		Phase.CHECK_IN:
			audio.play_bgm("lobby")
			# Spawn 2–3 random monsters with needs
			events.seed_check_in_day(day)
			ui_layer.get_node("HUD").set_phase_name("Check-In")
		Phase.EXPLORE:
			audio.play_bgm("night")
			events.roll_random_events()
			ui_layer.get_node("HUD").set_phase_name("Explore")
		Phase.DELIVERY:
			audio.play_bgm("panic")
			ui_layer.get_node("HUD").set_phase_name("Delivery")


func end_day() -> void:
	# Simple end-of-day scoring
	hotel_rating = clampf(hotel_rating + tasks.get_daily_delta(), 1.0, 5.0)
	day += 1
	_change_phase(Phase.CHECK_IN)
