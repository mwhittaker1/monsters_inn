extends Control

@export var y_offset: float = -16.0
@export var padding: Vector2 = Vector2(8, 6)
@export var default_seconds: float = 1.5

var _camera: Camera2D = null
var _follow_world_pos: Vector2 = Vector2.ZERO
var _visible_until_ms: int = -1
var _is_active: bool = false

@onready var _panel: PanelContainer = $PanelContainer
@onready var _label: Label = $PanelContainer/MarginContainer/Label

func _ready() -> void:
	# Optional: put this node in a group so others can find it without hard paths.
	add_to_group("PromptUI")
	_refresh_camera()
	visible = false
	modulate.a = 1.0
	# DEBUG: show a prompt 1s after load so we know the UI renders
	await get_tree().create_timer(1.0).timeout
	show_prompt("DEBUG: UI OK", Vector2.ZERO, 1.5)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_VISIBILITY_CHANGED:
		_refresh_camera()

func _process(_delta: float) -> void:
	if not _is_active:
		return

	# stick to the world point
	if _camera != null:
		var cvt: Transform2D = get_viewport().get_canvas_transform()
		var screen_pos: Vector2 = cvt * _follow_world_pos   # world → screen
		var size: Vector2 = get_combined_minimum_size()
		position = screen_pos - size * 0.5 + Vector2(0.0, y_offset)

	# timeout
	if _visible_until_ms >= 0 and Time.get_ticks_msec() >= _visible_until_ms:
		_hide_prompt()
	
func show_prompt(text: String, world_pos: Vector2, seconds: float = -1.0) -> void:
	_refresh_camera()
	_label.text = text
	_follow_world_pos = world_pos
	_update_min_size()
	_is_active = true
	visible = true
	modulate.a = 1.0

	var dur: float = seconds if seconds > 0.0 else default_seconds
	_visible_until_ms = Time.get_ticks_msec() + int(dur * 1000.0)

func refresh_position(world_pos: Vector2) -> void:
	_follow_world_pos = world_pos

func cancel_prompt() -> void:
	_hide_prompt()

func _hide_prompt() -> void:
	_is_active = false
	visible = false
	_visible_until_ms = -1

func _update_min_size() -> void:
	# Size the whole control so we can center it easily.
	# Ask the Label how big it wants to be, then add padding.
	var label_min: Vector2 = _label.get_minimum_size()
	custom_minimum_size = label_min + padding * 2.0

func _refresh_camera() -> void:
	# Always grab the viewport’s current Camera2D; works even if it’s on the Player.
	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam != null:
		_camera = cam


#debugging
