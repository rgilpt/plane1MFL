class_name FSM_Advance
extends Node

@export var actor: PathFollow2D = null
@export var fsm: FiniteStateMachine = null

var velocity_coef = 0.5
var velocity_x = -100
var gravity = -10

func _ready():
	return

func action_state():
	if actor == null:
		return
	actor.is_moving = true
	#if not actor.is_on_floor():
		#actor.velocity.y -= gravity
	#else:
		#actor.velocity.y = 0
	#actor.velocity.x = velocity_x
