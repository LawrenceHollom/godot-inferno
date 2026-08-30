class_name PresentationController
extends Node

## Runs the small, skippable effects used by narrative scenes.
##
## Call [method say] and [method fade_in] in sequence from a scene script. A press
## while an effect is playing completes that effect; a press while text is fully
## visible allows [method say] to return and the scene script to continue.

signal advance_requested

const PAUSING_PUNCTUATION := ",.;:!?\u2026\u2014\u2013-"
const SILENT_CHARACTERS := " \t\n\r.,;:!?\u2026\u2014\u2013-()[]{}\\\"'\u201c\u201d\u2018\u2019/\\"

enum PlaybackState {
	IDLE,
	TYPING,
	WAITING,
	ANIMATING,
}

@export var click_randomiser: AudioRandomiser

@export_range(1.0, 120.0, 1.0) var characters_per_second: float = 30.0
## Extra delay after commas, sentence endings, colons, semicolons, and dashes.
@export_range(0.0, 1.0, 0.01) var punctuation_pause: float = 0.15
## Short speech clip played once for each typed letter or number.
@export var talking_sound: AudioStream
@export_range(-80.0, 24.0, 0.1) var talking_sound_volume_db: float = -10.0

var _state: PlaybackState = PlaybackState.IDLE
var _active_label: RichTextLabel
var _active_canvas_item: CanvasItem
var _animation_target_alpha: float = 1.0
var _talking_sound_player: AudioStreamPlayer


func _ready() -> void:
	_talking_sound_player = AudioStreamPlayer.new()
	_talking_sound_player.stream = talking_sound
	_talking_sound_player.volume_db = talking_sound_volume_db
	if AudioServer.get_bus_index("Sfx") >= 0:
		_talking_sound_player.bus = "Sfx"
	add_child(_talking_sound_player)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("right"):
		advance()
		var viewport := get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


## Completes the current effect, or continues when the current line is complete.
## Connect an on-screen button's pressed signal to this method as well.
func advance() -> void:
	match _state:
		PlaybackState.TYPING:
			_active_label.visible_characters = -1
			_talking_sound_player.stop()
			_state = PlaybackState.WAITING
		PlaybackState.WAITING:
			advance_requested.emit()
			click_randomiser.play_random_stream()
		PlaybackState.ANIMATING:
			_active_canvas_item.modulate.a = _animation_target_alpha
			_state = PlaybackState.IDLE


## Types [param message] into [param label], then waits for the player to advance.
## Pass a positive [param speed] to override [member characters_per_second].
func say(label: RichTextLabel, message: String, speed: float = -1.0) -> void:
	_active_label = label
	label.text = message
	label.visible_characters = 0
	label.show()
	_state = PlaybackState.TYPING

	var typing_speed: float = speed if speed > 0.0 else characters_per_second
	var seconds_per_character: float = 1.0 / typing_speed
	var character_count: int = label.get_total_character_count()

	while label.visible_characters < character_count and _state == PlaybackState.TYPING:
		await get_tree().create_timer(seconds_per_character).timeout
		if _state == PlaybackState.TYPING:
			var character: String = message[label.visible_characters]
			label.visible_characters += 1
			if talking_sound != null and not SILENT_CHARACTERS.contains(character):
				_talking_sound_player.play()
			if PAUSING_PUNCTUATION.contains(character) and punctuation_pause > 0.0:
				await get_tree().create_timer(punctuation_pause).timeout

	label.visible_characters = -1
	_state = PlaybackState.WAITING
	await advance_requested
	_state = PlaybackState.IDLE
	_active_label.text = ""
	_active_label = null


## Fades [param item] in. Advancing during the fade completes it immediately.
func fade_in(item: CanvasItem, duration: float = 1.0) -> void:
	item.show()
	item.modulate.a = 0.0
	await _fade(item, 1.0, duration)


## Fades [param item] out and hides it. Advancing completes the fade immediately.
func fade_out(item: CanvasItem, duration: float = 1.0) -> void:
	await _fade(item, 0.0, duration)
	item.hide()


func _fade(item: CanvasItem, target_alpha: float, duration: float) -> void:
	_active_canvas_item = item
	_animation_target_alpha = target_alpha
	var starting_alpha: float = item.modulate.a

	_state = PlaybackState.ANIMATING
	if duration <= 0.0:
		item.modulate.a = target_alpha
		_state = PlaybackState.IDLE
		_active_canvas_item = null
		return

	var elapsed: float = 0.0
	while elapsed < duration and _state == PlaybackState.ANIMATING:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var weight: float = minf(elapsed / duration, 1.0)
		item.modulate.a = lerpf(starting_alpha, target_alpha, weight)

	item.modulate.a = target_alpha
	_state = PlaybackState.IDLE
	_active_canvas_item = null
