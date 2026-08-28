extends Node

@export var music: AudioStreamPlayer

var master_bus_index: int = AudioServer.get_bus_index("Master")
var music_bus_index: int = AudioServer.get_bus_index("Music")
var sfx_bus_index: int = AudioServer.get_bus_index("Sfx")

var has_music_started: bool

var master_volume: float = 0.67:
	set(value):
		master_volume = value
		AudioServer.set_bus_volume_db(master_bus_index, get_db(value))
	get:
		return master_volume

var music_volume: float = 0.67:
	set(value):
		music_volume = value
		AudioServer.set_bus_volume_db(music_bus_index, get_db(value))
	get:
		return music_volume

var sfx_volume: float = 0.67:
	set(value):
		sfx_volume = value
		AudioServer.set_bus_volume_db(sfx_bus_index, get_db(value))
	get:
		return sfx_volume

const SILENT: float = -1000
const NORMAL_POWER: float = 1
const SILENT_POWER: float = 0
const FADE_DURATION: float = 1.0


func get_db(volume: float) -> float:
	if volume < 0.001:
		return -10000
	else:
		return (volume * 30) - 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	has_music_started = true


func set_power(stream: AudioStreamPlayer, power: float) -> void:
	var db: float = log(power) / log(10)
	stream.volume_db = db


func stop_music() -> void:
	var tween: Tween = get_tree().create_tween()
	var lambda: Callable = func (power: float) -> void:
		set_power(music, power)
	tween.tween_method(lambda, NORMAL_POWER, SILENT_POWER, FADE_DURATION)
	await tween.finished
	music.stop()
	has_music_started = false


func play_music() -> void:
	music.play()
	has_music_started = true
	var lambda: Callable = func (power: float) -> void:
		set_power(music, power)
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(lambda, SILENT_POWER, NORMAL_POWER, FADE_DURATION)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if music.stream != null and not music.playing and has_music_started:
		music.play()
