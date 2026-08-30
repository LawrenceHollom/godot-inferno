class_name NarrativePresentation
extends Control

# What a crazy design decision to have this here.
enum Presentation {
    INTRO,
    PAST,
    ASHES,
	GAME,
}

const BACKGROUNDS_PATH := "res://assets/backgrounds"

@export var presentation: Presentation = Presentation.INTRO
@export var select_from_global_state: bool = true

@onready var background: ColorRect = $Background
@onready var image_layers: Control = $ImageLayers
@export var text_top: RichTextLabel
@export var text_middle: RichTextLabel
@export var text_bottom: RichTextLabel
@onready var advance_button: Button = $AdvanceButton
@onready var presentation_controller: PresentationController = $PresentationController

var _images: Dictionary[String, TextureRect] = {}
var _is_finishing: bool = false


func _ready() -> void:
    GlobalState.fade_out.connect(_on_fade_out)
    if select_from_global_state:
        var presentation_name: String = GlobalState.get_presentation_name()
        presentation = Presentation.get(presentation_name, Presentation.INTRO)
    run_presentation()


func run_presentation() -> void:
    var presentation_name: String = Presentation.keys()[presentation]
    var presentation_data: NarrativeData = GlobalState.get_narrative_data(presentation_name)
    if presentation_data == null:
        push_error("No presentation data found for '%s'." % presentation_name)
        _finish_presentation()
        return

    _apply_palette(presentation_data.palette)

    for action: Dictionary in presentation_data.actions:
        var action_type: String = str(action.get("type", "")).to_lower()
        var duration: float = float(action.get("duration", 1.0))

        match action_type:
            "text":
                var label: RichTextLabel = _get_text_label(str(action.get("position", "middle")))
                if label != null:
                    var speed: float = float(action.get("speed", -1.0))
                    var speaker: int = int(action.get("speaker", 0))
                    await presentation_controller.say(label, str(action.get("text", "")), speed, speaker)
            "fade_in":
                var image_in: TextureRect = _get_or_create_image(str(action.get("image", "")))
                if image_in != null:
                    await presentation_controller.fade_in(image_in, duration)
            "fade_out":
                var image_out: TextureRect = _get_existing_image(str(action.get("image", "")))
                if image_out != null:
                    await presentation_controller.fade_out(image_out, duration)
            _:
                push_warning("Unknown presentation action type '%s'." % action_type)

    _finish_presentation()

func _get_text_label(position: String) -> RichTextLabel:
    match position.to_lower():
        "top":
            return text_top
        "middle":
            return text_middle
        "bottom":
            return text_bottom
        _:
            push_warning("Unknown text position '%s'." % position)
            return null


func _get_or_create_image(filename: String) -> TextureRect:
    if filename.is_empty() or filename.get_file() != filename:
        push_warning("Background images must be specified by filename only: '%s'." % filename)
        return null
    if _images.has(filename):
        return _images[filename]

    var resource_path: String = BACKGROUNDS_PATH.path_join(filename)
    if not ResourceLoader.exists(resource_path, "Texture2D"):
        push_warning("Background image not found: %s" % resource_path)
        return null
    var texture: Texture2D = load(resource_path) as Texture2D
    if texture == null:
        push_warning("Could not load background image: %s" % resource_path)
        return null

    var image := TextureRect.new()
    image.name = filename.get_basename().validate_node_name()
    # image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    image.mouse_filter = Control.MOUSE_FILTER_IGNORE
    image.texture = texture
    image.expand_mode = TextureRect.EXPAND_KEEP_SIZE 
    image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED 
    image.hide()
    image_layers.add_child(image)
    _images[filename] = image
    return image


func _get_existing_image(filename: String) -> TextureRect:
    if not _images.has(filename):
        push_warning("Cannot fade out '%s' before it has been faded in." % filename)
        return null
    return _images[filename]


func _apply_palette(selected_palette: PaletteData.Palette) -> void:
    var light: Color = PaletteData.get_light(selected_palette)
    var medium: Color = PaletteData.get_medium(selected_palette)
    var dark: Color = PaletteData.get_dark(selected_palette)

    background.color = dark
    for label: RichTextLabel in [text_top, text_middle, text_bottom]:
        label.add_theme_color_override("default_color", light)

    advance_button.add_theme_color_override("font_color", dark)
    advance_button.add_theme_color_override("font_hover_color", dark)
    advance_button.add_theme_color_override("font_pressed_color", dark)
    var button_style := StyleBoxFlat.new()
    button_style.bg_color = medium
    button_style.anti_aliasing = false
    advance_button.add_theme_stylebox_override("normal", button_style)
    advance_button.add_theme_stylebox_override("hover", button_style)
    advance_button.add_theme_stylebox_override("pressed", button_style)


func _finish_presentation() -> void:
    if _is_finishing:
        return
    _is_finishing = true
    GlobalState.next_standard_scene()


func _on_advance_button_pressed() -> void:
    presentation_controller.advance()


func _on_fade_out() -> void:
    GlobalState.on_fade_out_finished()
