extends RigidBody2D

@export var input: PlayerInput
@export var raycast: RayCast2D
@export var spring: DampedSpringJoint2D
@export var remote: RemoteTransform2D

@export var force := 800
@export var jump_force := 200

@export var max_speed := 500

func _ready():
	pass

func _process(delta):
	raycast.global_rotation = Vector2.DOWN.angle_to(global_position.direction_to(get_global_mouse_position()))

func _physics_process(delta):
	var dir = Vector2(input.get_action_strength("move_left") - input.get_action_strength("move_right"), 0) * force
	apply_central_force(dir)


func _on_player_input_just_pressed(ev: InputEvent):
	if ev.is_action_pressed("jump"):
		apply_central_impulse(Vector2.UP * jump_force)
	
	if ev.is_action_pressed("fire") and raycast.is_colliding():
		var collider = raycast.get_collider()
		var point = raycast.get_collision_point()
		spring.node_a = spring.get_path_to(collider)
		spring.rest_length = global_position.distance_to(point)
		remote.update_rotation = false
	
	if ev.is_action_released("fire"):
		spring.node_a = NodePath("")
		remote.update_rotation = true


func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity= state.linear_velocity.normalized() * max_speed
		
#	_set_jump_state(state)
#
#func _set_jump_state(state):
#	for i in range(0, state.get_contact_count()):
#		if state.get_contact_local_normal(i).dot(Vector2.UP) >= 0.5:
#			can_jump = true
#			return
#	can_jump = false
