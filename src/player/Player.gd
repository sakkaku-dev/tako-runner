extends CharacterBody2D

enum {
	MOVE,
	STICK,
	SWING,
	JUMP,
}

@export var input: PlayerInput
@export var raycast: RayCast2D

@export var speed := 400
@export var accel := 800
@export var jump_force := 300

@export var tentacle_length := 400
@export var pull_force := 0.7
@export var max_pull_force := 100.0
@export var dampening := 0.1

@export var swing_move_force := 5
@export var decrease_swing_dist := 50

@export var sticky_delay := 0.3

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")

var swing_dist := 0.0
var connected_point
var delay := 0.0
var state = MOVE

func _ready():
	raycast.target_position = Vector2.DOWN * tentacle_length

func _is_touching():
	return is_on_ceiling() or is_on_wall()

func _process(delta):
	if connected_point != null:
		delay += delta
		raycast.global_rotation = Vector2.DOWN.angle_to(global_position.direction_to(connected_point))
	else:
		raycast.global_rotation = Vector2.DOWN.angle_to(global_position.direction_to(get_global_mouse_position()))
		
func _physics_process(delta):
	match state:
		MOVE: _move(delta)
		SWING: _swing(delta)
		STICK: _stick(delta)
		JUMP: _jump(delta)
	
	move_and_slide()

func _get_motion():
	return Vector2(
		input.get_action_strength("move_left") - input.get_action_strength("move_right"),
		input.get_action_strength("move_down") - input.get_action_strength("move_up")
	)

func _move(delta):
	var motion_x = _get_motion().x
	velocity.x = move_toward(velocity.x, motion_x * speed, accel * delta)
	velocity += gravity

func _swing(delta):
	if delay >= sticky_delay and _is_touching():
		state = STICK
		return
	
	var dir = global_position.direction_to(connected_point)
	var current_dist = global_position.distance_to(connected_point)
	var motion = _get_motion()
		
	# https://stackoverflow.com/questions/75195734/descending-pendulum-motion-in-physics-process
	var gravity_speed = 1500 #30000
	var air_resistance = -200
		
	velocity.y += gravity_speed * delta
	velocity += (velocity.normalized() * air_resistance * delta).limit_length(velocity.length())

	#pendulum motion
	var theta=Vector2.RIGHT.angle_to(connected_point - global_position) * -1 # angle between local x_axis & pivot point vector 
	var sin_theta=sin(theta)
	var cos_theta=cos(theta)
	velocity.x = velocity.x + velocity.y*sin_theta*cos_theta - velocity.x*cos_theta*cos_theta
	velocity.y = velocity.y + velocity.x*sin_theta*cos_theta - velocity.y*sin_theta*sin_theta

	var tension = clamp(current_dist - swing_dist, 0, 1) * gravity_speed
	velocity += dir * tension * delta
	
	velocity.x += motion.x * swing_move_force

func _stick(delta):
	velocity = Vector2.ZERO

func _jump(delta):
	var dir = Vector2.UP
	var motion_x = _get_motion().x
	var normal = raycast.get_collision_normal()
	
	if is_on_wall() and normal.dot(Vector2(motion_x, 0)) > 0:
		dir = dir + Vector2(motion_x, 0)
		
	connected_point = null
	velocity += dir * jump_force
	state = MOVE

func _on_player_input_just_received(ev: InputEvent):
	if ev.is_action_pressed("jump") and (is_on_floor() or connected_point != null and _is_touching()):
		state = JUMP
	elif ev.is_action_pressed("fire") and raycast.is_colliding():
		delay = 0
		connected_point = raycast.get_collision_point()
		swing_dist = global_position.distance_to(connected_point)
		state = SWING
	elif ev.is_action_released("fire"):
		connected_point = null
		state = MOVE

