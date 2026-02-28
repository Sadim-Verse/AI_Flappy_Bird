class_name Node_Gene extends Resource

# Represent a Neuron

enum Type {INPUT, HIDDEN, OUTPUT}
var id: int
var type: Type
var bias: float # Optional

func _init(_id: int, _type: Type):
	id = _id
	type = _type

#func duplicate_gene() -> Node_Gene:
#	return Node_Gene.new(id, type)
	
# Add this at the bottom of your Node Gene script
func duplicate_gene():
	return get_script().new(id, type)
