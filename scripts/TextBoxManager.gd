extends Control

# Expects a Label child at $Panel/Text
@onready var text_label: Label = $Panel/Text
var queue: Array[String] = []
var typing: bool = false
var idx:int = 0

func say(lines:Array[String]) -> void:
	queue = lines
	idx = 0
	_show_next()

func _show_next() -> void:
	if idx >= queue.size():
		hide()
		return
	show()
	text_label.text = queue[idx]
	idx += 1

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		_show_next()
