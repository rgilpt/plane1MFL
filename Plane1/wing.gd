extends RigidBody2D

enum WingProfileType{
	SYMETRICAL,
	CAMBERED
}


var lift_force = Vector2()
var drag_force = Vector2()

@export var total_fins_area = 0.05
@export var cl = 0.2

@export var total_fins_section_area = 0.02
@export var cd = 0.3
@export var wing_profile_type:WingProfileType = WingProfileType.SYMETRICAL

var is_inverted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func angle_of_attack_calculation(a, b):
	
	return acos(a.dot(b)/(a.length() * b.length()))

func lift_angle_of_attack_mod_simetrical(aa):
	if aa > 0.01 and aa < 0.262:
		return 5.747 * aa
	elif aa >= 0.262 and aa < 0.35:
		return 1.75
	elif aa <= 0.262 and aa > 0.35:
		return -1.75
	elif aa > 0.35:
		return 0
	elif aa < -0.35:
		return 0
	elif aa < -0.01 and aa > -0.262:
		return -5.747 * aa
	else:
		return 0
		
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
			(PI/2-(abs(aa) - PI/2))/ (PI/2)) + total_fins_section_area

func lift_force_calc(aa, direction_vector, l_velocity):
	var lift_force = direction_vector.rotated(-PI/2).normalized()
	
	var lift_aa_coef = lift_angle_of_attack_mod_simetrical(aa)
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
	print(state.get_constant_force())
	var direction_vector = Vector2(1,0)
	var velocity_vector = state.linear_velocity


	var aa = -(direction_vector.rotated(rotation)).angle_to(velocity_vector)
	aa = wrapf(aa, -PI, PI)
	#if is_inverted:
		#aa = -aa

	lift_force = lift_force_calc(aa, direction_vector, linear_velocity)
	drag_force = drag_force_calc(aa, direction_vector, linear_velocity)

	var displacement = Vector2()
	apply_force(lift_force.rotated(rotation), displacement)
	apply_force(drag_force, displacement)
	
	print("Wing Lift force: {v}".format({"v":lift_force.rotated(rotation)}))
	
