extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var door_id: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open(a):
	if a == door_id:
		$AnimationPlayer.play("open")
	
func close(a):
	if a == door_id:
		$AnimationPlayer.play("close")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
