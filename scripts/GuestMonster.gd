extends Node2D

class_name GuestMonster

signal mood_changed(value)

@export var name_tag: String = "Mr. Fang"
@export var species: String = "Vampire"
@export var room_pref: String = "dark"
@export var special_needs: Array[String] = ["blood_bag", "cobweb_pillow"]
@export var event_modifiers: Array[String] = []

var mood: int = 60 # 0–100
var room_assigned: Node = null
var active_quests: Array[String] = []

func _ready() -> void:
	active_quests = special_needs.duplicate()


func assign_room(room:Node) -> void:
	room_assigned = room
	if room and room.has_method("assign_guest"):
		room.assign_guest(self)


func react_to_event(evt) -> void:
	# Basic mood hit
	mood = clamp(mood - 5, 0, 100)
	emit_signal("mood_changed", mood)


func deliver_item(item:String) -> void:
	if item in active_quests:
		active_quests.erase(item)
		mood = clamp(mood + 10, 0, 100)
		emit_signal("mood_changed", mood)


func is_satisfied() -> bool:
	return active_quests.is_empty()


func check_out() -> void:
	if room_assigned and room_assigned.has_method("vacate"):
		room_assigned.vacate()
	queue_free()
