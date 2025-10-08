extends Control
@onready var label: Label = $Phase

func set_phase_name(name: String) -> void:
	label.text = "Phase: %s" % name
