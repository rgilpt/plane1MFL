extends CharacterBody2D

var health = 100

var is_alive = true

@export var player:RigidBody2D = null
const BULLET = preload("res://scenes/bullet.tscn")
@onready var label: Label = $Label

var velocity_coef = 0.5

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

func fire_bullet(body):
	if body != null:
		if body.is_in_group("Player"):
			
			var direction =   (body.global_position + body.linear_velocity * velocity_coef) - self.global_position
			direction = direction.rotated(randf_range(-0.3, 0.3))
			var new_bullet = BULLET.instantiate()
			new_bullet.position = self.position
			
			#new_bullet.set_collision_layer(1)
			new_bullet.set_collision_mask_value(2, true)
			new_bullet.set_speed(direction.normalized() * 2000)
			
			get_parent().add_child(new_bullet)

func _on_perception_body_entered(body: Node2D) -> void:
	label.set_text("Hey!!!")
	var tween = get_tree().create_tween()
	tween.tween_property(label,"text","", randf_range(0.5, 1.5))
	tween.tween_callback(fire_bullet.bind(body))
