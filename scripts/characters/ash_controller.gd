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
@export var footstep_tone_enabled: bool = true
@export var crouch_footstep_pitch: float = 260.0
@export var walk_footstep_pitch: float = 380.0
@export var sprint_footstep_pitch: float = 520.0
@export var footstep_tone_duration: float = 0.10
@export var footstep_tone_amplitude: float = 0.4
@export var debug_footsteps: bool = false

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
var _did_warn_missing_noise_system: bool = false
var _footstep_playback: AudioStreamGeneratorPlayback

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
	_setup_footstep_audio()

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
	if _noise_system == null and not _did_warn_missing_noise_system:
		_did_warn_missing_noise_system = true
		push_warning("AshController could not find NoiseSystem. Set noise_system_path or add a sibling node named 'NoiseSystem'.")

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
	if _noise_system != null:
		_noise_system.emit_noise(global_position, noise_strength)
	elif debug_footsteps:
		print("[AshController/Footstep] NoiseSystem missing; footstep tone still active")

	if debug_footsteps:
		print("[AshController/Footstep] cadence speed=%.2f strength=%.3f" % [horizontal_speed, noise_strength])
	_play_footstep_tone(noise_strength)

func _resolve_noise_system() -> void:
	if not noise_system_path.is_empty():
		_noise_system = get_node_or_null(noise_system_path) as NoiseSystem

	if _noise_system == null and get_parent() != null:
		_noise_system = get_parent().get_node_or_null("NoiseSystem") as NoiseSystem

func _setup_footstep_audio() -> void:
	var footstep_audio := get_node_or_null("FootstepAudio3D") as AudioStreamPlayer3D
	if footstep_audio == null:
		push_warning("AshController is missing FootstepAudio3D child. Movement tone feedback disabled.")
		if debug_footsteps:
			print("[AshController/Footstep] FootstepAudio3D missing")
		return

	if footstep_audio.stream == null:
		var generator := AudioStreamGenerator.new()
		generator.mix_rate = 44100.0
		generator.buffer_length = 0.1
		footstep_audio.stream = generator

	footstep_audio.play()
	_footstep_playback = footstep_audio.get_stream_playback() as AudioStreamGeneratorPlayback
	if debug_footsteps:
		print("[AshController/Footstep] playback ready=%s" % [str(_footstep_playback != null)])

func _play_footstep_tone(noise_strength: float) -> void:
	if not footstep_tone_enabled:
		if debug_footsteps:
			print("[AshController/Footstep] skipped: footstep_tone_enabled=false")
		return
	if _footstep_playback == null:
		if debug_footsteps:
			print("[AshController/Footstep] skipped: playback missing")
		return

	var pitch := walk_footstep_pitch
	if is_crouching:
		pitch = crouch_footstep_pitch
	elif is_sprinting:
		pitch = sprint_footstep_pitch

	var frame_count := int(44100.0 * footstep_tone_duration)
	if frame_count <= 0:
		if debug_footsteps:
			print("[AshController/Footstep] skipped: frame_count <= 0")
		return

	var amplitude := clamp(footstep_tone_amplitude * noise_strength, 0.0, 0.8)
	if debug_footsteps:
		print("[AshController/Footstep] pushing frames=%d pitch=%.1f amp=%.3f" % [frame_count, pitch, amplitude])
	for i in frame_count:
		var t := float(i) / 44100.0
		var sample := sin(TAU * pitch * t) * amplitude
		_footstep_playback.push_frame(Vector2(sample, sample))

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
