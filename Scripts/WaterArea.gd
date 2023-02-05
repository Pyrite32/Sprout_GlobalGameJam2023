extends Area2D


var uses = 1

func _on_Sprout_body_entered(sprout:Object):
	#sprout.grow();
	uses = uses - 1
	
	if uses == 0:
		get_parent().queue_free()
	
