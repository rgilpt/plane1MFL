class_name FSM_Alert
extends Node

@export var actor: PathFollow2D = null
var target = null
@export var fsm: FiniteStateMachine = null

const BULLET = preload("res://scenes/bullet.tscn")

var velocity_coef = 0.5

func _ready():
	return

func action_state():
	if actor != null:
		actor.is_moving = false
		#actor.velocity = Vector2()
