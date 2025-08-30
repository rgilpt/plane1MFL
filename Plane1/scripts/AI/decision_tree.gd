class_name DecisionTree
extends Node

@export var action_selection:ActionSelectionComponent

func get_action():
	return get_action_decision_tree()

func get_action_decision_tree():
	if action_selection == null:
		return
	if action_selection.FSM == null:
		return
	var FSM = action_selection.FSM
	if FSM.enemy_in_area:
		if FSM.is_reloading:
			return action_selection.actions.FSM_RELOAD
		else:
			return action_selection.actions.FSM_FIRE
	else:
		if FSM.is_alert:
			return action_selection.actions.FSM_ALERT
		else:
			return action_selection.actions.FSM_ADVANCE
