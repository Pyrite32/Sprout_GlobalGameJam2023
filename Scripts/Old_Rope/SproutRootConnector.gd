extends Node2D

var Rope = preload("res://Scenes/Rope/Rope.tscn")

var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO
var rope_instance:Rope = null
var pot_point:RigidBody2D = null
var sprout_point:RigidBody2D = null

onready var Sprout := get_parent().get_node("Sprout");


func _ready():
	print("Sprout found: " + Sprout.name)
	Sprout.connect("attaching", self, "_on_Sprout_attaching")


func _process(delta):
	if rope_instance != null:
		if pot_point != null:
			rope_instance.set_start_pos(pot_point, pot_point.global_position)

		if sprout_point != null:
			rope_instance.set_end_pos(sprout_point, sprout_point.global_position)


func _on_Sprout_attaching(potRef:RigidBody2D, rootAttachPoint:RigidBody2D):
	print("Sprout trying to attach")
	
	if potRef == null:
		print("Pot reference not found")
		return
	
	if rootAttachPoint == null: 
		print("Root not found")
		return
	
	pot_point = potRef.RootAttachPosition
	sprout_point = rootAttachPoint
	
	if rope_instance != null:
		rope_instance.queue_free()
		
	start_pos = pot_point.global_position
	end_pos = sprout_point.global_position
	
	print("Creating rope instance")
	rope_instance = Rope.instance()
	add_child(rope_instance)
	rope_instance.spawn_rope(start_pos, start_pos - Vector2(0, 200))
	
	print("Root attached")


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

