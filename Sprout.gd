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

onready var Buffer = $Buffer
onready var Coyote = $Coyote
onready var Anim = $AnimatedSprite

enum State { EMPTY, CARRY, CARRY_SWITCH }

var currentState = State.EMPTY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 
	
func _physics_process(delta):
	var acceleration = Vector2.ZERO
	var is_falling_down = velocity.y > 0.0 and not is_on_floor()
	if Input.is_action_pressed("move_left"):
		acceleration = Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		acceleration = Vector2.RIGHT
	if Input.is_action_pressed("pick_up"):
		pick_up_pot()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * Friction)
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
	
	
	acceleration *= Acceleration
	acceleration += Vector2.DOWN * GRAVITY
	velocity += acceleration
	
	velocity.x = clamp(velocity.x, -WalkSpeed, WalkSpeed)
	
	
	velocity += impulses
	velocity = move_and_slide(velocity, Vector2.UP)
	
	impulses = Vector2.ZERO
	
	Anim.animate(velocity, is_falling_down, is_on_floor())
	
func jump():
	velocity.y = 0
	impulses = Vector2.UP * JumpHeight
	pass
	
func pick_up_pot():
	if potReference != null:
		var pot : RigidBody2D = potReference.duplicate()
		potReference.queue_free()
		add_child(pot)
		pot.visible = false
		transition_state(State.CARRY)
	pass

func transition_state(new_state):
	currentState = new_state

func on_buffer_timeout():
	can_buffer_jump = false

func on_coyote_timeout():
	can_coyote_jump = false


func _on_PickupRange_area_entered(area:Area2D):
	print("From sprout!")
	potReference = area.get_parent()
	can_pick_up = true


func _on_PickupRange_area_exited(area:Area2D):
	potReference = null
	can_pick_up = false
