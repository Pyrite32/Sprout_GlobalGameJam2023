extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum PushState { PRESSED, UNPRESSED }
var currentState = PushState.UNPRESSED

onready var PushTimer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func transition_state(new_state):
	if currentState == PushState.UNPRESSED and new_state == PushState.PRESSED:
		broadcast_opened()
		$Sprite.frame = 1
	elif currentState == PushState.PRESSED and new_state == PushState.UNPRESSED:
		$Sprite.frame = 0
		broadcast_closed()
	
	currentState = new_state

func broadcast_opened():
	pass

func broadcast_closed():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	transition_state(PushState.UNPRESSED)


func _on_Button_area_entered(area):
	transition_state(PushState.PRESSED)

func _on_Button_area_exited(area):
	PushTimer.start()
