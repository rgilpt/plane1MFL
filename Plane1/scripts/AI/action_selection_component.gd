class_name ActionSelectionComponent
extends Node

@export var FSM:FiniteStateMachine
@export var selector:DecisionTree

enum actions
{
	FSM_ADVANCE,
	FSM_ALERT,
	FSM_FIRE,
	FSM_RELOAD
}
func get_action():
	
	return selector.get_action()
