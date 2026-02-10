class_name ObjectiveManager
extends Node

## Tracks mission objectives and completion states.

signal objective_added(text: String)
signal objective_completed(text: String)

var objectives: Array[String] = []

func add_objective(text: String) -> void:
	objectives.append(text)
	objective_added.emit(text)

func complete_objective(text: String) -> void:
	if text in objectives:
		objective_completed.emit(text)
