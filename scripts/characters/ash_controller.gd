class_name AshController
extends CharacterBody3D

## Player character controller for ASH.

signal health_changed(new_health: float)
signal detected_by_enemy(enemy: Node3D)

@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var max_health: float = 100.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var acceleration: float = 12.0
@export var state_transition_speed: float = 10.0
@export var crouch_scale_y: float = 0.65
@export var sprint_fov: float = 82.0
@export var crouch_camera_height: float = 1.1
@export var normal_tint: Color = Color(1.0, 0.45, 0.22, 1.0)
@export var crouch_tint: Color = Color(0.35, 0.7, 1.0, 1.0)
@export var sprint_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var base_move_noise: float = 0.35
@export var sprint_noise_multiplier: float = 1.85
@export var crouch_noise_multiplier: float = 0.4
@export var min_noise_speed: float = 0.15
@export var noise_emit_interval: float = 0.12
@export var noise_system_path: NodePath

var current_health: float
var is_crouching: bool = false
var is_sprinting: bool = false

@onready var avatar_mesh: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D

var _base_mesh_scale: Vector3
var _base_camera_height: float
var _base_camera_fov: float
var _avatar_material: StandardMaterial3D
var _noise_system: NoiseSystem
var _noise_emit_timer: float = 0.0

func _ready() -> void:
	current_health = max_health
	_base_mesh_scale = avatar_mesh.scale
	_base_camera_height = camera.position.y
	_base_camera_fov = camera.fov

	if avatar_mesh.material_override is StandardMaterial3D:
		_avatar_material = avatar_mesh.material_override.duplicate()
	else:
		_avatar_material = StandardMaterial3D.new()

	avatar_mesh.material_override = _avatar_material
	_avatar_material.albedo_color = normal_tint
	_avatar_material.emission = normal_tint
	_resolve_noise_system()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	update_stealth_noise(delta)
	update_visual_feedback(delta)

func handle_movement(delta: float) -> void:
	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if move_direction.length() > 0.0:
		move_direction = move_direction.normalized()
		move_direction = global_transform.basis * move_direction
		move_direction.y = 0.0
		move_direction = move_direction.normalized()

	var target_speed := move_speed
	if is_crouching:
		target_speed = crouch_speed
	elif is_sprinting:
		target_speed = sprint_speed

	var target_velocity := move_direction * target_speed
	velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)

	move_and_slide()

func update_stealth_noise(delta: float) -> void:
	if _noise_system == null:
		return

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if horizontal_speed < min_noise_speed:
		_noise_emit_timer = 0.0
		return

	_noise_emit_timer += delta
	if _noise_emit_timer < noise_emit_interval:
		return

	_noise_emit_timer = 0.0
	var speed_ratio := clamp(horizontal_speed / sprint_speed, 0.0, 1.0)
	var state_multiplier := 1.0
	if is_crouching:
		state_multiplier = crouch_noise_multiplier
	elif is_sprinting:
		state_multiplier = sprint_noise_multiplier

	var noise_strength := base_move_noise * speed_ratio * state_multiplier
	_noise_system.emit_noise(global_position, noise_strength)

func _resolve_noise_system() -> void:
	if not noise_system_path.is_empty():
		_noise_system = get_node_or_null(noise_system_path) as NoiseSystem

	if _noise_system == null and get_parent() != null:
		_noise_system = get_parent().get_node_or_null("NoiseSystem") as NoiseSystem

func update_visual_feedback(delta: float) -> void:
	var target_scale_y := _base_mesh_scale.y
	var target_camera_height := _base_camera_height
	var target_fov := _base_camera_fov
	var target_tint := normal_tint

	if is_crouching:
		target_scale_y = _base_mesh_scale.y * crouch_scale_y
		target_camera_height = crouch_camera_height
		target_tint = crouch_tint
	elif is_sprinting:
		target_fov = sprint_fov
		target_tint = sprint_tint

	avatar_mesh.scale.y = lerp(avatar_mesh.scale.y, target_scale_y, state_transition_speed * delta)
	camera.position.y = lerp(camera.position.y, target_camera_height, state_transition_speed * delta)
	camera.fov = lerp(camera.fov, target_fov, state_transition_speed * delta)

	var new_tint := _avatar_material.albedo_color.lerp(target_tint, state_transition_speed * delta)
	_avatar_material.albedo_color = new_tint
	_avatar_material.emission = new_tint

func apply_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health)
	if current_health <= 0.0:
		die()

func die() -> void:
	# TODO: Trigger game over and respawn flow.
	pass
