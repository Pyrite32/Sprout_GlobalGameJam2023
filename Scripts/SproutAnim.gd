extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum AnimState { EMPTY, CARRYING, GRABBING, DROPPING, ENTER_POT, EXIT_POT}

signal dropped
signal grabbed
signal exited

var frozen = false
var prevAnim = ""
var shitOffset : int = 16 

func freeze():
	prevAnim = animation
	stop()
	frozen = true
	
func unfreeze():
	play(prevAnim)
	frozen = false
	

var animState = AnimState.EMPTY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func animate(direction: Vector2, is_falling: bool, is_on_floor:bool):
	if not frozen:
		flip_h = direction.x > 0
		if animState == AnimState.EMPTY:
			if direction.length() < 0.1:
				play("idle")
			else:
				if is_on_floor:
					play("walk")
				else:
					play("jump")
			if animation == "jump":
				if is_falling and frame > 0:
					frame = 2
				elif frame > 0:
					frame = 1
		elif animState == AnimState.CARRYING:
			if direction.length() < 0.1:
				play("pot_idle")
			else:
				play("pot_walk")

		
	
func transition_state(new_state):
	if not frozen:
		match new_state:
			AnimState.GRABBING:
				play("pot_lift")
			AnimState.DROPPING:
				get_parent().transition_state(get_parent().State.CARRY_SWITCH)
				play("pot_place")
			AnimState.ENTER_POT:
				play("pot_enter")
			AnimState.EXIT_POT:
				play("pot_exit")
				position.y = -shitOffset
			AnimState.EMPTY:
				if animState == AnimState.EXIT_POT:
					position.y = 0
		animState = new_state

# this is terrible code but I don't have any choice!!!! dunno what to do


func _on_AnimatedSprite_animation_finished():
	if animState == AnimState.GRABBING:
		# move to carry
		animState = AnimState.CARRYING
		emit_signal("grabbed")
	elif animState == AnimState.DROPPING:
		emit_signal("dropped")
	elif animState == AnimState.ENTER_POT:
		emit_signal("exited")
		frame = 7
		stop()
		

