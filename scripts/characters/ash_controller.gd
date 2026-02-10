class_name AshController
extends CharacterBody3D

## Player character controller for ASH.

signal health_changed(new_health: float)
signal detected_by_enemy(enemy: Node3D)

@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var max_health: float = 100.0

var current_health: float
var is_crouching: bool = false
var is_sprinting: bool = false

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(_delta: float) -> void:
	# TODO: Implement movement input, camera-relative direction, and sprint/crouch logic.
	pass

func apply_damage(amount: float) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	if current_health <= 0.0:
		die()

func die() -> void:
	# TODO: Trigger game over and respawn flow.
	pass
