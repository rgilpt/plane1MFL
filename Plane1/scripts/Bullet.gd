extends RigidBody2D


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_fired = false

var fins_position = Vector2(9.5, 0)

var total_fins_area = 4
var cl = 0.3

var total_fins_section_area = 1.0
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

var torque_pitch_controlled = 1000
var controlled_angular_velocity = 0.05

var c_torque_pitch = 0
var change_angle = -1.8
var change_angle_nominal = -0.2
var is_inverted = false
var current_angle = 0
var is_pitching = false

var my_rotation = 0
var heading_angle = 0

var rof:float = 0.7
var ready_to_fire:bool = true
@onready var rate_fire: Timer = $RateFire

var bomb_fire_coef = 1.0

@onready var collision_shape_2d = $CollisionShape2D

@onready var vectors_layer = $VectorsLayer

#@onready var car = get_parent().get_node("Car")
@onready var camera_2d = $Camera2D
#@onready var plume = $Plume
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3

@onready var wing: RigidBody2D = $Wing
var tail_wing_pos = Vector2(-100, 0)
@onready var trottle_viewer: TextureProgressBar = $"../CanvasLayer/TrottleViewer"

var is_restarting:bool = false
var is_starting:bool = true
const BULLET = preload("res://scenes/bullet.tscn")

const BOMB = preload("res://scenes/bomb.tscn")

var bomb_position = Vector2(20, 30)
var is_fliped = false

var ammo_bombs = 4

var prestige = 0

@onready var altitude_reader: RayCast2D = $AltitudeReader

func fired(initial_speed_value, power, initial_angle, engine=true):
	
	self.rotate(initial_angle)
	self.apply_impulse(initial_speed_value * power,Vector2())
	
	#camera_2d.is_current()
	#velocity = initial_speed_value * power
	if engine:
		has_engine = true
		
	
func _ready() -> void:
	
	
	is_restarting = false
	wing.joint = true
	
	if Global.difficult_selection == Global.Difficult.EASY:
		torque_pitch_controlled = 1000
		controlled_angular_velocity = 0.05
		ammo_bombs = 5
	else:
		torque_pitch_controlled = 500
		controlled_angular_velocity = 0.01
		ammo_bombs = 4
		
		
	
	
	
func sas_on():
	angular_velocity = lerp(angular_velocity, 0.0, controlled_angular_velocity)
	var difference = current_angle - heading_angle
	label.set_text("{v}".format({"v": "%0.2f" % rad_to_deg(difference)}))
	if abs(difference) > 0.02:
		apply_torque( sign(-difference) * torque_pitch_controlled)
	
func _physics_process(delta):
	
	#altitude_reader.position = Vector2(0,0)
	var world_down_point = global_position + Vector2.DOWN * 1000
	var local_down_point = to_local(world_down_point)
	altitude_reader.target_position =  local_down_point
	var collider = altitude_reader.get_collider()
	var col_point = altitude_reader.get_collision_point()
	var local_col_point = to_local(col_point)
	
	print(local_col_point.y)
	if abs(local_col_point.y) > 1000:
		var coef_zoom = abs(1000/local_col_point.y)
		camera_2d.zoom = Vector2(0.3* coef_zoom,0.3* coef_zoom)
	else:
		camera_2d.zoom = Vector2(0.3,0.3 )
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
		is_starting = false
	elif Input.is_action_pressed("ui_down"):
		power -= delta_power
	power = clamp(power, 0, max_power)
	var current_value = 100.0/max_power * power
	trottle_viewer.value = current_value
	
	#label.set_text(str(power))
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
		
		
	
	if Input.is_action_pressed("ui_accept") and ready_to_fire:
		ready_to_fire = false
		rate_fire.wait_time = rof
		rate_fire.start()

		var new_bullet = BULLET.instantiate()
		var new_speed = Vector2(1,0).rotated(rotation) * 2000
		new_bullet.set_speed(new_speed)
		new_bullet.position = position + Vector2(70,-30).rotated(rotation)
		get_parent().add_child(new_bullet)
		#self.position += Vector2(0, -100)
		
	if Input.is_action_just_pressed("ui_fire_bomb") and ammo_bombs > 0:
		var new_bomb = BOMB.instantiate()
		
		new_bomb.position = position + bomb_position.rotated(rotation)
		new_bomb.released(linear_velocity * bomb_fire_coef)
		get_parent().add_child(new_bomb)
		
		ammo_bombs -= 1
		
	
	if Input.is_action_just_released("ui_reset_position"):
		self.position = Vector2(0, -500)
	if Input.is_action_just_released("ui_restart"):
		is_restarting = true
		$Timer.start()
	$"../CanvasLayer/L_Prestige".set_text(
		"Prestige: {v}".format({"v": "%0.2f" % prestige}))

		#get_tree().reload_current_scene()
func flip():
	if is_fliped:
		is_fliped = false
	else:
		is_fliped = true
		
	var my_plane = get_tree().get_first_node_in_group("Plane")
	
	var sprite_2d: Sprite2D = $Sprite2D
	sprite_2d.scale.y = -sprite_2d.scale.y
	
	var rear_wheel: RigidBody2D = $RearWheel
	rear_wheel.position.y = -rear_wheel.position.y  - 40
	var rear_pin_joint_2d: PinJoint2D = $RearPinJoint2D
	rear_pin_joint_2d.node_a = ""
	rear_pin_joint_2d.node_b = ""
	rear_pin_joint_2d.position.y = -rear_pin_joint_2d.position.y - 40

	rear_pin_joint_2d.node_a = my_plane.get_path()
	rear_pin_joint_2d.node_b = rear_wheel.get_path()
	
	var rear_damped_spring_joint_2d: DampedSpringJoint2D = $RearDampedSpringJoint2D
	rear_damped_spring_joint_2d.position.y = -rear_damped_spring_joint_2d.position.y

	var front_wheel: RigidBody2D = $FrontWheel
	front_wheel.position.y = -front_wheel.position.y - 40
	var pin_joint_2d_2: PinJoint2D = $PinJoint2D2
	pin_joint_2d_2.node_a = ""
	pin_joint_2d_2.node_b = ""
	pin_joint_2d_2.position.y = -pin_joint_2d_2.position.y - 40
	pin_joint_2d_2.node_a = my_plane.get_path()
	pin_joint_2d_2.node_b = front_wheel.get_path()
	if is_fliped:
		bomb_position = Vector2(20, -70)
	else:
		bomb_position = Vector2(20, 30)
	
	


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
		#return 2
		return 1.75
	elif aa < -0.087 and aa > -0.1745:
		#return -0.6
		return -0.3
	elif aa > 0.35:
		#return 0.4
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
	#print("lift_aa_coef: {v}".format({"v":lift_aa_coef}))
	#print("l_velocity.length(): {v}".format({"v":l_velocity.length()}))
	
	
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
	var ray_cast_2d_5: RayCast2D = $RayCast2D5
	var ray_cast_2d_6: RayCast2D = $RayCast2D6
	var ray_cast_2d_7: RayCast2D = $RayCast2D7

	heading_angle = wrapf(heading_angle, -PI, PI)
	my_rotation = rotation
	
	
	var aa = -(direction_vector.rotated(my_rotation)).angle_to(velocity_vector)
	#print(aa)
	#if is_inverted:
		#aa = -aa
	
	aa = wrapf(aa, -PI, PI)
	
	
	
	lift_force = lift_force_calc(aa, direction_vector, linear_velocity)
	drag_force = drag_force_calc(aa, direction_vector, linear_velocity)
	#lift_force = lift_force_calc(aa, direction_vector, linear_velocity)
	#drag_force = drag_force_calc(aa, direction_vector, linear_velocity)
	
	
	displacement = fins_position.rotated(rotation)
	
	#lift_force = lift_force.rotated(rotation)
	#drag_force = drag_force.rotated(rotation)
	
	#if is_inverted:
		#displacement.x = -displacement.x
	if is_inverted:
		#displacement = - displacement
		lift_force = - lift_force
		#if (heading_angle < PI and heading_angle > PI/2) or (heading_angle > -PI and heading_angle < -PI/2) :
			#displacement = - displacement
			##lift_force.x = - lift_force.x
			#apply_force(lift_force.rotated(rotation), displacement)
			##drag_force = - drag_force
			#apply_force(drag_force.rotated(rotation), displacement)
		#else:
			#apply_force(lift_force, displacement)
			#apply_force(drag_force, displacement)
		
	else:
		pass
	apply_force(lift_force, displacement)
	apply_force(drag_force, displacement)
	
	ray_cast_2d_2.position = displacement
	ray_cast_2d_2.target_position = lift_force
		
	#print(drag_force)
	ray_cast_2d_4.target_position = drag_force
	var displacement2 = missile_drag_position.rotated(rotation)
	#apply_force(missile_drag_force, displacement2)
	
	if has_engine:
		thrust_force = direction_vector.normalized() * power
		fuel -= power_fuel_drain * power
		if is_inverted:
			#thrust_force = thrust_force
			apply_force(thrust_force.rotated(rotation), Vector2(0,0))
		else:
			apply_force(thrust_force.rotated(rotation), Vector2(0,0))
		ray_cast_2d_7.position = displacement
		ray_cast_2d_7.target_position = thrust_force * 20
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
	#print("delta: {v}".format({"v":rad_to_deg(delta_angle)}))
	
		#if abs(delta_angle) > 0.1:
			#if is_inverted:
				#apply_torque(my_speed * torque_pitch_controlled * abs(delta_angle)/delta_angle)
			#else:
				#apply_torque(my_speed * torque_pitch_controlled * -abs(delta_angle)/delta_angle)
	
	#apply_torque( torque_pitch * c_torque_pitch)
	#print(my_speed)
	
	#print(thrust_force)
	
	ray_cast_2d.target_position = direction_vector * 300
	ray_cast_2d_3.target_position = velocity_vector
	
	label_3.set_text("{v}".format({"v": "%0.2f" % rad_to_deg(heading_angle)}))
	label_2.set_text("{v}".format({"v": "%0.2f" % rad_to_deg(current_angle)}))
	#label_2.set_text("{v}".format({"v": "%0.2f" % rad_to_deg(aa)}))
	
	var wing_forces = wing.get_forces(state.linear_velocity, direction_vector.rotated(my_rotation))
	#print(wing_forces)
	#var hardcoded_wing_pos = Vector2(-100, 0)
	if is_inverted:
		#tail_wing_pos = -tail_wing_pos
		wing_forces["lift_force"] = -wing_forces["lift_force"]
		#if (heading_angle < PI and heading_angle > PI/2) or (heading_angle > -PI and heading_angle < -PI/2) :
			#wing_forces["lift_force"] = wing_forces["lift_force"].rotated(rotation)
			#wing_forces["drag_force"] = wing_forces["drag_force"].rotated(rotation)
		#else:
			#wing_forces["lift_force"].x = - wing_forces["lift_force"].x
			#wing_forces["drag_force"] = wing_forces["drag_force"]
		##wing_forces["drag_force"].x = -wing_forces["drag_force"].x
		##wing_forces["drag_force"].x = - wing_forces["drag_force"].x
		#apply_force(wing_forces["lift_force"], tail_wing_pos)
		#apply_force(wing_forces["drag_force"], tail_wing_pos)
		#
	#else:
		#wing_forces["lift_force"] = -wing_forces["lift_force"]
		#wing_forces["drag_force"] = wing_forces["drag_force"] 
	if abs(c_torque_pitch) > 0:
		apply_torque(my_speed * torque_pitch * c_torque_pitch)
	else:
		
		sas_on()
		
	wing_forces["lift_force"] = -wing_forces["lift_force"]
	apply_force(wing_forces["lift_force"], tail_wing_pos)
	apply_force(wing_forces["drag_force"], tail_wing_pos)
		
	ray_cast_2d_5.position = tail_wing_pos
	ray_cast_2d_5.target_position = wing_forces["lift_force"] * 20
	ray_cast_2d_6.position = tail_wing_pos
	ray_cast_2d_6.target_position = wing_forces["drag_force"] * 20
		
	
	#apply_force(wing_forces["lift_force"], wing.position)
	#apply_force(wing_forces["drag_force"], wing.position)
	
	
	#print("my rotation: {v}".format({"v":rad_to_deg(my_rotation)}))
	#print("aa: {v}".format({"v":aa}))
	#print("Main Lift: {v}".format({"v":lift_force}))
	#print("Main vertival forces: {v}".format({"v": lift_force}))
	#print("Main vertival forces: {v}".format({"v":lift_force.y + state.get_constant_force().y + drag_force.y + 
		#- wing_forces["lift_force"].y - wing_forces["drag_force"].y
	#}))
	##print("aa: {v}".format({"v":rad_to_deg(aa)}))
	#print("velocity vector: {v}".format({"v":velocity_vector.length()}))
	#print("velocity vector angle: {v}".format({"v":rad_to_deg(velocity_vector.angle())}))
	#
	#print("Angular velocity: {v}".format({"v":state.angular_velocity}))
	#print("Torque constant: {v}".format({"v":state.get_constant_torque()}))
	#
	#print("Tail Lift: {v}".format({"v":-wing_forces["lift_force"].y}))
	
func calculate_area_aa(aa):
	if abs(aa) > PI/2:
		return 0.5
		
	return 4 * 0.4/PI * abs(aa) + 0.1

func _on_timer_prime_timeout():
	collision_shape_2d.disabled = false


func _on_rate_fire_timeout() -> void:
	ready_to_fire = true
	
