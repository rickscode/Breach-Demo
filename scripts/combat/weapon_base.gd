class_name WeaponBase
extends Node3D

## Base weapon behavior for melee or firearms.

signal fired

@export var damage: float = 25.0
@export var fire_rate: float = 0.3

var _cooldown: float = 0.0

func _process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)

func try_fire() -> void:
	if _cooldown > 0.0:
		return
	_cooldown = fire_rate
	fired.emit()
