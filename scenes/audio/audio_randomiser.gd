extends Node

class_name AudioRandomiser

@export var streams: Array[AudioStream] = []

@export var volume_db: float = 0.0

var players: Array[AudioStreamPlayer] = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var is_playing_continuously: bool = false
var current_player: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	for stream: AudioStream in streams:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.stream = stream
		player.bus = "Sfx"
		player.volume_db = volume_db
		add_child(player)
		players.append(player)


func play_random_stream() -> void:
	if players.is_empty():
		return
	current_player = rng.randi_range(0, players.size() - 1)
	players[current_player].play()


func play_continuously() -> void:
	is_playing_continuously = true


## Stops whatever is sounding right now and cancels continuous playback.
## Used to cut the scroll loop off once a ScrollingNumber reaches its target.
func stop_current_stream() -> void:
	is_playing_continuously = false
	if current_player < players.size():
		players[current_player].stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if players.is_empty():
		return
	if is_playing_continuously && !players[current_player].playing:
		play_random_stream()
