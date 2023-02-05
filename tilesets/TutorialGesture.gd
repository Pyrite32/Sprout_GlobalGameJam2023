extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var open_trigger = false
var close_trigger = false
export var autostart = false
export(String, MULTILINE) var tutorialText

# Called when the node enters the scene tree for the first time.
func _ready():
	if autostart:
		body_entered(null)
	$Label.text = tutorialText
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func body_entered(body):
	if not $AnimationPlayer.is_playing() and not open_trigger:
		open_trigger = true
		$AnimationPlayer.play("enter")


func body_exited(body):
	if not close_trigger:
		$Wait.start()
		close_trigger = true


func _on_Wait_timeout():
	$AnimationPlayer.play("exit")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		queue_free()
