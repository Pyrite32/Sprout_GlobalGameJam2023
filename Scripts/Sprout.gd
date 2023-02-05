extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var Acceleration: float = 40.0
export var WalkSpeed: float = 110.0
export var Friction: float = 200.0
export var GRAVITY : float = 20.0
export var JumpHeight: float = 30.0
export var RetractSpeed: float = 100.0
export var is_first_sprout = false

var impulses : Vector2
var velocity : Vector2

var can_buffer_jump = false
var can_coyote_jump = true
var jumped_already = false;
var can_pick_up = false
var potReference : RigidBody2D
var bond = null;
var bind_of_interest = null;


var potRef : Node2D
var frozen = true


var potSlowdown = 0.0

onready var Buffer = $Buffer
onready var Coyote = $Coyote
onready var Anim = $AnimatedSprite

onready var PotScene = preload("res://Scenes/Pot.tscn")

enum State { EMPTY, CARRY, CARRY_SWITCH, POT_SWITCH}
var currentState = State.POT_SWITCH

signal attaching
signal completed_level

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_first_sprout:
		# set idle
		frozen = false
		currentState = State.EMPTY
	else:
		transition_state(State.EMPTY)
		Anim.animation = "pot_exit"
		Anim.frame = 0
		Anim.freeze()
	pass 
	
func reveal():
	frozen = false
	Anim.unfreeze()
	print("REVEAL!!")
	transition_state(State.EMPTY)
	
func get_movement_vector():
	var acceleration = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		acceleration = Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		acceleration = Vector2.RIGHT
	return acceleration * Acceleration
	
func _physics_process(delta):
	var is_falling_down = velocity.y > 0.0 and not is_on_floor() 
	var acceleration = Vector2.ZERO
	if frozen:
		velocity = Vector2.ZERO
		return
	if currentState != State.CARRY_SWITCH and currentState != State.POT_SWITCH or frozen or (bond == null):
		acceleration = get_movement_vector()
		
		if Input.is_action_pressed("pick_up"):
			if currentState == State.CARRY:
				
				Anim.transition_state(Anim.AnimState.DROPPING)
				currentState == State.CARRY_SWITCH
			else:
				pick_up_pot()
				
			
			
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				jumped_already = true
				jump()
			else:
				can_buffer_jump = true
				Buffer.start()
				if can_coyote_jump and is_falling_down and not jumped_already:
					jump()
					can_coyote_jump = false
		elif is_on_floor():
			can_coyote_jump = true
			jumped_already = false
			if can_buffer_jump:
				jump()
				can_buffer_jump = false
		if is_falling_down:
			if Coyote.is_stopped() and can_coyote_jump:
				Coyote.start()
	if (acceleration == Vector2.ZERO):
		velocity = velocity.move_toward(Vector2.ZERO, delta * Friction)
		
	acceleration *= Acceleration
	acceleration += Vector2.DOWN * GRAVITY
	velocity += acceleration
	var opposingForce = Vector2(-velocity.x * potSlowdown, 0)
	if potRef != null and potSlowdown > 0.0:
		var pot_to_player : Vector2 = (Vector2(global_position.x, 0) - Vector2(potRef.global_position.x, 0)).normalized()
		var opposingForceStrength = max(0.0, pot_to_player.dot( Vector2(-sign(velocity.x), 0.0 )  ) )
		velocity += opposingForce * opposingForceStrength
	
	var carrySlowdown = 1.0
	if currentState == State.CARRY:
		carrySlowdown = 0.5
	
	velocity.x = clamp(velocity.x, -WalkSpeed * carrySlowdown , WalkSpeed * carrySlowdown)
	
	
	if Input.is_action_pressed("retract"):
		die()
		
		
	velocity += impulses
	velocity = move_and_slide(velocity, Vector2.UP)
	
	impulses = Vector2.ZERO
	
	try_attach()
	
	Anim.animate(velocity, is_falling_down, is_on_floor())
	
func try_attach():
	if Input.is_action_just_pressed("attach"):
		print("attach try!")
		if bind_of_interest != null:
			print("attach doing!")
			bind_of_interest.forge_bond_with(self)
		
		
func jump():
	if currentState == State.EMPTY:
		velocity.y = 0
		impulses = Vector2.UP * JumpHeight
	pass
	
func pick_up_pot():
	if potReference != null and currentState != State.CARRY and not potReference.isStatic:
		var pot : RigidBody2D = potReference.duplicate()
		potReference.queue_free()
		Anim.add_child(pot)
		pot.visible = false
		if potReference.is_glowing():
			transition_state(State.POT_SWITCH)
			if bond != null:
				bond.queue_free()
		else:
			transition_state(State.CARRY_SWITCH)
	pass
	


func transition_state(new_state):
	if new_state == State.CARRY_SWITCH:
		Anim.transition_state(Anim.AnimState.GRABBING)
	if new_state == State.POT_SWITCH:
		Anim.transition_state(Anim.AnimState.ENTER_POT)
		currentState = new_state
	if new_state == State.EMPTY:
		if currentState == State.POT_SWITCH:
			Anim.transition_state(Anim.AnimState.EXIT_POT)
	currentState = new_state

func on_buffer_timeout():
	can_buffer_jump = false

func on_coyote_timeout():
	can_coyote_jump = false


func _on_PickupRange_area_entered(area:Area2D):
	if area.get_parent().name == "Pot":
		potReference = area.get_parent()
		can_pick_up = true


func _on_PickupRange_area_exited(area:Area2D):
	potReference = null
	can_pick_up = false


func _on_AnimatedSprite_dropped():
	# spawn the thingy again.

	var pot = Anim.get_child(0)
	if pot != null and currentState == State.CARRY_SWITCH:
		print("doing stuff!")
		var new_pot = PotScene.instance()
		get_tree().root.add_child(new_pot);
		new_pot.set_as_toplevel(true)
		var dirSign
		if Anim.flip_h:
			dirSign = 1.0
		else:
			dirSign = -1.0
		print(dirSign)
		new_pot.global_position = global_position + Vector2(dirSign, 0.0) * 30.0
		transition_state(State.EMPTY)
		new_pot.visible = true
		Anim.transition_state(Anim.AnimState.EMPTY)


func _on_AnimatedSprite_grabbed():
	transition_state(State.CARRY)


func _on_AreaOfRedundance_body_entered(body):
	if body.name == "Pot":
		print("it works!")
		potRef = body as Node2D
		potSlowdown = 0.99
		


func _on_AreaOfRedundance_body_exited(body):
	if body.name == "Pot":
		potSlowdown = 0.0
		potRef = null

func give_impulse(impulse):
	impulses += impulse


func _on_AnimatedSprite_exited():
	emit_signal("completed_level")

func die():
	var respawnpoint = get_parent().get_node("Respawn")
	global_position = respawnpoint.global_position
	if bond != null:
		bond.queue_free()
	bond = null

func _on_AnimatedSprite_entered():
	#var new_pot = PotScene.instance()
	#new_pot.isStatic = true
	#new_pot.forge_bond_with(self)
	#get_parent().add_child(new_pot);
	#new_pot.global_position = global_position + Vector2.RIGHT * 30.0
	
	currentState = State.EMPTY
	Anim.animState = Anim.AnimState.EMPTY
