class_name FiniteStateMachine
extends Node

@export var verbose_level = 1

var current_state = null

var long_decision_timer: Timer
var short_decision_timer: Timer

@export var actor: CharacterBody2D = null
@export var action_selection: ActionSelectionComponent = null

var target = null

## State variables
var enemy_in_area = false
var is_alert = false
var is_reloading = false

enum state_result_type{
	failed,
	success,
	started,
	working,
}
var state_result = state_result_type.started
signal change_state_result(result_value)

var overide_next_action = null
var memory_target_location = null

func _ready():
	return
	

func _physics_process(delta):
	return
	if current_state != null:
		if current_state.has_method("action_state"):
			current_state.action_state()

func long_decision():
	pass

func set_target(new_target):
	target = new_target

func short_decision():
	pass

func get_action():
	var current_state_enum = action_selection.get_action()
	set_state(current_state_enum)

func set_state(new_state):
	if overide_next_action != null:
		new_state = overide_next_action
		overide_next_action = null
	
	if new_state == ActionSelectionComponent.actions.FSM_FIRE:
		current_state = $FSM_Fire
	elif new_state == ActionSelectionComponent.actions.FSM_ADVANCE:
		current_state = $FSM_Advance
	elif new_state == ActionSelectionComponent.actions.FSM_ALERT:
		current_state = $FSM_Alert
	elif new_state == ActionSelectionComponent.actions.FSM_RELOAD:
		current_state = $FSM_Reload
	#elif new_state == ActionSelectionComponent.actions.COLLECT_RESOURCES:
		#current_state = $CollectResourcesFSMComponent
	#elif new_state == ActionSelectionComponent.actions.CUT_TREE:
		#current_state = $CutTreeFSMComponent
	#elif new_state == ActionSelectionComponent.actions.PLANT_TREE:
		#current_state = $PlantTreeFSMComponent
	#elif new_state == ActionSelectionComponent.actions.PLACE_TRAPS:
		#current_state = $PlaceTrapsFSMComponent
	#elif new_state == ActionSelectionComponent.actions.HANDLE_TRAP:
		#current_state = $HandleTrapFSMComponent
	#elif new_state == ActionSelectionComponent.actions.CHECK_TRAPS:
		#current_state = $HandleTrapFSMComponent
	#elif new_state == ActionSelectionComponent.actions.CRAFT:
		#current_state = $CraftFSMComponent
	#elif new_state == ActionSelectionComponent.actions.FIND_RESOURCES:
		#current_state = $ExploreFSMComponent
	#elif new_state == ActionSelectionComponent.actions.GO_HOME:
		#current_state = $GoHomeFSMComponent
	set_state_result(state_result_type.started)
	#change_state_result.emit(state_result_type.started)
	#if verbose_level > 0:
		#print(ActionSelectionComponent.actions.keys()[new_state] )
	return current_state
	
func set_state_result(result_type):
	state_result = result_type
	change_state_result.emit(result_type)

func action_state():
	if current_state != null:
		current_state.action_state()
	else:
		var current_state_enum = action_selection.get_action()
		set_state(current_state_enum)
