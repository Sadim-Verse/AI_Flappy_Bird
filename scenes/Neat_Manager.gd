class_name Neat_Manager extends Node

@export var bird_scene: PackedScene # For Bird.tscn
@export var population_size: int = 50

var generation: int = 1
var population: Array[Genome] = []
var active_birds: Array = []
var global_innovation: int = 0

func _ready():
	# Create the very first generation of random brains
	for i in range(population_size):
		population.append(create_base_genome())
	
	# Start pipes and hide UI for Gen 1
	get_parent().reset_world()
	
	start_generation()

# Creates a basic brain with 3 inputs hooked directly to 1 output
func create_base_genome() -> Genome:
	var g = Genome.new()
	# Create 3 inputs (IDs 0, 1, 2) and 1 output (ID 3)
	g.nodes.append(Node_Gene.new(0, Node_Gene.Type.INPUT))
	g.nodes.append(Node_Gene.new(1, Node_Gene.Type.INPUT))
	g.nodes.append(Node_Gene.new(2, Node_Gene.Type.INPUT))
	g.nodes.append(Node_Gene.new(3, Node_Gene.Type.OUTPUT))
	
	# Connect inputs to output with random starting weights (-1.0 to 1.0)
	for i in range(3):
		var weight = randf_range(-1.0, 1.0)
		g.connections.append(Connection_Gene.new(i, 3, weight, i))
		
	return g

func start_generation():
	print("Starting Generation: ", generation)
	active_birds.clear()
	
	for genome in population:
		var bird = bird_scene.instantiate()
		bird.brain = Neural_Network.new(genome)
		bird.get_pipe_callback = Callable(get_parent(), "get_next_pipe_pos") # Link the vision
		
		add_child(bird)
		active_birds.append(bird)
		
		# Start the bird flying
		bird.flying = true

func _process(delta):
	# Check if all birds are dead
	var all_dead = true
	for bird in active_birds:
		if bird.alive:
			all_dead = false
			break
			
	if all_dead and active_birds.size() > 0:
		evolve_next_generation()

func evolve_next_generation():
	# Update fitness scores on the genomes
	for i in range(population_size):
		population[i].fitness = active_birds[i].fitness
		
	# Sort population by fitness (highest to lowest)
	population.sort_custom(func(a, b): return a.fitness > b.fitness)
	
	print("Best Fitness this Gen: ", population[0].fitness)
	
	var new_population: Array[Genome] = []
	
	# Elitism: Keep the top 5 birds exactly as they are
	for i in range(5):
		new_population.append(clone_genome(population[i]))
		
	# Mutate the rest based on the top performers
	while new_population.size() < population_size:
		# Pick a random top-performing bird (from the top 50%)
		var parent = population[randi() % (population_size / 2)]
		var child = clone_genome(parent)
		mutate_weights(child)
		new_population.append(child)
		
	# Cleanup old birds
	for bird in active_birds:
		bird.queue_free()
		
	# Reset pipes/game state here (You will need to call your game's reset function)
		get_parent().reset_world()
		
	population = new_population
	generation += 1
	start_generation()

# --- Helper Functions ---

func clone_genome(g: Genome) -> Genome:
	var clone = Genome.new()
	for n in g.nodes: clone.nodes.append(n.duplicate_gene())
	for c in g.connections: clone.connections.append(c.duplicate_gene())
	return clone

func mutate_weights(g: Genome):
	for conn in g.connections:
		if randf() < 0.8: # 80% chance to slightly tweak weight
			conn.weight += randf_range(-0.5, 0.5)
		elif randf() < 0.1: # 10% chance to completely randomize weight
			conn.weight = randf_range(-2.0, 2.0)

