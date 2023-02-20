extends Control


func _on_VideoPlayer_finished():
	load_main_scene()


func _input(event):
	if event.is_action_pressed("ui_select"):
		load_main_scene()


func load_main_scene():
	print("Loading main scene")
	get_tree().change_scene("res://Scenes/WeltManager.tscn")

