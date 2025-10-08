extends Node

signal phase_changed(new_phase)
enum Phase { CHECK_IN, EXPLORE, DELIVERY }

@onready var ui_layer: CanvasLayer = $UILayer  # (this IS a scene node)

var current_phase: Phase = Phase.CHECK_IN
var day: int = 1
var hotel_rating: float = 3.0

func _ready() -> void:
	_change_phase(Phase.CHECK_IN)
	# Start music via autoload singleton
	if AudioManager:
		AudioManager.play_bgm("lobby")
	else:
		push_error("AudioManager autoload missing or misnamed")

func _process(delta: float) -> void:
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
	_change_phase(prev)  # <- moved outside the if

func _change_phase(new_phase: int) -> void:
	current_phase = new_phase
	emit_signal("phase_changed", current_phase)
	match current_phase:
		Phase.CHECK_IN:
			AudioManager?.play_bgm("lobby")
			EventManager?.seed_check_in_day(day)
			ui_layer.get_node("HUD").set_phase_name("Check-In")
		Phase.EXPLORE:
			AudioManager?.play_bgm("night")
			EventManager?.roll_random_events()
			ui_layer.get_node("HUD").set_phase_name("Explore")
		Phase.DELIVERY:
			AudioManager?.play_bgm("panic")
			ui_layer.get_node("HUD").set_phase_name("Delivery")

func end_day() -> void:
	hotel_rating = clampf(hotel_rating + TaskManager.get_daily_delta(), 1.0, 5.0)
	day += 1
	_change_phase(Phase.CHECK_IN)
