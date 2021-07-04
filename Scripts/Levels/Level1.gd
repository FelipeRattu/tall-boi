extends Node2D


func _ready():
	GameManager.mute = false
	GameManager.currentLevel = "1"


func _on_LevelEnding_body_entered(body):
	get_tree().change_scene("res://Scenes/Levels/Level2.tscn")
