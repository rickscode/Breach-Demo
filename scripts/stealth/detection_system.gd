class_name DetectionSystem
extends Node

## Handles visibility checks and alert escalation.

signal detection_changed(level: float)

@export var detection_rate: float = 1.0
@export var decay_rate: float = 0.5

var detection_level: float = 0.0

func _process(_delta: float) -> void:
	# TODO: Update detection_level based on line-of-sight and noise.
	pass
