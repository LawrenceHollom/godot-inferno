extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	timer.timeout.connect(_on_transition_finished)


func _on_transition_finished() -> void:
	GlobalState.on_transition_finished()