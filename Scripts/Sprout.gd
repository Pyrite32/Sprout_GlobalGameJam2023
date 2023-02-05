extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var Acceleration: float = 40.0
export var WalkSpeed: float = 110.0
export var Friction: float = 200.0
export var GRAVITY : float = 20.0
export var JumpHeight: float = 30.0

var impulses : Vector2
var velocity : Vector2

var can_buffer_jump = false
var can_coyote_jump = true
var jumped_already = false;
var can_pick_up = false
var potReference : RigidBody2D

var potRef : Node2D

var potSlowdown = 0.0

onready var Buffer = $Buffer
onready var Coyote = $Coyote
onready var Anim = $AnimatedSprite

onready var PotScene = preload("res://Scenes/Pot.tscn")

enum State { EMPTY, CARRY, CARRY_SWITCH }

var currentState = State.EMPTY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 
	
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
	if currentState != State.CARRY_SWITCH:
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
	var opposingForce = Vector2(-velocity.x * potSlowdown, -velocity.y * potSlowdown)
	if potRef != null and potSlowdown > 0.0:
		var pot_to_player : Vector2 = (Vector2(global_position.x, global_position.y) - Vector2(potRef.global_position.x, potRef.global_position.y)).normalized()
		var opposingForceStrength = max(0.0, pot_to_player.dot(Vector2(-sign(velocity.x), -sign(velocity.y))) )
		print("VELOCITY BEFORE: ", velocity)
		velocity += opposingForce * opposingForceStrength
		print("VELOCITY AFTER: ", velocity)
	
	var carrySlowdown = 1.0
	if currentState == State.CARRY:
		carrySlowdown = 0.5
	
	velocity.x = clamp(velocity.x, -WalkSpeed * carrySlowdown , WalkSpeed * carrySlowdown)
	
	
	velocity += impulses
	velocity = move_and_slide(velocity, Vector2.UP)
	
	impulses = Vector2.ZERO
	
	Anim.animate(velocity, is_falling_down, is_on_floor())
	
func jump():
	if currentState == State.EMPTY:
		velocity.y = 0
		impulses = Vector2.UP * JumpHeight
	pass
	
func pick_up_pot():
	if potReference != null and currentState != State.CARRY:
		var pot : RigidBody2D = potReference.duplicate()
		potReference.queue_free()
		Anim.add_child(pot)
		pot.visible = false
		transition_state(State.CARRY_SWITCH)
	pass
	


func transition_state(new_state):
	currentState = new_state
	if new_state == State.CARRY_SWITCH:
		Anim.transition_state(Anim.AnimState.GRABBING)
		

func on_buffer_timeout():
	can_buffer_jump = false

func on_coyote_timeout():
	can_coyote_jump = false


func _on_PickupRange_area_entered(area:Area2D):
	print("From sprout!")
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
