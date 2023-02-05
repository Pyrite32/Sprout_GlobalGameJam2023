extends Area2D

func _on_Sprout_body_entered(sprout:Object):
	sprout.die();
