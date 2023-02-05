extends Node2D

var Rope = preload("res://Scenes/Rope/Rope.tscn")
var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if start_pos == Vector2.ZERO:
			start_pos = get_global_mouse_position()
		elif end_pos == Vector2.ZERO:
			end_pos = get_global_mouse_position()
			
			#ROPE LOGIC
			var rope = Rope.instance()
			add_child(rope)
			rope.spawn_rope(start_pos, end_pos)
			
			#RESET
			start_pos = Vector2.ZERO
			end_pos = Vector2.ZERO
