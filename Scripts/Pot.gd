extends RigidBody2D
class_name Pot

enum { UNLIT, LIT }

var currentState = UNLIT
var intensity = 0.0
var can_be_picked_up = false
var prev_vector = Vector2.ZERO

onready var root = preload("res://Scenes/PseudoRoot.tscn")

export var isStatic : bool
export var forceInitialConnection: bool
export var length: float = 200.0


func _ready():
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


func _process(delta):
	if currentState == UNLIT:
		intensity = max(0.0, intensity-delta)
	if currentState == LIT:
		intensity = min(1.0, intensity+delta)
	$Sprite.material.set_shader_param("intensity", intensity)	


func forge_bond_with(sprout):
	if isStatic:
		print(self.name + " made bond with " + sprout.name)
		
		if sprout.bond != null:
			sprout.bond.queue_free()
		var new_bond = root.instance()
		new_bond.init($RootAttachPosition)
		add_child(new_bond)
		new_bond.set_as_toplevel(true)
		new_bond.global_position = global_position
		new_bond.bind_root_target(sprout)
		new_bond.maximum_length = length
		new_bond.pull_threshold = 0.7 * length
		sprout.bond = new_bond


func sever_bond(sprout):
	sprout.bond.queue_free()


func _on_PickupRange_area_entered(area):
	print(area.name + " has entered the range of " + self.name)
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
		print(self.name + " is in uptake range of " + body.name)
		body.bind_of_interest = self


func _on_UptakeRange_body_exited(body):
	if (body.name == "Sprout"):
		print(body.name + " is no longer in uptake range of " + body.name)
		body.bind_of_interest = null
