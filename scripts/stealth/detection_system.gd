class_name DetectionSystem
extends Node3D

## Vision cone detection component. Attach as child of an enemy.

signal suspicious
signal fully_detected
signal lost_target

@export var vision_range: float = 10.0
@export var vision_angle_degrees: float = 90.0
@export var detection_rate: float = 1.0
@export var decay_rate: float = 0.5
@export var eye_height: float = 1.5

var detection_level: float = 0.0
var _target: Node3D
var _was_suspicious: bool = false
var _was_detected: bool = false

func _process(delta: float) -> void:
	if not _target:
		_find_target()
	if not _target:
		_drain_detection(delta)
		return

	var can_see := _check_los()
	if can_see:
		var rate := detection_rate
		if _target.has_method("get") and _target.get("is_crouching"):
			rate *= 0.6
		detection_level = minf(detection_level + rate * delta, 1.0)
	else:
		_drain_detection(delta)

	_update_signals()

func _drain_detection(delta: float) -> void:
	detection_level = maxf(detection_level - decay_rate * delta, 0.0)
	_update_signals()

func _find_target() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

func _check_los() -> bool:
	if not _target:
		return false

	# Hidden players are invisible
	if _target.get("is_hidden"):
		return false

	var enemy := get_parent() as Node3D
	if not enemy:
		return false

	var eye_pos := enemy.global_position + Vector3.UP * eye_height
	var target_pos := _target.global_position + Vector3.UP * 0.5

	# Distance check
	var effective_range := vision_range
	if _target.get("is_crouching"):
		effective_range *= 0.7
	var distance := eye_pos.distance_to(target_pos)
	if distance > effective_range:
		return false

	# Angle check
	var to_target := (target_pos - eye_pos).normalized()
	var forward := -enemy.global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_target))
	var half_angle := vision_angle_degrees / 2.0
	if angle > half_angle:
		return false

	# Raycast check -- skip enemy layer (2)
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(eye_pos, target_pos)
	query.collision_mask = 0b101  # Layers 1 (player) + 3 (environment)
	query.exclude = [enemy.get_rid()]
	var result := space_state.intersect_ray(query)

	if result.is_empty():
		return true
	# Hit something -- is it the player?
	return result.collider == _target

func get_effective_vision_range() -> float:
	var r := vision_range
	if _target and _target.get("is_crouching"):
		r *= 0.7
	return r

func get_effective_vision_angle() -> float:
	return vision_angle_degrees

func _update_signals() -> void:
	var is_suspicious := detection_level >= 0.4
	var is_detected := detection_level >= 0.99
	var is_lost := detection_level < 0.1

	if is_detected and not _was_detected:
		fully_detected.emit()
	elif is_suspicious and not _was_suspicious:
		suspicious.emit()

	if is_lost and (_was_suspicious or _was_detected):
		lost_target.emit()

	_was_suspicious = is_suspicious
	_was_detected = is_detected
