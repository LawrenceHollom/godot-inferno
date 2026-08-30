extends Control

@export var fire: Fire
@export var click_randomiser: AudioRandomiser

var is_leaving: bool

func _ready() -> void:
	GlobalState.transition_type = GlobalState.TransitionType.INTRO
	fire.set_intensity(0.75)
	is_leaving = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right") and not is_leaving:
		click_randomiser.play_random_stream()
		is_leaving = true
		GlobalState.audio_controller.play_transition()
		var tween: Tween = create_tween()
		tween.tween_method(fire.set_intensity, 0.75, 3.0, 2.25)
		tween.tween_callback(GlobalState.on_fade_out_finished)
