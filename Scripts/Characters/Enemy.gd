extends StaticBody2D

export(Array, NodePath) var colliders
export(Array, NodePath) var hitboxes

export(bool) var flippedSprite

export var frame : int = 0

signal hitPlayer

func _ready():
	$EnemySprite.frame = frame
	tweak_collision(true)
	$EnemyAnimator.play("Idle")
	$EnemySprite.flip_h = !flippedSprite

func _on_EnemyHitbox_body_entered(body):
	if body.is_in_group("Player"):
		var playerFrame = body.get_node("PlayerSprite").frame
		calculate_damage(playerFrame)

func calculate_damage(playerFrame):
	if playerFrame < $EnemySprite.frame:
		
		$EnemySprite.frame -= (playerFrame + 1)
		tweak_collision(false)
	else:
		$EnemyAnimator.play("Die")
	
	emit_signal("hitPlayer", frame)

var lastIndex

func tweak_collision(onReady):
	var index = $EnemySprite.frame
	if onReady:
		get_node(colliders[index]).visible = true
		get_node(colliders[index]).set_deferred("disabled", false)
		get_node(hitboxes[index]).visible = true
		get_node(hitboxes[index]).set_deferred("disabled", false)
		lastIndex = index
	else:
		get_node(colliders[lastIndex]).visible = false
		get_node(colliders[lastIndex]).set_deferred("disabled", true)
		get_node(colliders[index]).visible = true
		get_node(colliders[index]).set_deferred("disabled", false)
		get_node(hitboxes[lastIndex]).visible = false
		get_node(hitboxes[lastIndex]).set_deferred("disabled", true)
		get_node(hitboxes[index]).visible = true
		get_node(hitboxes[index]).set_deferred("disabled", false)
		lastIndex = index


func _on_EnemyAnimator_animation_finished(anim_name):
	if anim_name == "Die":
		self.queue_free()
