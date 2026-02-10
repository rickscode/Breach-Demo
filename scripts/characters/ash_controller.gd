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
@export var footstep_interval: float = 0.5
@export var sprint_footstep_interval: float = 0.3
@export var crouch_footstep_interval: float = 0.8
@export var camera_sensitivity: float = 3.0
@export var camera_distance: float = 3.0
@export var model_turn_speed: float = 10.0

var current_health: float
var is_crouching: bool = false
var is_sprinting: bool = false
var is_hidden: bool = false

@onready var model: Node3D = $Model
@onready var camera: Camera3D = $Camera3D
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio3D

var _base_model_scale: Vector3
var _base_camera_height: float
var _base_camera_fov: float
var _footstep_timer: float = 0.0
var _noise_system: NoiseSystem
var _tone_walk: AudioStreamWAV
var _tone_sprint: AudioStreamWAV
var _tone_crouch: AudioStreamWAV
var _char_anim: CharacterAnimation
var _camera_yaw: float = 0.0

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	_base_model_scale = model.scale
	_base_camera_height = camera.position.y
	_base_camera_fov = camera.fov
	_setup_footstep_audio()
	_resolve_noise_system()
	_setup_animations()
	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hide"):
		_toggle_hide()

func _physics_process(delta: float) -> void:
	handle_camera_rotation(delta)
	if is_hidden:
		velocity = Vector3.ZERO
		_update_camera()
		return
	handle_movement(delta)
	update_visual_feedback(delta)
	update_footsteps(delta)
	_update_camera()

func handle_camera_rotation(delta: float) -> void:
	var camera_input := Input.get_axis("camera_left", "camera_right")
	_camera_yaw += camera_input * camera_sensitivity * delta

func handle_movement(delta: float) -> void:
	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Movement relative to camera direction (MGS3-style)
	var cam_forward := Vector3(-sin(_camera_yaw), 0.0, -cos(_camera_yaw))
	var cam_right := Vector3(cos(_camera_yaw), 0.0, -sin(_camera_yaw))
	var move_direction := (cam_right * input_vector.x + cam_forward * input_vector.y)
	if move_direction.length() > 0.0:
		move_direction = move_direction.normalized()

	# Rotate model to face movement direction
	if move_direction.length() > 0.1:
		var target_angle := atan2(move_direction.x, move_direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, model_turn_speed * delta)

	var target_speed := move_speed
	if is_crouching:
		target_speed = crouch_speed
	elif is_sprinting:
		target_speed = sprint_speed

	var target_velocity := move_direction * target_speed
	velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)

	move_and_slide()
	_update_animation()

func update_visual_feedback(delta: float) -> void:
	var target_scale_y := _base_model_scale.y
	var target_camera_height := _base_camera_height
	var target_fov := _base_camera_fov

	if is_crouching:
		target_scale_y = _base_model_scale.y * crouch_scale_y
		target_camera_height = crouch_camera_height
	elif is_sprinting:
		target_fov = sprint_fov

	model.scale.y = lerp(model.scale.y, target_scale_y, state_transition_speed * delta)
	camera.position.y = lerp(camera.position.y, target_camera_height, state_transition_speed * delta)
	camera.fov = lerp(camera.fov, target_fov, state_transition_speed * delta)

func _update_camera() -> void:
	var cam_offset := Vector3(
		sin(_camera_yaw) * camera_distance,
		camera.position.y,
		cos(_camera_yaw) * camera_distance
	)
	camera.position = cam_offset
	camera.look_at(global_position + Vector3.UP * 0.8)

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

func _setup_animations() -> void:
	_load_character_model("res://assets/models/ash-character.fbx")
	var anim_player := _find_anim_player(model)
	if not anim_player:
		return
	_char_anim = CharacterAnimation.new()
	model.add_child(_char_anim)
	_char_anim.setup(anim_player)
	_char_anim.load_mixamo_animations({
		"idle": "res://assets/models/Idle.fbx",
		"walk": "res://assets/models/Standard Walk.fbx",
		"run": "res://assets/models/Running.fbx",
		"crouch_idle": "res://assets/models/Male Crouch Pose.fbx",
		"crouch_walk": "res://assets/models/Crouched Walking.fbx",
	})

func _load_character_model(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var scene: PackedScene = load(path)
	if not scene:
		return
	# Hide the capsule mesh fallback
	var mesh_inst := model.get_node_or_null("MeshInstance3D")
	if mesh_inst:
		mesh_inst.visible = false
	var instance := scene.instantiate()
	model.add_child(instance)

func _find_anim_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found := _find_anim_player(child)
		if found:
			return found
	return null

func _update_animation() -> void:
	if not _char_anim:
		return
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.5
	if is_crouching:
		_char_anim.play_state("crouch_walk" if is_moving else "crouch_idle")
	elif is_sprinting and is_moving:
		_char_anim.play_state("run")
	elif is_moving:
		_char_anim.play_state("walk")
	else:
		_char_anim.play_state("idle")
