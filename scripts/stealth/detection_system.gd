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
var _cone_mesh: MeshInstance3D
var _cone_material: StandardMaterial3D
var _was_suspicious: bool = false
var _was_detected: bool = false

func _ready() -> void:
	_setup_vision_cone_mesh()

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
	_update_cone_color()

func _drain_detection(delta: float) -> void:
	detection_level = maxf(detection_level - decay_rate * delta, 0.0)
	_update_signals()
	_update_cone_color()

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

func _setup_vision_cone_mesh() -> void:
	_cone_mesh = MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 1.2
	cone.height = 4.0
	_cone_mesh.mesh = cone
	# Rotate so cone points forward (-Z)
	_cone_mesh.rotation_degrees.x = -90.0
	_cone_mesh.position = Vector3(0.0, eye_height * 0.5, -2.0)

	_cone_material = StandardMaterial3D.new()
	_cone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_cone_material.albedo_color = Color(0.0, 1.0, 0.0, 0.04)
	_cone_material.no_depth_test = true
	_cone_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_cone_mesh.material_override = _cone_material

	add_child(_cone_mesh)

func _update_cone_color() -> void:
	if not _cone_material:
		return
	var color: Color
	if detection_level >= 0.99:
		color = Color(1.0, 0.0, 0.0, 0.1)
	elif detection_level >= 0.4:
		color = Color(1.0, 1.0, 0.0, 0.07)
	else:
		color = Color(0.0, 1.0, 0.0, 0.04)
	_cone_material.albedo_color = _cone_material.albedo_color.lerp(color, 0.15)
