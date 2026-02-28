extends Area2D # Or whatever your pipe extends

signal hit
signal scored

var has_scored: bool = false # Prevents 50 birds from triggering 50 points

# This is your function for when a bird hits the actual pipe
func _on_body_entered(body):
	# Instead of emitting a generic 'hit' signal, we tell the specific bird to die!
	if body.has_method("die"):
		body.die()

# This is your function for the Area2D in the gap between the pipes
func _on_score_area_body_entered(body):
	if not has_scored and body.has_method("die"):
		scored.emit()
		has_scored = true # Lock it so the other 49 birds don't give extra points
