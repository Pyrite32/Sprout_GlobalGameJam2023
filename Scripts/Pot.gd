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

onready var root = preload("res://Scenes/PseudoRoot.tscn")

export var isStatic : bool
export var forceInitialConnection: bool
export var length: float = 200.0
var first_spawn : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	$UptakeRange/CollisionShape2D.shape.radius = length / 3
	first_spawn = global_position
	if forceInitialConnection:
		var sprout = get_parent().get_node("Sprout")
		if sprout != null:
			forge_bond_with(sprout)
	if isStatic:
		$Sprite.frame = 1
		$Collider.disabled = true
		gravity_scale = 0
	else:
		$UptakeRange.monitorable = false
		$UptakeRange.monitoring = false
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
	if state.linear_velocity.length() - prev_vector.length() > 200.0:
		state.linear_velocity = Vector2.ZERO
		
		
	
	
func forge_bond_with(sprout):
	if isStatic:
		print("bondmake!")
		if sprout.bond != null:
			sprout.bond.queue_free()
		if root == null:
			root = load("res://Scenes/PseudoRoot.tscn")
		var new_bond = root.instance()
		add_child(new_bond)
		new_bond.set_as_toplevel(true)
		new_bond.global_position = global_position
		new_bond.bind_root_target(sprout)
		new_bond.maximum_length = length
		new_bond.pull_threshold = 0.7 * length
		sprout.bond = new_bond
	pass
	
func sever_bond(sprout):
	sprout.bond.queue_free()
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


func _on_UptakeRange_body_entered(body):
	if (body.name == "Sprout"):
		print("interesting")
		body.bind_of_interest = self


func _on_UptakeRange_body_exited(body):
	if (body.name == "Sprout"):
		print("Goodbye!")
		body.bind_of_interest = null
