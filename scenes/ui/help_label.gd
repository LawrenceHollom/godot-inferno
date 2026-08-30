extends Label


var time_since_text_set: float
var is_text_displayed: bool

const TEXT_DURATION: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalState.help_text_set.connect(_on_help_text_set)
	is_text_displayed = false
	text = ""


func _on_help_text_set() -> void:
	time_since_text_set = 0.0
	is_text_displayed = true
	text = GlobalState.help_text


func _process(delta: float) -> void:
	time_since_text_set += delta
	if is_text_displayed and time_since_text_set > TEXT_DURATION:
		text = ""
		is_text_displayed = false
