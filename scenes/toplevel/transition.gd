extends Control

@export var colour_rect: ColorRect
@export var texture_rect: TextureRect
@export var label: Label

@export var eyes: Array[Texture2D]
@export var babel: Texture2D
@export var tree: Texture2D
@export var flower: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()


func _on_transition_finished() -> void:
	GlobalState.on_transition_finished()