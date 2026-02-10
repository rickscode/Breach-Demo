class_name AshController
extends CharacterBody3D

## Player character controller for ASH.

signal health_changed(new_health: float)
signal detected_by_enemy(enemy: Node3D)

@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var max_health: float = 100.0

@export var mouse_sensitivity: float = 0.15
@export var camera_pitch_limit: float = 70.0

var current_health: float
var is_crouching: bool = false
var is_sprinting: bool = false

var _gravity: float
var _camera_pitch: float = 0.0

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	current_health = max_health
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity") as float

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		_camera_pitch = clamp(
			_camera_pitch - event.relative.y * mouse_sensitivity,
			-camera_pitch_limit,
			camera_pitch_limit
		)
		camera.rotation_degrees.x = _camera_pitch

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	is_sprinting = Input.is_action_pressed("sprint")	
	is_crouching = Input.is_action_pressed("crouch")

	var speed := move_speed
	if is_sprinting:
		speed = sprint_speed
	elif is_crouching:
		speed = crouch_speed

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

func apply_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health)
	if current_health <= 0.0:
		die()

func die() -> void:
	# TODO: Trigger game over and respawn flow.
	pass
