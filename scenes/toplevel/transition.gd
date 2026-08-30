extends Control

@export var colour_rect: ColorRect
@export var texture_rect: TextureRect
@export var label: Label

@export var eyes: Array[Texture2D]
@export var death: Array[Texture2D]
@export var babel: Texture2D
@export var tree: Texture2D
@export var flower: Texture2D

@export var drum: AudioStreamPlayer

const ANIMATION_DELAY: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    label.text = ""
    texture_rect.visible = false
    var tween := create_tween()
    _set_palette(tween, GlobalState.current_palette)
    match GlobalState.transition_type:
        GlobalState.TransitionType.INTRO:
            _play_intro_transition(tween)
        GlobalState.TransitionType.SHORT:
            _play_short_transition(tween)
        GlobalState.TransitionType.LONG:
            _play_long_transition(tween)
        GlobalState.TransitionType.OUTRO:
            _play_outro_transition(tween)
    if GlobalState.transition_type != GlobalState.TransitionType.OUTRO:
        tween.tween_callback(_on_transition_finished)
            

func _play_intro_transition(tween: Tween):
    tween.tween_interval(ANIMATION_DELAY)
    _open_eye(tween)
    _set_text_size(tween, 2)
    _full_text_inferno(tween)
    _set_palette(tween, GlobalState.next_palette)
    _flash_image(tween, death[0])
    _set_text_size(tween, 4)
    _full_text_inferno(tween)
    _flash_image(tween, death[1])
    _set_text_size(tween, 6)
    _full_text_inferno(tween)
    _flash_image(tween, death[2])
    _set_text_size(tween, 8)
    _full_text_inferno(tween)

            

func _play_long_transition(tween: Tween):
    GlobalState.audio_controller.play_transition()
    tween.tween_interval(ANIMATION_DELAY)
    _set_text_size(tween, 7)
    _stepped_inferno(tween)
    _open_eye(tween)
    _set_text_size(tween, 3)
    _full_text_inferno(tween)
    _set_palette(tween, GlobalState.next_palette)
    _set_text_size(tween, 5)
    _full_text_inferno(tween)
    _flash_image(tween, tree)
    _set_text_size(tween, 7)
    _full_text_inferno(tween)
    _flash_image(tween, flower)
    _set_text_size(tween, 9)
    _full_text_inferno(tween)
    _flash_image(tween, babel)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_interval(ANIMATION_DELAY)


func _play_short_transition(tween: Tween):
    tween.tween_interval(ANIMATION_DELAY)
    var textures: Array[Texture2D] = [babel, tree, flower]#, candle, axe, grave]
    _full_text_inferno(tween)
    _flash_image(tween, textures[randi_range(0, len(textures) - 1)])
    _full_text_inferno(tween)
    _set_palette(tween, GlobalState.next_palette)
    _full_text_inferno(tween)
    _flash_image(tween, textures[randi_range(0, len(textures) - 1)])
    _full_text_inferno(tween)


func _play_outro_transition(tween: Tween):
    GlobalState.audio_controller.play_transition()
    tween.tween_interval(ANIMATION_DELAY)
    _close_eye(tween)
    _full_text_inferno(tween)
    _flash_image(tween, babel)
    _full_text_inferno(tween)
    _flash_image(tween, tree)
    _full_text_inferno(tween)
    _flash_image(tween, flower)
    _full_text_inferno(tween)


func _set_text_size(tween: Tween, mult: int) -> void:
    tween.tween_callback(label.add_theme_font_size_override.bind("font_size", 16 * mult))


func _stepped_inferno(tween: Tween) -> void:
    tween.tween_callback(set_label_text.bind("IN"))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_label_text.bind("FER"))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_label_text.bind("NO"))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_label_text.bind(""))
    tween.tween_interval(ANIMATION_DELAY)


func _full_text_inferno(tween: Tween) -> void:
    tween.tween_callback(set_label_text.bind("INFERNO"))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_label_text.bind(""))


func _open_eye(tween: Tween) -> void:
    tween.tween_callback(set_image_visibility.bind(true))
    tween.tween_callback(set_image.bind(eyes[2]))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image.bind(eyes[1]))
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image.bind(eyes[0]))
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image_visibility.bind(false))

func _close_eye(tween: Tween) -> void:
    tween.tween_callback(set_image_visibility.bind(true))
    tween.tween_callback(set_image.bind(eyes[0]))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image.bind(eyes[1]))
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image.bind(eyes[2]))
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image_visibility.bind(false))


func _flash_image(tween: Tween, image: Texture2D) -> void:
    tween.tween_callback(set_image_visibility.bind(true))
    tween.tween_callback(set_image.bind(image))
    tween.tween_callback(drum.play)
    tween.tween_interval(ANIMATION_DELAY)
    tween.tween_callback(set_image_visibility.bind(false))


func _set_palette(tween: Tween, palette: PaletteData.Palette) -> void:
    tween.tween_callback(_set_palette_now.bind(palette))

func _set_palette_now(palette: PaletteData.Palette) -> void:
    var light_colour := PaletteData.get_light(palette)
    var medium_colour := PaletteData.get_medium(palette)
    var dark_colour := PaletteData.get_dark(palette)

    label.add_theme_color_override("font_color", light_colour)
    colour_rect.color = dark_colour

    var image_material := texture_rect.material as ShaderMaterial
    image_material.set_shader_parameter("target_light", light_colour)
    image_material.set_shader_parameter("target_medium", medium_colour)
    image_material.set_shader_parameter("target_dark", dark_colour)


func set_label_text(text: String) -> void:
    label.text = text

func set_image_visibility(vis: bool) -> void:
    texture_rect.visible = vis

func set_image(texture: Texture2D) -> void:
    texture_rect.texture = texture


func _on_transition_finished() -> void:
    GlobalState.on_transition_finished()
