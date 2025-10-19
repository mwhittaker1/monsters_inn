class_name Interactable
extends Area2D

signal interacted(by: Node)
@export var prompt: String = "Interact"

func interact(_by: Node2D = null) -> void:
	# Locate the UI (the prompt is in group "PromptUI")
	var prompt := get_tree().get_first_node_in_group("PromptUI")
	if prompt:
		var player_pos := _by.global_position
		var offset := Vector2(12, -6)  # tweak this to your liking
		prompt.show_prompt("Interact!", player_pos + offset, 5)
	else:
		push_error("Interactable: Could not find PromptUI in group 'PromptUI'.")
