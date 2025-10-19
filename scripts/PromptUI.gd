extends Control

@export var y_offset: float = -16.0
@export var padding: Vector2 = Vector2(8, 6)
@export var default_seconds: float = 1.5
@export var extra_offset: Vector2 = Vector2.ZERO   # ← new: extra XY shift

var _camera: Camera2D = null
var _follow_world_pos: Vector2 = Vector2.ZERO
var _visible_until_ms: int = -1
var _is_active: bool = false

@onready var _panel: PanelContainer = $PanelContainer
@onready var _label: Label = $PanelContainer/MarginContainer/Label

func _ready() -> void:
	add_to_group("PromptUI")
	_refresh_camera()
	visible = false
	modulate.a = 1.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_VISIBILITY_CHANGED:
		_refresh_camera()

func _process(_dt: float) -> void:
	if not _is_active:
		return
		
	if _camera != null:
		var screen_pos: Vector2 = get_viewport().get_final_transform() * _follow_world_pos
		
		var sz: Vector2 = get_combined_minimum_size()
		position = screen_pos - sz * 0.5 + Vector2(0.0, y_offset) + extra_offset
		
	# timeout
	if _visible_until_ms >= 0 and Time.get_ticks_msec() >= _visible_until_ms:
		_hide_prompt()

func show_prompt(text: String, world_pos: Vector2, seconds: float = -1.0) -> void:
	_refresh_camera()
	_label.text = text
	_update_min_size()
	_follow_world_pos = world_pos
	_is_active = true
	visible = true
	modulate.a = 1.0

	var dur := (seconds if seconds > 0.0 else default_seconds)
	_visible_until_ms = Time.get_ticks_msec() + int(dur * 5000.0)

func refresh_position(world_pos: Vector2) -> void:
	_follow_world_pos = world_pos

func cancel_prompt() -> void:
	_hide_prompt()

func _hide_prompt() -> void:
	_is_active = false
	visible = false
	_visible_until_ms = -1

func _update_min_size() -> void:
	var label_min: Vector2 = _label.get_minimum_size()
	custom_minimum_size = label_min + padding * 2.0

func _refresh_camera() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		_camera = cam
