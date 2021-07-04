extends StateMachine

# The main AnimationPlayer handles the main states animations...
#... the SecondaryAnimationPlayer handles animations in between the states or transition animations

# Variable to get the path to the main AnimationPlayer node and avoid big lines of code
#onready var animation_player = parent.get_node("AnimationPlayer")
# Variable to get the path to the secondary AnimationPlayer node and avoid big lines of code
#onready var secondary_animation_player = parent.get_node("SecondaryAnimationPlayer")

# Signal to emit to the secondary state machine when player dies
signal died

# Adding the states as soon as the scene staerts and setting initial state do idle
func _ready():
	
	GameManager.enable_music_filter(false)
	
	parent.frame = 0
#	parent.apple_collision()
	
	# Setting default number of jumps according to the number the game designer typed in the editor
	parent.defaultNumberOfJumps = parent.numberOfJumps
	
	# Saving the value of canMoveXAxis before a jump
	parent.couldMoveXAxisBeforeJump = parent.canMoveXAxis
	
	parent.set_cameras_variables()
	
	add_state("Idle")
	add_state("Walk")
	add_state("Jump")
	add_state("Fall")
	add_state("Dead")
	call_deferred("set_state", states.Idle)


# Calling the input, velocity calculation, move and slide and check ground methods once in a physic time
func _state_logic(delta):
	
	parent.input_handling()
	
	parent.calculate_velocity(delta)
	
	parent.apply_movement()
	
	parent.check_ground()
	
	parent.apply_gravity(delta)
	
	parent.send_height_to_game_manager()
	
	match state:
		# If in WALK state accelerates the player towards maxSpeed using acceleration variable
		states.Walk:
#			parent.motion.x = lerp(parent.motion.x, parent.maxSpeed * parent.directionX, parent.acceleration)
			parent.motion.x = parent.defaultSpeed * parent.directionX
		# If in JUMP state makes the player jump, call funcions to toggle off raycasts for ground detection and...
		#... subtracts a digit from the number of jumps
		states.Jump:
			if parent.directionX != 0:
				parent.motion.x = parent.defaultAirSpeed * parent.directionX
				match parent.directionX:
					-1:
						parent.jump_sprite_control(true)
					1:
						parent.jump_sprite_control(false)
			# Disabling raycasts to avoid collision on the way up
			parent.toggle_raycasts("down", false)
			parent.canMoveXAxis = parent.canMoveInTheAir
			#checking if player still can jump in the air (double, triple or whatever jump)
			if parent.numberOfJumps <= 0:
				parent.can_jump = false
				parent.numberOfJumps = parent.defaultNumberOfJumps
		# If in FALL toggle the raycasts on again for ground detection and changes character weight
		states.Fall:
			if parent.directionX != 0:
				parent.motion.x = parent.defaultAirSpeed * parent.directionX
				match parent.directionX:
					-1:
						parent.jump_sprite_control(true)
					1:
						parent.jump_sprite_control(false)
			parent.toggle_raycasts("down", true)
		# If in DEAD state stops moving and fall
		states.Dead:
			parent.motion.x = 0
			

# Sets the conditions in witch each state should change to another and checks it once in a physic time
func _get_transition(delta):
	#PARAMETRIC VARIABLES/CONSTANTS:
	#directionX = input pressed left or right according to rule in parent
	#directionY = input pressed up or down according to rule in parent
	#can_jump = boolean variable wich determines if the player can jump or not
	#MINIMUM_VELOCITY_X = Minimum velocity in the X axis the player can go before stopping, set in parent
	#velocityX = Player speed in the X axis
	#velocityY = Player speed in the Y axis
	#is_grounded = Boolean variable to tell if the player's down raycast is coliding with the ground
	#is_dead = true if player died and false if not
	match state:
		states.Idle:
			if parent.directionY == -1 and parent.can_jump and !parent.is_dead:
				return states.Jump
			elif parent.directionX != 0 and parent.canMoveXAxis and !parent.is_dead:
				return states.Walk
			elif parent.velocityY >= 0 and !parent.is_grounded and !parent.is_dead:
				return states.Fall
			elif parent.is_dead:
				return states.Dead
		states.Walk:
			if parent.can_jump and parent.directionY == -1 and !parent.is_dead:
				return states.Jump
			elif parent.is_grounded and parent.directionX == 0:
				return states.Idle
			elif parent.velocityY >= 0 and !parent.is_grounded and !parent.is_dead:
				return states.Fall
			elif parent.is_dead:
				return states.Dead
		states.Jump:
			if parent.can_jump and parent.directionY == -1 and !parent.is_dead:
				return states.Jump
			elif parent.velocityY > 0 and !parent.is_dead:
				return states.Fall
			elif parent.is_dead:
				return states.Dead
		states.Fall:
			if parent.is_grounded and parent.velocityX < parent.MINIMUM_VELOCITY_X and !parent.is_dead:
				return states.Idle
			elif parent.is_grounded and parent.canMoveXAxis and !parent.is_dead:
				return states.Walk
			elif parent.can_jump and parent.directionY == -1 and !parent.is_dead:
				return states.Jump
			elif parent.is_dead:
				return states.Dead

# Executed once every time a state changes, useful to set the state animation or test if a state was changed correctly,
# can be used as well to set forces in jumps or anything that requires single execution
func _enter_state(new_state, old_state):
	match new_state:
		states.Idle:
			parent.idle()
			print("Idle")
		states.Walk:
			parent.walk(true)
			print("Walk")
		states.Jump:
			parent.jump()
			print("Jump")
		states.Fall:
			parent.weight = parent.weightDown
			parent.toggle_raycasts("down", true)
			# Checking if previous state was jump to prevent player from jumping in the air if falling on a hole
			if old_state != states.Jump:
				parent.can_jump = false
			parent.fall()
			print("Fall")
		states.Dead:
			parent.death()

# Executed once every time a state changes, but this time in the end of a state, useful for transition animations
func _exit_state(old_state, new_state):
	match old_state:
		states.Walk:
			parent.walk(false)
		states.Fall:
			# checking if the player is grounded so it can jump
			if parent.is_grounded:
				parent.can_jump = true
				parent.directionY = 0
#			secondary_animation_player.play("Land")
			print("Landed")
		states.Jump:
			parent.ceiling()
			print("Ceiling")
