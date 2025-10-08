extends Control

# Simple 1.5s splash then go to main menu
@export var hold_time: float = 1.5
var _timer := 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= hold_time or Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
