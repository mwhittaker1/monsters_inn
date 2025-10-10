class_name Interactable
extends Area2D

signal interacted(by: Node)
@export var prompt: String = "Interact"

func interact(by: Node) -> void:
	emit_signal("interacted", by)
