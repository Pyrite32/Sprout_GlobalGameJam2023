extends Node2D

var endPoint = Vector2.ZERO
var target : KinematicBody2D

export var LinkName: String
export var pull_threshold = 200.0
export var maximum_length = 600.0


func init(link):
	var new_target = link
	bind_root_target(new_target)


func bind_root_target(new_target:KinematicBody2D):
	if new_target != null:
		print(self.name + " root has been binded to " + new_target.name)
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
			var linearWeight = min(0.5, pow(((dist-pull_threshold) / (maximum_length - pull_threshold)), 2.0) )
			material.set_shader_param("intensity", linearWeight)
			var velocity = -target.velocity * linearWeight
			target.give_impulse(velocity)


