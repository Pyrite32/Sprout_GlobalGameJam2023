extends Node2D

var Rope = preload("res://Scenes/Rope/Rope.tscn")

var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO
var rope_instance:Object = null

onready var Sprout := get_parent().get_node("Sprout");

func _ready():
	Sprout.connect("attaching", self, "_sprout_attaching")

func _sprout_attaching():
	if Sprout.potRef == null: return
	
	if rope_instance == null:
		rope_instance = Rope.instance()
		add_child(rope_instance)
	
	start_pos = Sprout.potRef.position
	end_pos = Sprout.position

#func _input(event):
#	if event is InputEventMouseButton and !event.is_pressed():
#		if start_pos == Vector2.ZERO:
#			start_pos = get_global_mouse_position()
#		elif end_pos == Vector2.ZERO:
#			end_pos = get_global_mouse_position()
#
#			#ROPE LOGIC
#			var rope = Rope.instance()
#			add_child(rope)
#			rope.spawn_rope(start_pos, end_pos)
#
#			#RESET
#			start_pos = Vector2.ZERO
#			end_pos = Vector2.ZERO
