extends RigidBody2D
class_name Pot

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var can_be_picked_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PickupRange_area_entered(area):
	print("from pot!")
	can_be_picked_up = true


func _on_PickupRange_area_exited(area):
	can_be_picked_up = false
