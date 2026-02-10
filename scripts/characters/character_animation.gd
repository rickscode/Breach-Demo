class_name CharacterAnimation
extends Node

## Manages animation playback with crossfade blending.
## Can load animations from separate Mixamo FBX files and map them to state names.

@export var crossfade_time: float = 0.2

var _anim_player: AnimationPlayer
var _current_state: String = ""


func setup(anim_player: AnimationPlayer) -> void:
	_anim_player = anim_player


func load_mixamo_animations(anim_map: Dictionary) -> void:
	## Loads animations from separate FBX scene files and adds them to the AnimationPlayer.
	## anim_map: { "state_name": "res://assets/models/SomeAnim.fbx", ... }
	if not _anim_player:
		return
	# Ensure we have a writable library
	var lib: AnimationLibrary
	if _anim_player.has_animation_library(""):
		lib = _anim_player.get_animation_library("")
	else:
		lib = AnimationLibrary.new()
		_anim_player.add_animation_library("", lib)

	for state_name in anim_map:
		var path: String = anim_map[state_name]
		if not ResourceLoader.exists(path):
			continue
		var scene: PackedScene = load(path)
		if not scene:
			continue
		var instance := scene.instantiate()
		var source_player := _find_animation_player(instance)
		if source_player:
			var anim_names := source_player.get_animation_list()
			if anim_names.size() > 0:
				# Mixamo FBX files typically have one animation (often named "mixamo.com")
				var anim := source_player.get_animation(anim_names[0])
				if anim:
					var copy := anim.duplicate()
					copy.loop_mode = Animation.LOOP_LINEAR
					lib.add_animation(state_name, copy)
		instance.queue_free()


func play_state(state_name: String) -> void:
	if not _anim_player:
		return
	if state_name == _current_state:
		return
	if not _anim_player.has_animation(state_name):
		return
	_anim_player.play(state_name, crossfade_time)
	_current_state = state_name


func get_current_state() -> String:
	return _current_state


func _find_animation_player(node: Node) -> AnimationPlayer:
	if not node:
		return null
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found := _find_animation_player(child)
		if found:
			return found
	return null
