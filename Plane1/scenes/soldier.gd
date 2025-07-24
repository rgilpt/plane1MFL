extends CharacterBody2D

var health = 100

var is_alive = true

@export var player:RigidBody2D = null

func receive_damage(power):
	health -= power
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.7)
	if health <= 0:
		if player != null:
			player.prestige += 100
		
		is_alive = false
		
		tween.tween_property($Sprite2D, "scale", Vector2(), 1.2)
		tween.tween_callback(self.queue_free)
	else:
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.7)
