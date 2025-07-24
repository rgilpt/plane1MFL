extends StaticBody2D

var health = 300

func receive_damage(power):
	health -= power
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.7)
	if health <= 0:
		
		
		tween.tween_property($Sprite2D, "scale", Vector2(), 1.2)
		tween.tween_callback(self.queue_free)
	else:
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.7)
