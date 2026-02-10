class_name NoiseSystem
extends Node

## Tracks player and environment noise sources for AI awareness.

signal noise_emitted(position: Vector3, strength: float)

var _listeners: Array[Node3D] = []

func register_listener(listener: Node3D) -> void:
	if listener not in _listeners:
		_listeners.append(listener)

func unregister_listener(listener: Node3D) -> void:
	_listeners.erase(listener)

func emit_noise(position: Vector3, strength: float) -> void:
	noise_emitted.emit(position, strength)
	for listener in _listeners:
		if is_instance_valid(listener) and listener.has_method("on_noise_heard"):
			listener.on_noise_heard(position, strength)
