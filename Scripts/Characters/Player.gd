extends KinematicBody2D

# Gravity Related
const GRAVITY = 400
const MINIMUM_VELOCITY_X = 0.2

# Body Related
export (float) var weightUp
export (float) var weightDown
var weight = 0

# Control Related
export (bool) var canMoveXAxis
export (bool) var canMoveInTheAir
var couldMoveXAxisBeforeJump
var motion = Vector2.ZERO
var directionX = 0
var directionY = 0
var velocityX = 0
var velocityY = 0

# Speed Related
export (float) var acceleration
export (float) var maxSpeed
export (float) var friction
export (float) var speedBreak

export (float) var defaultSpeed
export (float) var defaultAirSpeed

# Jump Related
export (float) var jumpForce
export (int) var numberOfJumps
var defaultNumberOfJumps
var can_jump = false
var is_grounded = true

# Death Related
var is_dead = false
var died_by_falling = false

# Size related
var frame = 0
var enemyFrame
export(Array, NodePath) var colliders

# Camera Related
var levelCamera
var myCamera

func set_cameras_variables():
	levelCamera = get_parent().get_node("LevelCamera")
	myCamera = $PlayerCamera

# Apply the movement on KinematicBody2D
func apply_movement():
	motion = move_and_slide(motion)

# Uniting all the input related methods in one call
func input_handling():
	x_axis_controller()
#	y_axis_controller()
	
	if Input.is_action_just_pressed("ui_restart"):
		get_tree().reload_current_scene()
		
	zoom_controller()

# Using delta calculates the speed in witch the player is moving in the X and Y axis and stores in variables
func calculate_velocity(delta):
	velocityX = int(motion.x / delta)
	velocityY = int(motion.y / delta)

# Logic for controlling the player left and right or toggle on/off
func x_axis_controller():
	# Checks if player can move in the X axis
	if canMoveXAxis and myCamera.current:
		# Get the input integer
		# 1  = pressed right
		# 0  = unpressed
		# -1 = pressed left
		directionX = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	else:
		directionX = 0

# Logic for controlling the jump and Y axys commands (to toggle off just set numberOfJumps to 0 in the editor)
func y_axis_controller():
	# Get the input integer
	# -1  = pressed up
	# 0  = unpressed
	# 1 = pressed down
	directionY = -int(Input.is_action_just_pressed("ui_up")) + int(Input.is_action_just_pressed("ui_down"))

func zoom_controller():
	if get_parent().name != "Level 10":
		if Input.is_action_pressed("ui_zoom"):
			if myCamera.current:
				levelCamera.set_deferred("current", true)
				myCamera.set_deferred("current", false)
		if Input.is_action_just_released("ui_zoom"):
			levelCamera.set_deferred("current", false)
			myCamera.set_deferred("current", true)

# Usign Raycasts to check if player in on the ground
func check_ground():
	for raycast in $DownRaycasts.get_children():
		if raycast.is_colliding():
			is_grounded = true
			if couldMoveXAxisBeforeJump:
				canMoveXAxis = true
		else:
			is_grounded = false

# Toggles on/off any of the raycasts in the player scene
func toggle_raycasts(whichRaycast, toggle):
	if whichRaycast == "down":
		for raycast in $DownRaycasts.get_children():
			raycast.enabled = toggle

# Applies gravity and weight to the player
func apply_gravity(delta):
	motion.y += (GRAVITY + weight) * delta

func _on_Enemy_hitPlayer(enemyFrame):
	calculate_damage(enemyFrame)

func _on_Apple_makePlayerTaller():
	directionY = -1
	lastIndex = frame
	if frame < 4:
		frame += 1
		$PlayerSprite.frame = frame
		tweak_collision(frame)

onready var collider = $PlayerCollision

func calculate_damage(enemyFrame):
	if enemyFrame < $PlayerSprite.frame:
		$PlayerSprite.frame -= (enemyFrame + 1)
	else:
		is_dead = true
	
	frame = $PlayerSprite.frame
	tweak_collision($PlayerSprite.frame)

onready var lastIndex = 0

func tweak_collision(index):
	get_node(colliders[lastIndex]).visible = false
	get_node(colliders[lastIndex]).set_deferred("disabled", true)
	get_node(colliders[index]).visible = true
	get_node(colliders[index]).set_deferred("disabled", false)
	lastIndex = index

func send_height_to_game_manager():
	GameManager.currentPlayerHeight = $PlayerSprite.frame

func walk(toggle : bool):
	if toggle:
		$PlayerAnimator.play("Walk")
		if directionX > 0:
			$PlayerSprite.flip_h = false
			$WalkParticles.position = Vector2(-4.43, 9)
			$WalkParticles.gravity = Vector2(-50, 5)
		elif directionX < 0:
			$PlayerSprite.flip_h = true
			$WalkParticles.position = Vector2(4.57, 9)
			$WalkParticles.gravity = Vector2(50, 5)
	$WalkParticles.emitting = toggle

func idle():
	motion.x = 0
	$PlayerAnimator.play("Idle")

func jump():
	weight = weightUp
	numberOfJumps -= 1
	if motion.y > 0:
		motion.y = 0
	motion.y -= jumpForce
	$PlayerAnimator.play("Jump")

func jump_sprite_control(toggle : bool):
	$PlayerSprite.flip_h = toggle

func fall():
	$PlayerAnimator.play("Jump")

func ceiling():
	$PlayerAnimator.play("Fall")

func death():
	$PlayerAnimator.play("Death")
	$DeathSound.play()
	GameManager.enable_music_filter(true)
