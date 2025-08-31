extends CharacterBody2D

var health = 100

var is_alive = true

@export var player:RigidBody2D = null
const BULLET = preload("res://scenes/bullet.tscn")
@onready var label: Label = $Label

var velocity_coef = 0.5

@export var fsm:FiniteStateMachine
@onready var action_selection_component: ActionSelectionComponent = $AI/ActionSelectionComponent

var is_starting = true
@onready var t_alert: Timer = $T_Alert
var is_moving = true
var gravity = -10

func _ready() -> void:
	t_alert.wait_time = 2.0 + randf_range(0.5, 1.0)
	
func my_move():
	if not is_on_floor():
		velocity.y -= gravity
	else:
		velocity.y = 0
	if is_moving:
		velocity.x = - 80
		move_and_slide()
func _physics_process(delta: float) -> void:
	
	if is_starting:
		fsm.get_action()
		fsm.action_state()
		is_starting = false
	
	my_move.call_deferred()

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
			
			fsm.set_target(body) 
			fsm.enemy_in_area = true
			fsm.get_action()
			#var direction =   (body.global_position + body.linear_velocity * velocity_coef) - self.global_position
			#direction = direction.rotated(randf_range(-0.3, 0.3))
			#var new_bullet = BULLET.instantiate()
			#new_bullet.position = self.position
			#
			##new_bullet.set_collision_layer(1)
			#new_bullet.set_collision_mask_value(2, true)
			#new_bullet.set_speed(direction.normalized() * 2000)
			#
			#get_parent().add_child(new_bullet)

func _on_perception_body_entered(body: Node2D) -> void:
	label.set_text("Hey!!!")
	var tween = get_tree().create_tween()
	tween.tween_property(label,"text","", randf_range(0.5, 1.5))
	#tween.tween_callback(fire_bullet.bind(body))
	fire_bullet(body)


func _on_t_reload_timeout() -> void:
	if fsm != null:
		fsm.is_reloading = false
		fsm.get_action()


func _on_perception_body_exited(body: Node2D) -> void:
	if body != null:
		if body.is_in_group("Player"):
			#fsm.set_target(body) 
			fsm.enemy_in_area = false
			fsm.is_alert = true
			fsm.get_action()
			t_alert.start()
			

func _on_t_alert_timeout() -> void:
	#fsm.enemy_in_area = false
	fsm.is_alert = false
	fsm.get_action()


func _on_t_action_timeout() -> void:
	
	if fsm.current_state != null:
		fsm.call_deferred("get_action")
		if fsm.current_state.has_method("action_state"):
			fsm.current_state.call_deferred("action_state")
