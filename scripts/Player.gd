extends Node2D

@export var grid_size: int = 32
@export var step_time: float = 0.12
@export var faces_right_by_default := false  # true if art faces RIGHT by default

var _facing: Vector2 = Vector2.DOWN
var _moving := false
var _from: Vector2
var _to: Vector2
var _t := 0.0

@onready var spr: AnimatedSprite2D = get_node_or_null("Sprite") as AnimatedSprite2D
@onready var _ray: RayCast2D = $InteractRay

func _ready() -> void:
	if spr == null:
		push_error("Player: AnimatedSprite2D 'Sprite' not found under Player.")
		print_tree_pretty()
		return	
	var names := spr.sprite_frames.get_animation_names()
	
	print("Anim names:", names)
	
	if not spr.sprite_frames.has_animation("idle") or not spr.sprite_frames.has_animation("walk"):
		push_error("Missing 'idle' or 'walk' animations on SpriteFrames.")
		
	spr.speed_scale = 1.0
	_to = _snap_to_grid(global_position)
	_from = _to
	global_position = _to
	spr.play("idle")
	
	if spr:
		# optional: scale first idle frame to grid
		var tex := spr.sprite_frames.get_frame_texture("idle", 0)
		if tex:
			var sz := tex.get_size()
			if sz.x > 0.0 and sz.y > 0.0:
				var s := float(grid_size)
				spr.scale = Vector2(s / sz.x, s / sz.y)

func _physics_process(d: float) -> void:
	# keep ray ~1 tile ahead
	_ray.target_position = _facing * float(grid_size) * 1.1
	_ray.force_raycast_update()

	if _moving:
		_t += d / step_time
		global_position = _from.lerp(_to, _t)
		if _t >= 1.0:
			global_position = _to
			_moving = false
			if spr: spr.play("idle")
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_try_interact()

	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector2.RIGHT

	if dir != Vector2.ZERO and not _moving:
		_update_facing(dir)
		_start_step(dir)

func _start_step(dir: Vector2) -> void:
	_moving = true
	_t = 0.0
	_from = global_position
	_to = (_from / grid_size).floor() * grid_size + dir * grid_size
	if spr: spr.play("walk")
	if dir.x != 0 and spr:
		spr.flip_h = (dir.x < 0) if faces_right_by_default else (dir.x > 0)

func _try_interact() -> void:
	# brief reach boost so you're not pixel-perfect
	_ray.target_position = _facing * float(grid_size) * 1.5
	_ray.force_raycast_update()

	if _ray.is_colliding():
		var hit := _ray.get_collider()
		if hit and hit.has_method("interact"):
			hit.interact(self)
			return

	# fallback (optional): nearest interactable in a short cone
	var best: Node = null
	var best_d := 1e9
	var p := global_position
	for n in get_tree().get_nodes_in_group("interactables"):
		if not n is Node2D: continue
		var to := (n as Node2D).global_position - p
		if to.dot(_facing) <= 0: continue
		var d := to.length()
		if d <= 64.0 and d < best_d:
			best = n; best_d = d
	if best and best.has_method("interact"):
		best.interact(self)

func _update_facing(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		_facing = dir

func _snap_to_grid(p: Vector2) -> Vector2:
	return (p / grid_size).floor() * grid_size
