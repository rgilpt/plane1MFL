extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func destroy_tank():
	var EXPLOSION  = load("res://scenes/explosion.tscn")
	var explosion = EXPLOSION.instantiate()
	explosion.position = self.position
	get_parent().add_child(explosion)
	
	self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullet"):
		body.destroy()
		self.destroy_tank()
		
