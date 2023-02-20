extends Area2D


enum PushState { PRESSED, UNPRESSED }
var currentState = PushState.UNPRESSED

export var id : int = 0
export var wait_time : float = 10;

onready var PushTimer = $Timer


func _ready():
	$Timer.wait_time = wait_time;


func transition_state(new_state):
	if currentState == PushState.UNPRESSED and new_state == PushState.PRESSED:
		broadcast_opened()
		$Sprite.frame = 1
	elif currentState == PushState.PRESSED and new_state == PushState.UNPRESSED:
		$Sprite.frame = 0
		broadcast_closed()
	
	currentState = new_state


func broadcast_opened():
	get_tree().call_group("button_based", "open", id)


func broadcast_closed():
	get_tree().call_group("button_based", "close", id)


func _on_Timer_timeout():
	transition_state(PushState.UNPRESSED)


func _on_Button_body_entered(body):
	print(self.name + " has been pushed by " + body.name)
	transition_state(PushState.PRESSED)


func _on_Button_body_exited(body):
	print(self.name + " is no longer pushed.")
	PushTimer.start()
