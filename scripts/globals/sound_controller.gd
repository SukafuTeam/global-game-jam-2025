extends Node

# SFX Fields
@export_subgroup("SFX")
@export var sfx_bus: String = "Master"
@export var num_players: int = 12
var available: Array[AudioStreamPlayer] = []
var queue: Array[SoundEffect] = []

# bgm Fields
@export_subgroup("BGM")
@export var bgm_bus: String = "Master"
@onready var bgm_player: AudioStreamPlayer = $bgm
@export var initial_bgm_volume: float = 0.8
var current_bgm_name: String = ""

func _ready():
	bgm_player.volume_db = linear_to_db(initial_bgm_volume)
	# For each possible effect we can play
	for i in num_players:
		# Create a new player
		var player = AudioStreamPlayer.new()
		# Adds it to the scene
		add_child(player)
		# Adds it to the available array
		available.append(player)
		# Connects its finished signal to reenter the available array
		player.finished.connect(on_stream_finised.bind(player))
		# Set its audio bus
		player.bus = sfx_bus

#region: SFX Processing
func on_stream_finised(stream):
	available.append(stream)

func play_sfx(effect: AudioStream, volume: float = -1.0, pitch: float = -1.0):
	if effect == null:
		push_warning("Trying to play a null sfx")
		return
	
	# Adds a new effect to be played
	queue.append(SoundEffect.new(effect, volume, pitch))

func _process(_delta):
	# If there's no sounds to be played, or no available players, return early
	if queue.is_empty() or available.is_empty():
		return

	# Gets the player, and the effect to be played
	var player = available.pop_front() as AudioStreamPlayer
	var effect = queue.pop_front() as SoundEffect
	
	# Sets up stream and volume
	player.stream = effect.stream
	var f_volume = effect.volume if effect.volume != -1 else 1
	player.volume_db = linear_to_db(f_volume)
	
	var f_pitch = effect.pitch if effect.pitch != -1 else 1
	player.pitch_scale = f_pitch
	
	# And finally play the effect
	player.play()
#endregion

#region: bgm Processing
func change_bgm(new_name: String, stream: AudioStream):
	# If we're already playing this bgm, return
	if current_bgm_name == new_name:
		return
		
	# Or if the stream is null, with a warn
	if stream == null:
		push_warning("Trying to change bgm to a null stream")
		return
	
	current_bgm_name = new_name
	bgm_player.stop()
	bgm_player.stream = stream
	bgm_player.play()

func pause_bgm():
	bgm_player.stream_paused = true

func resume_bgm():
	bgm_player.stream_paused = false

func stop_bgm():
	bgm_player.stop()

func play_bgm():
	if bgm_player.stream == null:
		return
	
	bgm_player.play()
#endregion
