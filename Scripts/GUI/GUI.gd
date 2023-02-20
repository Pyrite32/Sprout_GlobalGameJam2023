extends Control


func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/Prologue.tscn")


func _on_Credits_pressed():
	get_tree().change_scene("res://Scenes/Credits.tscn")

func _on_Exit_pressed():
	get_tree().quit()
