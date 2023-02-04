extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum AnimState { EMPTY, CARRYING }

var animState = AnimState.EMPTY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func animate(direction: Vector2, is_falling: bool, is_on_floor:bool):
	if animState == AnimState.EMPTY:
		flip_h = direction.x > 0
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
		pass
	
		
	
func transition_state(new_state):
	match new_state:
		AnimState.JUMP:
			play("jump")
		AnimState.WALK:
			play("walk")
		AnimState.IDLE:
			play("idle")
	animState = new_state
