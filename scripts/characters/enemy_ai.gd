class_name EnemyAI
extends CharacterBody3D

## Enemy AI with patrol, detection states, and noise response.

enum AlertState { UNAWARE, SUSPICIOUS, ALERT }

@export var patrol_speed: float = 2.0
@export var alert_speed: float = 4.5
@export var patrol_pause_duration: float = 1.5
@export var suspicious_timeout: float = 3.0
@export var alert_los_timeout: float = 5.0
@export var rotation_speed: float = 5.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var alert_state: AlertState = AlertState.UNAWARE
var last_known_position: Vector3
var _patrol_points: Array[Vector3] = []
var _current_patrol_index: int = 0
var _pause_timer: float = 0.0
var _state_timer: float = 0.0
var _detection_system: DetectionSystem
var _noise_system: NoiseSystem

func _ready() -> void:
	_collect_patrol_points()
	_setup_detection_system()
	_resolve_noise_system()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match alert_state:
		AlertState.UNAWARE:
			_process_patrol(delta)
		AlertState.SUSPICIOUS:
			_process_suspicious(delta)
		AlertState.ALERT:
			_process_alert(delta)

	move_and_slide()

func _collect_patrol_points() -> void:
	for child in get_children():
		if child is Marker3D:
			_patrol_points.append(child.global_position)
	# If no markers, just stand in place
	if _patrol_points.is_empty():
		_patrol_points.append(global_position)

func _setup_detection_system() -> void:
	for child in get_children():
		if child is DetectionSystem:
			_detection_system = child
			break
	if not _detection_system:
		return
	_detection_system.suspicious.connect(_on_suspicious)
	_detection_system.fully_detected.connect(_on_fully_detected)
	_detection_system.lost_target.connect(_on_lost_target)

func _resolve_noise_system() -> void:
	var nodes := get_tree().get_nodes_in_group("noise_system")
	if nodes.size() > 0 and nodes[0] is NoiseSystem:
		_noise_system = nodes[0]
		_noise_system.register_listener(self)
		return
	# Fallback: search scene tree
	for node in get_tree().root.get_children():
		var found := _find_noise_system(node)
		if found:
			_noise_system = found
			_noise_system.register_listener(self)
			return

func _find_noise_system(node: Node) -> NoiseSystem:
	if node is NoiseSystem:
		return node
	for child in node.get_children():
		var found := _find_noise_system(child)
		if found:
			return found
	return null

# -- State processors --

func _process_patrol(delta: float) -> void:
	if _patrol_points.size() <= 1 and _patrol_points[0].distance_to(global_position) < 0.5:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	if _pause_timer > 0.0:
		_pause_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var target := _patrol_points[_current_patrol_index]
	var to_target := target - global_position
	to_target.y = 0.0
	var distance := to_target.length()

	if distance < 0.5:
		_current_patrol_index = (_current_patrol_index + 1) % _patrol_points.size()
		_pause_timer = patrol_pause_duration
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var direction := to_target.normalized()
	velocity.x = direction.x * patrol_speed
	velocity.z = direction.z * patrol_speed
	_rotate_toward(direction, delta)

func _process_suspicious(delta: float) -> void:
	_state_timer -= delta
	velocity.x = 0.0
	velocity.z = 0.0

	# Face last known position
	var to_target := last_known_position - global_position
	to_target.y = 0.0
	if to_target.length() > 0.1:
		_rotate_toward(to_target.normalized(), delta)

	# Boost detection while suspicious
	if _detection_system:
		_detection_system.vision_range = _detection_system.vision_range  # Already set via state entry

	if _state_timer <= 0.0:
		_enter_state(AlertState.UNAWARE)

func _process_alert(delta: float) -> void:
	# Chase player
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player: Node3D = players[0]
		if not player.get("is_hidden"):
			last_known_position = player.global_position

	var to_target := last_known_position - global_position
	to_target.y = 0.0
	var distance := to_target.length()

	if distance > 1.5:
		var direction := to_target.normalized()
		velocity.x = direction.x * alert_speed
		velocity.z = direction.z * alert_speed
		_rotate_toward(direction, delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# Check if we've lost LOS
	if _detection_system and _detection_system.detection_level < 0.1:
		_state_timer -= delta
		if _state_timer <= 0.0:
			_enter_state(AlertState.SUSPICIOUS)
	else:
		_state_timer = alert_los_timeout

func _enter_state(new_state: AlertState) -> void:
	alert_state = new_state
	match new_state:
		AlertState.UNAWARE:
			if _detection_system:
				_detection_system.vision_angle_degrees = 90.0
				_detection_system.detection_rate = 1.0
		AlertState.SUSPICIOUS:
			_state_timer = suspicious_timeout
			if _detection_system:
				_detection_system.vision_angle_degrees = 90.0
				_detection_system.detection_rate = 1.5
		AlertState.ALERT:
			_state_timer = alert_los_timeout
			if _detection_system:
				_detection_system.vision_angle_degrees = 180.0
				_detection_system.detection_rate = 2.0

func _rotate_toward(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var target_basis := Basis.looking_at(direction, Vector3.UP)
	basis = basis.slerp(target_basis, rotation_speed * delta)

# -- Signal handlers --

func _on_suspicious() -> void:
	if alert_state == AlertState.UNAWARE:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			last_known_position = players[0].global_position
		_enter_state(AlertState.SUSPICIOUS)

func _on_fully_detected() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		last_known_position = players[0].global_position
	_enter_state(AlertState.ALERT)

func _on_lost_target() -> void:
	if alert_state == AlertState.ALERT:
		_enter_state(AlertState.SUSPICIOUS)

# -- Noise response --

func on_noise_heard(noise_position: Vector3, strength: float) -> void:
	var distance := global_position.distance_to(noise_position)
	var effective := strength / (distance + 1.0)
	if effective > 0.15 and alert_state == AlertState.UNAWARE:
		last_known_position = noise_position
		_enter_state(AlertState.SUSPICIOUS)
