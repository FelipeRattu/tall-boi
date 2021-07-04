extends CanvasLayer

func _ready():
	GameManager.set_ui_visibility(false)
	if GameManager.firstPlay:
		$StartPopup.popup_centered()
		get_tree().paused = true
	else:
		GameManager.set_ui_visibility(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		$StartPopup.hide()
		get_tree().paused = false
		GameManager.firstPlay = false
		GameManager.set_ui_visibility(true)
		GameManager.can_pause = true
