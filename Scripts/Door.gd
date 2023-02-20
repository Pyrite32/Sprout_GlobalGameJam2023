extends Node2D

export var id: int


func open(a):
	print(self.name + " door has been opened")
	if a == id:
		$Collider/AnimationPlayer.play("open")


func close(a):
	print(self.name + " door has been closed")
	if a == id:
		$Collider/AnimationPlayer.play("close")


