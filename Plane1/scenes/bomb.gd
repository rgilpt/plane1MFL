extends RigidBody2D

var is_armed = false
const EXPLOSION = preload("res://scenes/explosion.tscn")

func released(initial_speed:Vector2):
	
	linear_velocity = initial_speed
	
func _physics_process(delta: float) -> void:
	
	rotation = linear_velocity.angle()


func _on_timer_timeout() -> void:
	is_armed = true


func _on_body_entered(body: Node) -> void:
	if is_armed:
		var new_explosion = EXPLOSION.instantiate()
		
		new_explosion.position = position
		get_parent().add_child(new_explosion)
		queue_free()
