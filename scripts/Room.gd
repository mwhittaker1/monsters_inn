extends Node2D

class_name Room

@export var room_id: int = 0
@export var type_tag: String = "crypt" # crypt/swamp/lab/etc
@export var objects: Array[String] = ["coffin"]

var current_guest: GuestMonster = null
var cleanliness:int = 80
var active_events: Array = []

func assign_guest(monster:GuestMonster) -> void:
	current_guest = monster

func trigger_event(evt) -> void:
	active_events.append(evt)
	cleanliness = max(0, cleanliness - 10)

func resolve_event(evt) -> void:
	active_events.erase(evt)
	cleanliness = min(100, cleanliness + 5)

func vacate() -> void:
	current_guest = null
	cleanliness = max(50, cleanliness) # leave some mess
