extends CharacterBody2D
@export var game_over_scene: String = "res://scenes/game_over.tscn"
# Movement parameters
@export var jump_speed: float = 300.0  # Horizontal speed during jump
@export var min_jump_force: float = 300.0  # Minimum jump force
@export var max_jump_force: float = 1500.0  # Maximum jump force
@export var max_charge_time: float = 2  # Maximum time to charge jump (seconds)

# Physics parameters
@export var gravity: float = 980.0  # Gravity force

# Jump control variables
var jump_charge: float = 0.0  # Current jump charge
var is_charging: bool = false  # Whether we're charging a jump
var is_jumping: bool = false  # Whether we're currently in a jump

# Animation variables
@onready var animated_sprite = $AnimatedSprite2D  # Assumes you have an AnimatedSprite2D node

func _ready():

	add_to_group("character")
	if has_node("AnimatedSprite2D"):
		animated_sprite.animation = "idle"
		animated_sprite.play()

# This is the correct function name with underscores
func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
		if is_jumping:
			velocity.x += jump_speed
	else:
		# Reset jumping state when landing
		if is_jumping:
			is_jumping = false
			#velocity.x = 0  # Stop horizontal movement when landing
			play_animation("idle")
	
	# Handle jump charging
	if is_charging:
		jump_charge += delta
		jump_charge = min(jump_charge, max_charge_time)
	
	# Apply movement
	move_and_slide()
	
	# Print debug info
	if is_jumping:
		print("Jumping! Velocity: ", velocity)

func _input(event):
	# Space key pressed - start charging jump
	if event is InputEventKey and event.keycode == KEY_SPACE:
		if event.pressed and is_on_floor() and not is_charging:
			is_charging = true
			jump_charge = 0.0
			print("Started charging jump")
		
		# Space key released - execute jump if charging
		elif not event.pressed and is_charging:
			is_charging = false
			execute_jump()

func execute_jump():
	# Calculate jump force based on charge time
	var charge_percentage = jump_charge / max_charge_time
	var jump_force = min_jump_force + charge_percentage * (max_jump_force - min_jump_force)
	
	# Apply jump force (upward) and set horizontal movement (right)
	velocity.y = -jump_force
	velocity.x = jump_speed  # Start moving right during jump
	is_jumping = true
	
	# Play jump animation
	play_animation("jump")
	
	print("Executed jump! Velocity: ", velocity)

func update_animations():
	# This function ensures animations match the character state
	if is_jumping:
		play_animation("jump")
	elif is_on_floor():
		if is_charging:
			# Only try to play charging animation if it exists
			if animated_sprite.sprite_frames.has_animation("charging"):
				play_animation("charging")
			else:
				play_animation("idle")
		else:
			play_animation("idle")

func play_animation(anim_name: String):
	# Play the specified animation using AnimatedSprite2D
	if has_node("AnimatedSprite2D"):
		if animated_sprite.sprite_frames.has_animation(anim_name):
			if animated_sprite.animation != anim_name:
				print("Playing animation: ", anim_name)
				animated_sprite.animation = anim_name
				animated_sprite.play()


func _on_detectorarea_body_entered(body: Node2D) -> void:
	# Check if the body that entered is your character
	if body is CharacterBody2D:
		# Stop all movement of the character
		body.velocity = Vector2.ZERO
		
		# Reset jumping state if your character has this variable
		if "is_jumping" in body:
			body.is_jumping = false
		
		# Change animation to idle if your character has AnimatedSprite2D
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			if sprite.sprite_frames.has_animation("idle"):
				sprite.animation = "idle"
				sprite.play()
		
		# Print debug info
		print("Character entered detector area - movement stopped!")


func _on_deatharea_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		get_tree().change_scene_to_file(game_over_scene)
