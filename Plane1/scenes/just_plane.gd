extends Node2D
const PLANE = preload("res://scenes/plane.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Plane"):
		if not body.is_starting:
			var new_plane = PLANE.instantiate()
			new_plane.prestige = body.prestige
			body.queue_free()
			
			new_plane.position = Vector2(-9735.0, 722)
			add_child(new_plane)
			for c in get_node("Soldiers/Path2D").get_children():
				c.player = new_plane
