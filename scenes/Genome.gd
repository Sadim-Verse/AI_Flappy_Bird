class_name Genome extends Resource

# Acts as blueprint for one agent. Holds the list of nodes and connections

var id: int
var nodes: Array[Node_Gene] = [] 
var connections: Array[Connection_Gene] = []
var fitness: float = 0.0

# Helper to quickly find if a connection already exists
func connection_exists(in_node: int, out_node: int) -> bool:
	for conn in connections:
		if conn.in_node == in_node and conn.out_node == out_node:
			return true
	return false

# Used to classify species
func distance(other_genome: Genome) -> float:
	# Implement NEAT compatibility distance formula
	# c1 * Excess + c2 * Disjoint + c3 * WeightDiff
	return 0.0
