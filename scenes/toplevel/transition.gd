extends Control

@export var colour_rect: ColorRect
@export var texture_rect: TextureRect
@export var label: Label

@export var eyes: Array[Texture2D]
@export var babel: Texture2D
@export var tree: Texture2D
@export var flower: Texture2D

const ANIMATION_DELAY: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween := create_tween()
	label.text = ""
	texture_rect.visible = false
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind("IN"))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind("FER"))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind("NO"))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind(""))
	tween.tween_callback(set_image_visibility.bind(true))
	tween.tween_callback(set_image.bind(eyes[2]))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_image.bind(eyes[1]))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_image.bind(eyes[0]))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind("INFERNO"))
	tween.tween_callback(set_image_visibility.bind(false))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind(""))
	tween.tween_callback(set_image_visibility.bind(true))
	tween.tween_callback(set_image.bind(tree))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind("INFERNO"))
	tween.tween_callback(set_image_visibility.bind(false))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind(""))
	tween.tween_callback(set_image_visibility.bind(true))
	tween.tween_callback(set_image.bind(flower))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind("INFERNO"))
	tween.tween_callback(set_image_visibility.bind(false))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(set_label_text.bind(""))
	tween.tween_callback(set_image_visibility.bind(true))
	tween.tween_callback(set_image.bind(babel))
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_interval(ANIMATION_DELAY)
	tween.tween_callback(_on_transition_finished)



func set_label_text(text: String) -> void:
	label.text = text

func set_image_visibility(vis: bool) -> void:
	texture_rect.visible = vis

func set_image(texture: Texture2D) -> void:
	texture_rect.texture = texture


func _on_transition_finished() -> void:
	GlobalState.on_transition_finished()