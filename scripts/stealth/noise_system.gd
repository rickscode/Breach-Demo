class_name NoiseSystem
extends Node

## Tracks player and environment noise sources for AI awareness.

signal noise_emitted(position: Vector3, strength: float)

@export var debug_logs_enabled: bool = true
@export var debug_min_strength: float = 0.01

func emit_noise(position: Vector3, strength: float) -> void:
	if debug_logs_enabled and strength >= debug_min_strength:
		print("[NoiseSystem] strength=", snappedf(strength, 0.01), " position=", position)
	noise_emitted.emit(position, strength)
