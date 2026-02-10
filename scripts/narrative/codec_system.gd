class_name CodecSystem
extends Node

## Manages codec-style conversations and UI triggers.

signal codec_started(contact_name: String)
signal codec_ended

func start_codec(contact_name: String) -> void:
	codec_started.emit(contact_name)

func end_codec() -> void:
	codec_ended.emit()
