extends Area2D

onready var hitbox = $AppleBox

signal makePlayerTaller

func _ready():
	$AppleAnimator.play("Idle")

func _on_Apple_body_entered(body):
	if body.is_in_group("Player"):
		$PickupSound.play()
		emit_signal("makePlayerTaller")
		disableApple()

func disableApple():
	hitbox.set_deferred("disabled", true)
	self.set_deferred("visible", false)
	set_process(false)
	set_physics_process(false)
	set_physics_process_internal(false)
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
