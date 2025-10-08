extends Node


class_name EventManager


signal event_spawned(evt)

# Very light event structure for the jam
class HotelEvent:
	var id: String
	var target_room_id: int
	var mood_delta: int
	var duration: float
	var kind: String # "slime_leak", "power_outage", etc.


var rng := RandomNumberGenerator.new()
var active_events: Array[HotelEvent] = []
var rooms: Array[Node] = [] # Injected from scene


func seed_check_in_day(day:int) -> void:
	# Called at CHECK_IN: spawn monsters in some rooms (done by scene or GameManager)
	# Could bias tomorrow's random events based on guest mix.
	pass


func roll_random_events() -> void:
	# Create 1–2 small random events for EXPLORE phase
	if rooms.is_empty():
		return
	var evt := HotelEvent.new()
	evt.id = "E_%s" % str(Time.get_ticks_msec())
	evt.target_room_id = int(rng.randi_range(0, rooms.size()-1))
	evt.mood_delta = rng.randi_range(-10, -3)
	evt.duration = rng.randf_range(8.0, 16.0)
	evt.kind = "slime_leak"
	active_events.append(evt)
	emit_signal("event_spawned", evt)
	var room := rooms[evt.target_room_id]
	if room and room.has_method("trigger_event"):
		room.trigger_event(evt)


func clear_events() -> void:
	for e in active_events:
		var room := rooms[e.target_room_id]
		if room and room.has_method("resolve_event"):
			room.resolve_event(e)
	active_events.clear()
