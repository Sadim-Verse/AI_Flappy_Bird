class_name Connection_Gene extends Resource

# Represent a synapse between two neurons

var in_node: int
var out_node: int
var weight: float
var enabled: bool = true
var innovation_number: int # For NEAT history tracking

func _init(_in: int, _out: int, _weight: float, _innov: int):
	in_node = _in
	out_node = _out
	weight = _weight
	innovation_number = _innov

# Useful for cloning genes during reproduction
func duplicate_gene() -> Connection_Gene:
	var clone = get_script().new(in_node, out_node, weight, innovation_number)
	clone.enabled = enabled
	return clone

