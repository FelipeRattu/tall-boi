extends Node2D

func _ready():
	GameManager.currentLevel = "9"


func _on_LevelEnding_body_entered(body):
	get_tree().change_scene("res://Scenes/Levels/Level10.tscn")
