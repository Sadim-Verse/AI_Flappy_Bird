class_name Neural_Network extends RefCounted

var genome: Genome
var node_cache: Dictionary = {}
var input_nodes: Array[int] = []
var output_nodes: Array[int] = []

func _init(_genome: Genome):
	genome = _genome
	
	# Categorize our nodes so we know where to start and end
	for node in genome.nodes:
		if node.type == Node_Gene.Type.INPUT:
			input_nodes.append(node.id)
		elif node.type == Node_Gene.Type.OUTPUT:
			output_nodes.append(node.id)

# Function called by Bird at every frame
func acticate(inputs: Array) -> Array:
	node_cache.clear()		# Reset calculations for this frame
	# Feed the raw game into the input nodes
	# Assume 'input' array matches the order of 'input_nodes'
	for i in range(inputs.size()):
		if i < input_nodes.size():
			node_cache[input_nodes[i]] = inputs[i]
	
	# Ask the output nodes fot their final values
	var outputs: Array = []
	for out_id in output_nodes:
		outputs.append(get_node_value(out_id))
	
	return outputs

# Recursive function to trace backwards through the network
func get_node_value(node_id: int) -> float:
	# If we already calculated this node this frame, return the saved value
	if node_cache.has(node_id):
		return node_cache[node_id]
	
	# Otherwise, calculate it
	var sum: float = 0.0
	
	# Find all connections coming INTO this node
	for conn in genome.connections:
		if conn.out_node == node_id and conn.enabled:
			# Recursively get the value of the node feeding into this one, and multiply it by the connection's weight
			sum += get_node_value(conn.in_node) * conn.weight
			
	# Pass the sum through our Activation Function
	var final_value = sigmoid(sum)
	
	# Save it in the cache so we don't calculate it again this frame
	node_cache[node_id] = final_value
	
	return final_value


# The Sigmoid activation
func sigmoid(x: float) -> float:
	# cap x to prevent math overflow
	x = clamp(x, -20.0, 20.0)
	return 1.0/(1.0 + exp(-x))













