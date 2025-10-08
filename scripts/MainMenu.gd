extends Control

@onready var start_btn: Button = get_node_or_null("StartButton")

func _ready() -> void:
	# connect once; avoids editor wiring mistakes
	if not start_btn.pressed.is_connected(_on_start_pressed):
		start_btn.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	print("Start pressed")
