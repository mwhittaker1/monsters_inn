extends Interactable

func _ready() -> void:
	add_to_group("interactables")

func interact(by: Node) -> void:
	super.interact(by)
	print("Ding! Welcome to Monster Hotel.")
