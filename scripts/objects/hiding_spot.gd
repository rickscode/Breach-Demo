class_name HidingSpot
extends Area3D

## Hiding spot that makes the player invisible to enemies when activated.

var player_inside: bool = false
var _player_ref: Node3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		_player_ref = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		_player_ref = null
		# Unhide if player leaves the spot
		if body.get("is_hidden"):
			body.is_hidden = false
