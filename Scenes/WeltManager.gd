extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var level = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func goto_next_level():
	print("going 2 next level!")
	var levelNode = get_node("L" + str(level))
	var nextLevelNode = get_node("L" + str(level + 1))
	level += 1
	$Tween.interpolate_property($WeltCamera, "global_position", levelNode.get_node("WeltCenter").global_position, nextLevelNode.get_node("WeltCenter").global_position, 4.0)
	$Tween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Sprout_completed_level():
	goto_next_level()


func _on_Tween_tween_all_completed():
	var prevNode = get_node("L" + str(level-1))
	prevNode.queue_free()
	var sproutNode = get_node("L" + str(level)).get_node("Sprout")
	sproutNode.reveal()
