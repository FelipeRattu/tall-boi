extends Popup


func _input(event):
	if GameManager.can_pause:
		if event.is_action_pressed("ui_pause") and get_tree().paused == false:
			get_tree().paused = true
			self.popup_centered()
		elif event.is_action_pressed("ui_pause"):
			self.hide()
			get_tree().paused = false
