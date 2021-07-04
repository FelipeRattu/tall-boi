extends Node2D

func _ready():
	GameManager.currentLevel = "8"


func _on_LevelEnding_body_entered(body):
	get_tree().change_scene("res://Scenes/Levels/Level9.tscn")
