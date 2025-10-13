extends Area2D

@export var cooldown := 0.25
@export var pitch_jitter := 0.03
@onready var spr: Node2D = $"Sprite"
@onready var sfx: AudioStreamPlayer2D = $SFX
var _busy := false

func interact(_by: Node = null) -> void:
	if _busy: return
	_busy = true

	# audio
	if sfx.stream:
		sfx.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
		sfx.play()

	# visual: quick shake+squash tween (0.3s total)
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var base_rot := spr.rotation_degrees
	var base_scale := spr.scale

	t.tween_property(spr, "rotation_degrees", base_rot - 6.0, 0.06)
	t.parallel().tween_property(spr, "scale", base_scale * Vector2(1.04, 0.96), 0.06)

	t.tween_property(spr, "rotation_degrees", base_rot + 6.0, 0.06)
	t.parallel().tween_property(spr, "scale", base_scale * Vector2(0.98, 1.02), 0.06)

	t.tween_property(spr, "rotation_degrees", base_rot, 0.12)
	t.parallel().tween_property(spr, "scale", base_scale, 0.12)

	t.finished.connect(func():
		_busy = false
	)


func _on_interacted(by: Node) -> void:
	pass # Replace with function body.
