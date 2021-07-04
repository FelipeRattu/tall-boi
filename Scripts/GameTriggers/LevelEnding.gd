extends Area2D

#export(int) var index
#var scenes = [
#	"res://Scenes/Levels/Level1.tscn",
#	"res://Scenes/Levels/Level2.tscn",
#	"res://Scenes/Levels/Level 3.tscn",
#	"res://Scenes/Levels/Level 4.tscn",
#	"res://Scenes/Levels/CongratulationsLevel.tscn"
#]
#
#
#func _on_LevelEnding_body_entered(body):
#	if body.is_in_group("Player"):
#		get_tree().change_scene(scenes[index])


func _on_DetectionZone_body_entered(body):
	if body.is_in_group("Player"):
		$VortexSound.play()
