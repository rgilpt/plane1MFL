extends Node2D

@onready var gpu_particles_2d = $GPUParticles2D
@onready var area_2d: Area2D = $Area2D

var power = 80
var power_random = 20
var it_exploded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gpu_particles_2d.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tween = get_tree().create_tween()
	#var my_shape = $Area2D/CollisionShape2D.shape
	tween.tween_property($Area2D/CollisionShape2D.shape, "radius", 60, 0.3)
	#tween.tween_property($Sprite2D, "scale", Vector2(), 1.2)
	#tween.tween_callback(self.queue_free)
	
		

func set_off():
	gpu_particles_2d.emitting = false

func _on_gpu_particles_2d_finished():
	self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("receive_damage"):
		body.receive_damage(power + randi_range(0, power_random))
