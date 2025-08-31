class_name FSM_Fire
extends Node

@export var actor: CharacterBody2D = null
var target = null
@export var fsm: FiniteStateMachine = null

const BULLET = preload("res://scenes/bullet.tscn")

var velocity_coef = 0.5

func _ready():
	return

func action_state():
	if actor == null:
		return
	actor.is_moving = false
	target = fsm.target
	if target == null:
		return
	if target.is_in_group("Player"):
		
		var direction =   ((target.global_position + target.linear_velocity * velocity_coef) - 
			actor.global_position)
		direction = direction.rotated(randf_range(-0.3, 0.3))
		var new_bullet = BULLET.instantiate()
		new_bullet.position = actor.position
		
		#new_bullet.set_collision_layer(1)
		new_bullet.set_collision_mask_value(2, true)
		new_bullet.set_speed(direction.normalized() * 2000)
		
		actor.get_parent().get_parent().add_child(new_bullet)
		
		var t_reload = actor.get_node("T_Reload")
		fsm.is_reloading = true
		t_reload.start()
		fsm.get_action()
