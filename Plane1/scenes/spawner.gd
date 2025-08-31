extends Node2D

@export var n_wave_soldiers = 5
@export var n_waves = 3

@export var soldiers: Node2D = null
@export var player:RigidBody2D = null

const SOLDIER = preload("res://scenes/soldier.tscn")
@onready var timer_short: Timer = $TimerShort
@onready var timer_long: Timer = $TimerLong



func _ready() -> void:
	timer_short.start()
	randomize()

func _on_timer_short_timeout() -> void:
	if soldiers != null and player != null:
		var new_soldier = SOLDIER.instantiate()
		new_soldier.player = player
		new_soldier.position = self.position
		new_soldier.position.y = new_soldier.position.y - 20
		soldiers.add_child(new_soldier)
		n_wave_soldiers -= 1
		
		if n_wave_soldiers > 0:
			timer_short.start()
		else:
			timer_long.start()
			
		
		


func _on_timer_long_timeout() -> void:
	n_waves -= 1
	if n_waves > 0:
		n_wave_soldiers = 5
		timer_short.start()
