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
@export var footstep_interval: float = 0.5
@export var sprint_footstep_interval: float = 0.3
@export var crouch_footstep_interval: float = 0.8

var current_health: float
var is_crouching: bool = false
var is_sprinting: bool = false
var is_hidden: bool = false

@onready var avatar_mesh: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio3D

var _base_mesh_scale: Vector3
var _base_camera_height: float
var _base_camera_fov: float
var _avatar_material: StandardMaterial3D
var _footstep_timer: float = 0.0
var _noise_system: NoiseSystem
var _tone_walk: AudioStreamWAV
var _tone_sprint: AudioStreamWAV
var _tone_crouch: AudioStreamWAV

func _ready() -> void:
	add_to_group("player")
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
	_setup_footstep_audio()
	_resolve_noise_system()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hide"):
		_toggle_hide()

func _physics_process(delta: float) -> void:
	if is_hidden:
		velocity = Vector3.ZERO
		return
	handle_movement(delta)
	update_visual_feedback(delta)
	update_footsteps(delta)

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

func _toggle_hide() -> void:
	if is_hidden:
		is_hidden = false
		return
	# Check if inside a hiding spot
	var areas := get_tree().get_nodes_in_group("hiding_spot")
	for area in areas:
		if area is HidingSpot and area.player_inside:
			is_hidden = true
			return

func _setup_footstep_audio() -> void:
	_tone_walk = _generate_tone(150.0, 0.6, 0.05)
	_tone_sprint = _generate_tone(220.0, 1.0, 0.05)
	_tone_crouch = _generate_tone(100.0, 0.3, 0.04)

func _generate_tone(freq: float, volume: float, duration: float) -> AudioStreamWAV:
	var mix_rate := 22050
	var samples := int(mix_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / float(mix_rate)
		var envelope := 1.0 - (float(i) / float(samples))
		var value := sin(TAU * freq * t) * volume * envelope
		var sample_int := clampi(int(value * 32767.0), -32768, 32767)
		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.data = data
	return stream

func _resolve_noise_system() -> void:
	var nodes := get_tree().get_nodes_in_group("noise_system")
	if nodes.size() > 0 and nodes[0] is NoiseSystem:
		_noise_system = nodes[0]
	else:
		for node in get_tree().root.get_children():
			var found := _find_noise_system(node)
			if found:
				_noise_system = found
				break

func _find_noise_system(node: Node) -> NoiseSystem:
	if node is NoiseSystem:
		return node
	for child in node.get_children():
		var found := _find_noise_system(child)
		if found:
			return found
	return null

func update_footsteps(delta: float) -> void:
	if not is_on_floor():
		return

	var horizontal_vel := Vector2(velocity.x, velocity.z)
	if horizontal_vel.length() < 0.5:
		_footstep_timer = 0.0
		return

	_footstep_timer -= delta
	if _footstep_timer > 0.0:
		return

	var volume: float
	var noise_strength: float
	if is_crouching:
		_footstep_timer = crouch_footstep_interval
		volume = 0.3
		noise_strength = 0.2
	elif is_sprinting:
		_footstep_timer = sprint_footstep_interval
		volume = 1.0
		noise_strength = 1.0
	else:
		_footstep_timer = footstep_interval
		volume = 0.6
		noise_strength = 0.5

	_play_footstep_tone(volume)

	if _noise_system:
		_noise_system.emit_noise(global_position, noise_strength)

func _play_footstep_tone(_volume: float) -> void:
	if is_crouching:
		footstep_audio.stream = _tone_crouch
	elif is_sprinting:
		footstep_audio.stream = _tone_sprint
	else:
		footstep_audio.stream = _tone_walk
	footstep_audio.play()
