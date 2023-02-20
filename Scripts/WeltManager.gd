extends Node2D

var level = 1


func goto_next_level():
	var levelPath = "L" + str(level)
	print("Going to next level" + levelPath)
	
	var levelNode = get_node(levelPath)
	var nextLevelNode = get_node("L" + str(level + 1))
	level += 1
	$Tween.interpolate_property($WeltCamera, "global_position", levelNode.get_node("WeltCenter").global_position, nextLevelNode.get_node("WeltCenter").global_position, 4.0)
	$Tween.start()


func _on_Sprout_completed_level():
	print(self.name + " heard that Sprout completed the level.")
	goto_next_level()


func _on_Tween_tween_all_completed():
	var prevNode = get_node("L" + str(level-1))
	prevNode.queue_free()
	var sproutNode = get_node("L" + str(level)).get_node("Sprout")
	sproutNode.reveal()


func _on_Sprout_died(sprout:Object):
	var levelNode = get_node("L" + str(level))
	sprout.global_position = levelNode.get_node("SpawnPoint").global_position
