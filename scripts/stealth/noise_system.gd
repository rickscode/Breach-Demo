class_name NoiseSystem
extends Node

## Tracks player and environment noise sources for AI awareness.

signal noise_emitted(position: Vector3, strength: float)

func emit_noise(position: Vector3, strength: float) -> void:
	noise_emitted.emit(position, strength)
