class_name HealthComponent
extends Node

## Shared health/damage component for characters.

signal health_changed(current: float, max_value: float)
signal died

@export var max_health: float = 100.0

var current_health: float

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func apply_damage(amount: float) -> void:
	current_health = clamp(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()
