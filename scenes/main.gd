extends Node

@export var pipe_scene: PackedScene

var scroll: int = 0
const SCROLL_SPEED: int = 4
var score
var screen_size: Vector2i
var ground_height: int
var pipes: Array = []
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 95

# Called when the node enters the scene tree for the first time
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	
	# We don't call new_game() here. The NeatManager will tell Main when to start!

func _process(delta):
	# The world always scrolls as long as the NeatManager says birds are alive
	scroll += SCROLL_SPEED
	if scroll >= screen_size.x:
		scroll = 0
		
	$Ground.position.x = -scroll
	
	for pipe in pipes:
		pipe.position.x -= SCROLL_SPEED

# The NeatManager calls this when a new generation begins
func reset_world():
	scroll = 0
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	score = 0
	$Score_label.text = "SCORE: 0"
	
	$Game_Over.hide()
	generate_pipes()
	$Pipe_timer.start()

func _on_pipe_timer_timeout():
	generate_pipes()

func scored():
	score += 1
	$Score_label.text = "SCORE: " + str(score)

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	# This gap Y position is what the AI needs to see!
	pipe.position.y = (screen_size.y - ground_height)/2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	
	pipe.scored.connect(scored)
	
	add_child(pipe)
	pipes.append(pipe)
	pipe.add_to_group("pipes") # Tag it so we can easily delete it on reset

# --- NEAT VISION FUNCTION ---
# The birds call this every frame to "look" at the upcoming pipe
func get_next_pipe_pos(bird_x: float) -> Vector2:
	if pipes.is_empty():
		return Vector2(bird_x + 500, screen_size.y / 2) # Default safe spot if no pipes exist yet
		
	var closest_x = INF
	var closest_pipe = null
	
	for pipe in pipes:
		# We add a 30 pixel offset so the bird keeps looking at the pipe 
		# until it has fully passed *through* it.
		if pipe.position.x + 30 > bird_x and pipe.position.x < closest_x:
			closest_x = pipe.position.x
			closest_pipe = pipe
			
	if closest_pipe:
		return closest_pipe.position
	else:
		return Vector2(bird_x + 500, screen_size.y / 2)
