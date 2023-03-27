extends CharacterBody2D

@export var input: PlayerInput
@export var raycast: RayCast2D

@export var vertical_speed := 200
@export var vertical_accel := 100

@export var speed := 800
@export var accel := 500
@export var jump_force := 600

@export var tentacle_length := 200
@export var dampening := 0.02

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")

var connected_point
var resting_length := 0

func _ready():
	raycast.target_position = Vector2.DOWN * tentacle_length

func _process(delta):
	if connected_point:
		raycast.global_rotation = Vector2.DOWN.angle_to(global_position.direction_to(connected_point))
	else:
		raycast.global_rotation = Vector2.DOWN.angle_to(global_position.direction_to(get_global_mouse_position()))

func _physics_process(delta):
	var motion_x = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	velocity.x = move_toward(velocity.x, motion_x * speed, accel * delta)
	velocity += gravity
	
	if connected_point:
		var dir = global_position.direction_to(connected_point)
		var displacement = -(resting_length - global_position.distance_to(connected_point))
		var tension = 0.3
		
		velocity += dir * tension * displacement# - dampening * velocity
		
		var motion_y = input.get_action_strength("move_down") - input.get_action_strength("move_up")
		if motion_y != 0:
			velocity.y = move_toward(velocity.y, motion_y * vertical_speed, vertical_accel * delta)

# Hooke's Law
# Force = Tension * Displacement (TargetHeight - Height)

# Newtons Second Law of Motion
# Force = Mass * Acceleration

# Acceleration = (Tension / Mass) * Displacement - (Dampening * Velocity)
# Speed += (Tension / Mass) * Displacement - (Dampening * Velocity)
	
	move_and_slide()

func _on_player_input_just_received(ev: InputEvent):
	if ev.is_action_pressed("jump") and is_on_floor():
		velocity += Vector2.UP * jump_force

	if ev.is_action_pressed("fire") and raycast.is_colliding():
		connected_point = raycast.get_collision_point()
		resting_length = global_position.distance_to(connected_point)

	if ev.is_action_released("fire"):
		connected_point = null

#
#
#func _integrate_forces(state):
#	if state.linear_velocity.length() > max_speed:
#		state.linear_velocity= state.linear_velocity.normalized() * max_speed
		
#	_set_jump_state(state)
#
#func _set_jump_state(state):
#	for i in range(0, state.get_contact_count()):
#		if state.get_contact_local_normal(i).dot(Vector2.UP) >= 0.5:
#			can_jump = true
#			return
#	can_jump = false
