extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var id: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open(a):
	print("open door")
	if a == id:
		$Collider/AnimationPlayer.play("open")
	
func close(a):
	print("close door")
	if a == id:
		$Collider/AnimationPlayer.play("close")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
