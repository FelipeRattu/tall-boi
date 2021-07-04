extends CanvasLayer

func _ready():
	GameManager.can_pause = false
	GameManager.enable_music_filter(true)
	GameManager.set_ui_visibility(false)

func _input(event):
	if event.is_action_pressed("ui_restart"):
		GameManager.firstPlay = true
		get_tree().change_scene("res://Scenes/Levels/Level1.tscn")
	if event.is_action_pressed("ui_mute") and !GameManager.mute:
		GameManager.mute = true
		$MuteLabel.visible = false
		$UnmuteLabel.visible = true
	elif event.is_action_pressed("ui_mute") and GameManager.mute:
		GameManager.mute = false
		$MuteLabel.visible = true
		$UnmuteLabel.visible = false


func _on_Twitter_button_down():
	OS.shell_open("https://twitter.com/FelipeRattu")


func _on_Twitch_button_down():
	OS.shell_open("https://www.twitch.tv/feliperattu")
