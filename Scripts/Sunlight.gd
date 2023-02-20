extends Node2D


func _on_Area2D_body_entered(body:Node2D):
	if body.name == "Pot":
		body.call("transition_state", "lit")


func _on_Area2D_body_exited(body):
	if body.name == "Pot":
		body.call("transition_state", "unlit")
