extends RigidBody2D


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_fired = false

var fins_position = Vector2(11, 0)

var total_fins_area = 4
var cl = 0.3

var total_fins_section_area = 0.1
var cd = 0.4

var drag_mod_coef = 0.6

var lift_force = Vector2()
var drag_force = Vector2()
var displacement = Vector2()

var missile_drag_position = Vector2(-1, 0)
var missile_drag_force = Vector2()
var missile_section_area = 0.001

var destroyed = false

var has_engine = true
var fuel = 3000
var power = 0
var max_power = 1800
var delta_power = 10
var power_fuel_drain = 0.0001
var thrust_force = Vector2()

var bullet_angle = 0.0
var max_left_bullet_angle = 25.0
var max_right_bullet_angle = -25.0
var coef_multiplier = 3.0

var engine_angle = 0.0
var max_left_engine_angle = 10.0
var max_right_engine_angle = -10.0

var torque_pitch = 12
var torque_pitch_controlled = 18
var c_torque_pitch = 0
var change_angle = -1
var is_inverted = false
var current_angle = 0
var is_pitching = false

var heading_angle = 0

@onready var collision_shape_2d = $CollisionShape2D

@onready var vectors_layer = $VectorsLayer

#@onready var car = get_parent().get_node("Car")
@onready var camera_2d = $Camera2D
#@onready var plume = $Plume
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3

@onready var wing: RigidBody2D = $Wing

var is_restarting:bool = false

func fired(initial_speed_value, power, initial_angle, engine=true):
	
	self.rotate(initial_angle)
	self.apply_impulse(initial_speed_value * power,Vector2())
	
	#camera_2d.is_current()
	#velocity = initial_speed_value * power
	if engine:
		has_engine = true
		
	
func _ready() -> void:
	is_restarting = false
func _physics_process(delta):
	#if not has_engine:
		#plume.set_off()
	
	#if camera_2d != null and not destroyed:
		##car.get_node("Camera2D").enabled = false
		#camera_2d.enabled = true
	#camera_2d.enabled = true
	#if Input.is_action_pressed("ui_bullet_left"):
		#bullet_angle = max_left_bullet_angle
	#elif Input.is_action_pressed("ui_bullet_right"):
		#bullet_angle = max_right_bullet_angle
	#else:
		#bullet_angle = 0 
	#
	#if Input.is_action_pressed("ui_bullet_left"):
		#engine_angle = max_left_engine_angle
	#elif Input.is_action_pressed("ui_bullet_right"):
		#engine_angle = max_right_engine_angle
	#else:
		#engine_angle = 0 
	
	if Input.is_action_pressed("ui_up"):
		power += delta_power
	elif Input.is_action_pressed("ui_down"):
		power -= delta_power
	power = clamp(power, 0, max_power)
	
	label.set_text(str(power))
	if Input.is_action_just_released("ui_flip"):
		flip()
		if is_inverted:
			is_inverted = false
			wing.is_inverted = false
		else:
			is_inverted = true
			wing.is_inverted = true
		
	if Input.is_action_pressed("ui_left"):
		c_torque_pitch = change_angle
		is_pitching = true
	elif Input.is_action_pressed("ui_right"):
		c_torque_pitch = -change_angle
		is_pitching = true
	else:
		c_torque_pitch = 0
		if is_pitching:
			heading_angle = current_angle
			is_pitching = false
		
		
	
	if Input.is_action_just_pressed("ui_accept"):
		self.position += Vector2(0, -100)
	if Input.is_action_just_released("ui_reset_position"):
		self.position = Vector2(0, -500)
	if Input.is_action_just_released("ui_restart"):
		is_restarting = true
		#get_tree().reload_current_scene()
func flip():
	var sprite_2d: Sprite2D = $Sprite2D
	sprite_2d.scale.y = -sprite_2d.scale.y
	
	var rear_wheel: RigidBody2D = $RearWheel
	rear_wheel.position.y = -rear_wheel.position.y
	var rear_pin_joint_2d: PinJoint2D = $RearPinJoint2D
	rear_pin_joint_2d.node_a = ""
	rear_pin_joint_2d.node_b = ""
	rear_pin_joint_2d.position.y = -rear_pin_joint_2d.position.y
	rear_pin_joint_2d.node_a = get_parent().get_node("Bullet").get_path()
	rear_pin_joint_2d.node_b = rear_wheel.get_path()
	
	var rear_damped_spring_joint_2d: DampedSpringJoint2D = $RearDampedSpringJoint2D
	rear_damped_spring_joint_2d.position.y = -rear_damped_spring_joint_2d.position.y

	var front_wheel: RigidBody2D = $FrontWheel
	front_wheel.position.y = -front_wheel.position.y
	var pin_joint_2d_2: PinJoint2D = $PinJoint2D2
	pin_joint_2d_2.node_a = ""
	pin_joint_2d_2.node_b = ""
	pin_joint_2d_2.position.y = -pin_joint_2d_2.position.y
	pin_joint_2d_2.node_a = get_parent().get_node("Bullet").get_path()
	pin_joint_2d_2.node_b = front_wheel.get_path()
	
	#var new_pin: PinJoint2D = PinJoint2D.new()
	#new_pin.position = pin_joint_2d_2.position
	#new_pin.position.y = -pin_joint_2d_2.position.y
	##pin_joint_2d_2.position.y = -pin_joint_2d_2.position.y
	#add_child(new_pin)
	#new_pin.node_a = get_parent().get_node("Bullet").get_path()
	#new_pin.node_b = pin_joint_2d_2.node_b
	#
	#pin_joint_2d_2.queue_free()
	
	#front_wheel.position.y = -front_wheel.position.y



func set_vector(node, camera_2d):
	vectors_layer.draw.add_vector(
		node, "linear_velocity", 0.3, 4, Color(1,1,1, 0.5), true)
		
	vectors_layer.draw.add_vector(
		node, "lift_force", 1, 4, Color(0,1,0, 0.5), true)
	
	vectors_layer.draw.add_vector(
		node, "drag_force", 10, 4, Color(1,0,0, 0.5), true)
	
	vectors_layer.draw.add_vector(
		node, "missile_drag_force", 10, 4, Color(1,0,0, 0.5), true)
	
	vectors_layer.draw.add_vector(
		node, "displacement", 10, 4, Color(0,0,1, 0.5), true)
	vectors_layer.set_custom_camera(camera_2d)

func _on_timer_timeout():
	
	if is_restarting:
		get_tree().reload_current_scene()
	#destroy_bullet()

func destroy():
	pass
	#destroy_bullet()

func destroy_bullet():
	pass
	#destroyed = true
	#var EXPLOSION  = load("res://scenes/explosion.tscn")
	#var explosion = EXPLOSION.instantiate()
	#explosion.position = self.position
	#get_parent().add_child(explosion)
	#if camera_2d.is_current():
		#camera_2d.enabled = false
	
	
	#car.get_node("Camera2D").make_current()
	#car.get_node("Camera2D").enabled = true
	#self.queue_free()

func _on_body_entered(body):
	pass
	#if not body.is_in_group("Player"):
		#destroy_bullet()

func angle_of_attack_calculation(a, b):
	
	return acos(a.dot(b)/(a.length() * b.length()))
	
func lift_angle_of_attack_mod(aa):
	
	if aa > -0.087 and aa < 0.262:
		return 5.747 * aa + 0.5 
	elif aa >= 0.262 and aa < 0.35:
		return 1.75
	elif aa < -0.087 and aa > -0.262:
		return 0.3
	elif aa > 0.35:
		return 0.2
	else:
		return 0

func drag_angle_of_attack_mod(aa):
	if abs(aa) > 0 and abs(aa) < PI/2:
		return ((total_fins_area - total_fins_section_area) * 
			abs(aa)/ (PI/2)) + total_fins_section_area
	else:
		return ((total_fins_area - total_fins_section_area) * 
			(PI/2-(abs(aa) - PI/2))/ (PI/2)) * drag_mod_coef + total_fins_section_area
	
func lift_force_calc(aa, direction_vector, l_velocity):
	#var lift_force = direction_vector.rotated(-PI/2).normalized()
	var lift_force = l_velocity.normalized().rotated(-PI/2)
	
	var lift_aa_coef = lift_angle_of_attack_mod(aa)
	print("lift_aa_coef: {v}".format({"v":lift_aa_coef}))
	print("l_velocity.length(): {v}".format({"v":l_velocity.length()}))
	
	
	var lift_force_length = (0.5 * .002377 * 
		l_velocity.length() * l_velocity.length() * total_fins_area * 
		cl * lift_aa_coef)
	
	
	return lift_force * lift_force_length

func drag_force_calc(aa, direction_vector, l_velocity):
	var drag_force = -l_velocity.normalized()
	
	var drag_aa_coef = drag_angle_of_attack_mod(aa)
	drag_force = (0.5 * drag_force * .002377 * 
		l_velocity.length() * l_velocity.length() * 
		cd * drag_aa_coef)#.rotated(deg_to_rad(bullet_angle))
	
	return drag_force
	
func _integrate_forces(state):
	if is_restarting:
		return
	var direction_vector = Vector2(1,0)
	var velocity_vector = state.linear_velocity
	
	var ray_cast_2d: RayCast2D = $RayCast2D
	var ray_cast_2d_2: RayCast2D = $RayCast2D2
	var ray_cast_2d_3: RayCast2D = $RayCast2D3
	var ray_cast_2d_4: RayCast2D = $RayCast2D4
	heading_angle = wrapf(heading_angle, -PI, PI)
	var my_rotation = rotation
	
	
	var aa = -(direction_vector.rotated(my_rotation)).angle_to(velocity_vector)
	#if is_inverted:
		#aa = -aa
	
	#aa = wrapf(aa, -PI, PI)
	
	
	
	lift_force = lift_force_calc(aa, direction_vector, linear_velocity)
	drag_force = drag_force_calc(aa, direction_vector, linear_velocity)
	
	
	displacement = fins_position.rotated(rotation)
	if is_inverted:
		displacement.x = -displacement.x
	apply_force(lift_force.rotated(rotation), displacement)
	apply_force(drag_force, displacement)
	#print(drag_force)
	ray_cast_2d_4.target_position = drag_force
	var displacement2 = missile_drag_position.rotated(rotation)
	#apply_force(missile_drag_force, displacement2)
	
	if has_engine:
		thrust_force = direction_vector.normalized() * power
		fuel -= power_fuel_drain * power
		if is_inverted:
			apply_force(thrust_force.rotated(rotation), -displacement)
		else:
			apply_force(thrust_force.rotated(rotation), displacement)
		
		#if engine_angle == 0:
			#apply_force(thrust_force, displacement)
			##plume.position = displacement #+ Vector2(-50, 0)
			##plume.rotation = deg_to_rad(90 - engine_angle )
			##print(thrust_force.rotated(deg_to_rad(engine_angle)))
		#else:
			#apply_force(thrust_force.rotated(deg_to_rad(engine_angle)), displacement)
			##plume.position = displacement + Vector2(-50, 0)
			##plume.rotation = deg_to_rad(90 - engine_angle )
			##print(thrust_force.rotated(deg_to_rad(engine_angle)))
		
		
		if fuel < 0:
			has_engine = false
			
	var my_speed = linear_velocity.length()
	current_angle = direction_vector.rotated(rotation).angle()
	var delta_angle = current_angle - heading_angle
	print("delta: {v}".format({"v":rad_to_deg(delta_angle)}))
	if abs(c_torque_pitch) > 0:
		apply_torque(my_speed * torque_pitch * c_torque_pitch)
	else:
		pass
		if abs(delta_angle) > 0.1:
			if is_inverted:
				apply_torque(my_speed * torque_pitch_controlled * abs(delta_angle)/delta_angle)
			else:
				apply_torque(my_speed * torque_pitch_controlled * -abs(delta_angle)/delta_angle)
	
	#apply_torque( torque_pitch * c_torque_pitch)
	#print(my_speed)
	ray_cast_2d_2.target_position = lift_force
	#print(thrust_force)
	
	print("my rotation: {v}".format({"v":rad_to_deg(my_rotation)}))
	print("aa: {v}".format({"v":rad_to_deg(aa)}))
	print("velocity vector: {v}".format({"v":velocity_vector}))
	print("velocity vector angle: {v}".format({"v":rad_to_deg(velocity_vector.angle())}))
	ray_cast_2d.target_position = direction_vector * 300
	ray_cast_2d_3.target_position = velocity_vector
	
	label_3.set_text("{v}".format({"v": "%0.2f" % rad_to_deg(rotation)}))
	label_2.set_text("{v}".format({"v": "%0.2f" % rad_to_deg(aa)}))
	
func calculate_area_aa(aa):
	if abs(aa) > PI/2:
		return 0.5
		
	return 4 * 0.4/PI * abs(aa) + 0.1

func _on_timer_prime_timeout():
	collision_shape_2d.disabled = false
