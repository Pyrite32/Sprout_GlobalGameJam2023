extends RigidBody2D
class_name Pot

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum { UNLIT, LIT}

var currentState = UNLIT
var intensity = 0.0
var can_be_picked_up = false
var prev_vector = Vector2.ZERO

export var isStatic : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if isStatic:
		$Sprite.frame = 1
		$Collider.disabled = true
		gravity_scale = 0
	else:
		$Sprite.frame = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if currentState == UNLIT:
		intensity = max(0.0, intensity-delta)
	if currentState == LIT:
		intensity = min(1.0, intensity+delta)
	$Sprite.material.set_shader_param("intensity", intensity)	
	
	pass

func _integrate_forces(state):
	pass

func _on_PickupRange_area_entered(area):
	print("from pot!")
	can_be_picked_up = true

func is_glowing():
	return currentState == LIT

func _on_PickupRange_area_exited(area):
	can_be_picked_up = false

func transition_state(string):
	if string == "lit":
		currentState = LIT
		$Particles2D.restart()
		$Particles2D.emitting = true
	if string == "unlit":
		currentState = UNLIT
		$Particles2D.emitting = false
