extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



var endPoint = Vector2.ZERO
var target : KinematicBody2D

export var LinkName: String
export var pull_threshold = 200.0
export var maximum_length = 600.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_target = get_parent().get_node(LinkName)
	bind_root_target(new_target)
	pass # Replace with function body.

func bind_root_target(new_target:KinematicBody2D):
	target = new_target
	
func _process(delta):
	
	if target != null:
		endPoint = target.global_position
		var dist = endPoint.distance_to(global_position)
		$Sprite.region_rect.end.y = dist
		$Sprite.offset.y = -dist / 2.0
		
		var tovec = global_position - endPoint
		var angle = atan2(tovec.x, tovec.y)
		rotation = -angle
		
		
		if dist > pull_threshold:
			var linearWeight = min(0.3, pow(((dist-pull_threshold) / (maximum_length - pull_threshold)), 2.0) )
			material.set_shader_param("intensity", linearWeight)
			var velocity = -target.velocity * linearWeight
			target.give_impulse(velocity)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
