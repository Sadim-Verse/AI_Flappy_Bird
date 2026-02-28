extends CharacterBody2D

const GRAVITY: int = 1000	# determines how fast the bird false
const MAX_VEL: int = 600	# stabilizes the max fall speed
const FLAP_SPEED: int = -300	# how much the bird jumps up
var flying: bool = false
var falling: bool = false 
const START_POS = Vector2(100, 100)

# NEAT VARIABLES
var brain: Neural_Network		# The bird's brain
var fitness: float =0.0			# How well this bird is doing
var alive: bool = true			# Is the bird still playing
var get_pipe_callback: Callable		# A way for the bird to ask the Main scene where the pipes are
# -------------------------------------



# Called when the node enters the scene tree for the first time
func _ready():
	reset()


# Called every frame, 'delta' is the elapsed time since the previous frame
func _physics_process(delta):
	
	# NEAT DECISION LOGIC
	if alive and flying and brain != null:
		fitness += delta	# Survive longer = better fitness
		
		# Ask main game where next pipe is
		var next_pipe_pos = get_pipe_callback.call(global_position.x)
		var screen_height = get_viewport_rect().size.y
		
		# Setup the 3 inputs(normalized between 0 and 1)
		var input_bird_y = global_position.y/screen_height
		var input_dist_x = (next_pipe_pos.x - global_position.x) / get_viewport_rect().size.x
		var input_gap_y = next_pipe_pos.y / screen_height
		
		# Activate the brain
		var outputs = brain.acticate(([input_bird_y, input_dist_x, input_gap_y]))
		
		# If brain's output is > 0.5, flap
		if outputs[0] > 0.5 and velocity.y > 0: # Added velocity check so it doesn't flap infinitely upward
			flap()
	# -------------------------------------------------
	
	in_air(delta)

# Check if the bird is in the air and apply gravity
func in_air(delta):
	if flying or falling:
		velocity.y += GRAVITY * delta
		# terminal velocity
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play("fly")
		elif falling:
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		var collision = move_and_collide(velocity * delta)
		
		# NEAT DEATH LOGIC
		if collision and alive:
			die()
		if (global_position.y < 0 or global_position.y > get_viewport_rect().size.y) and alive:
			die()		# Die if it goes off screen
		# --------------------------------
	else:
		$AnimatedSprite2D.stop()

# Reset the bird position and state
func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)

# Allow the bird to fly upwards
func flap():
	velocity.y = FLAP_SPEED

# DIE FUNCTION
func die():
	alive = false
	falling = true
	flying = false
	# Hide the bird or make it semi-transparent so it doesn't clutter the screen
	modulate.a = 0.2
