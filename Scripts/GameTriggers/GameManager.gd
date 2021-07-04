extends CanvasLayer

var currentLevel : String
var currentPlayerHeight : int
var firstPlay : bool = true

var can_pause : bool = false
var mute : bool = false

func _ready():
	$GameMusic.play()

func _process(delta):
	$TallMeterSprite.frame = currentPlayerHeight
	$LevelNumber.text = currentLevel
	if mute:
		AudioServer.set_bus_mute(0, true)
	elif !mute:
		AudioServer.set_bus_mute(0, false)
	
func set_ui_visibility(toggle : bool):
	$LevelLabel.set_deferred("visible", toggle)
	$LevelNumber.set_deferred("visible", toggle)
	$RestartLabel.set_deferred("visible", toggle)
	$TallMeterLabel.set_deferred("visible", toggle)
	$TallMeterSprite.set_deferred("visible", toggle)

func enable_music_filter(toggle : bool):
	AudioServer.set_bus_effect_enabled(1, 0, toggle)
