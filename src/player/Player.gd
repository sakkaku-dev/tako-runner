extends CharacterBody2D

enum {
	MOVE,
	STICK,
	SWING,
	JUMP,
}

@export var input: PlayerInput
@export var raycast: RayCast2D

@export var vertical_speed := 200
@export var vertical_accel := 100

@export var speed := 500
@export var accel := 800
@export var jump_force := 300

@export var pull_force := 0.1
@export var max_pull_force := 100.0
@export var tentacle_length := 400
@export var dampening := 0.02

@export var sticky_delay := 0.3

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")

var connected_point
var delay := 0.0
var state = MOVE

func _ready():
	raycast.target_position = Vector2.DOWN * tentacle_length

func _is_touching():
	return is_on_ceiling() or is_on_floor() or is_on_wall()

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

func _move(delta):
	var motion_x = input.get_action_strength("move_left") - input.get_action_strength("move_right")
	velocity.x = move_toward(velocity.x, motion_x * speed, accel * delta)
	velocity += gravity

func _swing(delta):
	if delay >= sticky_delay and _is_touching():
		state = STICK
		return
	
	var dir = global_position.direction_to(connected_point)
	var dist = global_position.distance_to(connected_point)
	
#	if dist < 10 and _is_touching():
#		state = STICK
#		return
	
	var displacement = dist
	var force = pull_force * displacement
	if force > max_pull_force:
		force = max_pull_force
	
	velocity += dir * force - dampening * velocity
#	velocity += gravity

func _stick(delta):
	velocity = Vector2.ZERO

func _jump(delta):
	var dir = Vector2.UP
	
	if is_on_wall():
		var normal = raycast.get_collision_normal()
		dir = dir + normal
		connected_point = null
	
	velocity += dir * jump_force
	state = MOVE

func _on_player_input_just_received(ev: InputEvent):
	if ev.is_action_pressed("jump") and _is_touching():
		state = JUMP

	if ev.is_action_pressed("fire") and raycast.is_colliding():
		delay = 0
		connected_point = raycast.get_collision_point()
		state = SWING

	if ev.is_action_released("fire"):
		connected_point = null
		state = MOVE

