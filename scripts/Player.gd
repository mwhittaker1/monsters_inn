extends Node2D

@export var grid_size: int = 32
@export var step_time: float = 0.30
@export var faces_right_by_default := false  # true if art faces RIGHT by default

var _last_prompt_target: Node = null
var _facing: Vector2 = Vector2.DOWN
var _moving := false
var _from: Vector2
var _to: Vector2
var _t := 0.0

@onready var spr: AnimatedSprite2D = get_node_or_null("Sprite") as AnimatedSprite2D
@onready var _ray: RayCast2D = $InteractRay
@onready var _shape: CollisionShape2D = $CollisionShape2D

var _idle_anim := ""
var _walk_anim := ""


func _debug_probe_here() -> void:
	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = global_position
	params.collision_mask = 1
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var hits := space.intersect_point(params, 16)
	if hits.is_empty():
		print("No colliders detected near player at ", global_position)
	else:
		for h in hits:
			print("Hit:", h.collider, " (", h.collider.name, ")")

func _find_anim_case_insensitive(want: String) -> String:
	if spr == null or spr.sprite_frames == null:
		return ""
	for n in spr.sprite_frames.get_animation_names():
		if n.to_lower() == want.to_lower():
			return n
	return ""

func _ready() -> void:
	if spr == null:
		push_error("Player: AnimatedSprite2D 'Sprite' not found under Player.")
		print_tree_pretty()
		return

	_idle_anim = _find_anim_case_insensitive("idle")
	_walk_anim = _find_anim_case_insensitive("walk")
	print("Anim names:", spr.sprite_frames.get_animation_names(), " | idle:", _idle_anim, " walk:", _walk_anim)
	if _idle_anim == "" or _walk_anim == "":
		push_error("Missing idle/walk animations (any case).")

	# Snap to grid before starting anim
	_to = _snap_to_grid(global_position)
	_from = _to
	global_position = _to

	# Start idle
	spr.speed_scale = 1.0
	if _idle_anim != "":
		spr.play(_idle_anim)

	# Optional: scale first idle frame to grid_size
	var tex := spr.sprite_frames.get_frame_texture(_idle_anim, 0)
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
		_apply_walk_progress()
		global_position = _from.lerp(_to, _t)
		if _t >= 1.0:
			_finish_step()
		return
		
	var hit: Object = _ray.get_collider() if _ray.is_colliding() else null

	if hit != null and hit is Node and (hit as Node).is_in_group("Interactable"):
		if hit != _last_prompt_target:
			_last_prompt_target = hit
			var world_pos: Vector2 = _ray.get_collision_point()
			_get_prompt_ui().show_prompt("Press E", world_pos, 1.2)
	else:
		if _last_prompt_target != null:
			_last_prompt_target = null
			_get_prompt_ui().cancel_prompt()

	if Input.is_action_just_pressed("ui_accept") and hit is Node and (hit as Node).is_in_group("interactable"):
		_get_prompt_ui().cancel_prompt()
		var n := hit as Node
		if n.has_method("interact"):
			n.call_deferred("interact", self)

func _get_prompt_ui() -> Node:
	var n: Node = get_tree().get_first_node_in_group("PromptUI")
	if n != null:
		return n
	return get_node("/root/Game/UI/PromptUI")
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):  # Tab by default
		_debug_probe_here()
		
	if event.is_action_pressed("ui_interact"):
		_try_interact()

	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):    dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"): dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"): dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):dir = Vector2.RIGHT

	if dir != Vector2.ZERO and not _moving:
		_update_facing(dir)
		_start_step(dir)

func _start_step(dir: Vector2) -> void:
	_update_facing(dir)
	var from_pos := (_from if _moving else global_position)
	from_pos = _snap_to_grid(from_pos)
	var motion := dir * float(grid_size)

	if _would_hit(from_pos + motion):
		return

	_moving = true
	_t = 0.0
	_from = from_pos
	_to = from_pos + motion

	if _walk_anim != "":
		spr.play(_walk_anim)
		spr.speed_scale = 0.0 

	if dir.x != 0 and _walk_anim != "":
		spr.flip_h = (dir.x < 0) if faces_right_by_default else (dir.x > 0)

func _would_hit(target_world_pos: Vector2) -> bool:
	if _shape == null or _shape.shape == null:
		return false

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = _shape.shape
	var delta := target_world_pos - global_position
	params.transform = _shape.global_transform.translated(delta)
	params.collision_mask = 1 
	params.exclude = [self]

	var space := get_world_2d().direct_space_state
	return space.intersect_shape(params, 4).size() > 0

func _finish_step() -> void:
	global_position = _to
	_moving = false
	_t = 0.0
	if _idle_anim != "":
		spr.speed_scale = 1.0
		spr.play(_idle_anim)

func _apply_walk_progress() -> void:
	if _walk_anim == "": return
	var n := spr.sprite_frames.get_frame_count(_walk_anim)
	if n <= 0: return
	# progress 0..(n-1) over the step
	var f := int(floor(min(_t, 0.999) * n)) % n
	if spr.animation != _walk_anim:
		spr.play(_walk_anim)
		spr.speed_scale = 0.0
	if spr.frame != f:
		spr.frame = f

func _try_interact() -> void:
	_ray.target_position = _facing * float(grid_size) * 1.5
	_ray.force_raycast_update()

	if _ray.is_colliding():
		var hit := _ray.get_collider()
		if hit and hit.has_method("interact"):
			hit.interact(self)
			return

	# optional fallback: nearest interactable in short cone
	var best: Node = null
	var best_d := 1e9
	var p := global_position
	for n in get_tree().get_nodes_in_group("interactable"):
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
