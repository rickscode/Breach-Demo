class_name EnemyAI
extends CharacterBody3D

## Basic enemy AI placeholder.

enum AlertState { UNAWARE, SUSPICIOUS, ALERT }

@export var patrol_speed: float = 2.0
@export var alert_speed: float = 4.5

var alert_state: AlertState = AlertState.UNAWARE

func _physics_process(_delta: float) -> void:
	# TODO: Implement patrol routes and state machine transitions.
	pass
