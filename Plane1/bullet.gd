extends Area2D

var speed = Vector2()
var power = 10
var random_power = 20

func _physics_process(delta: float) -> void:
	global_position = global_position + speed * delta

func set_speed(new_speed:Vector2):
	speed = new_speed


func _on_body_entered(body: Node2D) -> void:
	
	if body.has_method("receive_damage"):
		body.receive_damage(power + randi_range(0, random_power))
		
	self.queue_free()


func _on_timer_timeout() -> void:
	self.queue_free()
