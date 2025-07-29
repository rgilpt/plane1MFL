extends Node2D


func _on_button_pressed() -> void:
	Global.difficult_selection = Global.Difficult.EASY
	
	get_tree().change_scene_to_file("res://scenes/test_plane.tscn")


func _on_button_2_pressed() -> void:
	Global.difficult_selection = Global.Difficult.HARD
	
	get_tree().change_scene_to_file("res://scenes/test_plane.tscn")
