extends Area2D


func receive_damage(power):
	get_parent().receive_damage(power)
