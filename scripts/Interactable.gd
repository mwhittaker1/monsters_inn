class_name Interactable
extends Area2D

signal interacted(by: Node)
@export var prompt: String = "Interact"

func interact(_by: Node = null) -> void:
	# Locate the UI (the prompt is in group "PromptUI")
	var prompt := get_tree().get_first_node_in_group("PromptUI")
	if prompt:
		prompt.show_prompt("Interact!", global_position, 1.5)
