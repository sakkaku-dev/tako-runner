extends State

@export var swing_move_force := 5
@export var decrease_swing_dist := 50
@export var stick_delay := 0.1
@export var tentacle_cast: RayCast2D

@export var pull_speed := 100
@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")
@onready var player: Player = owner

var reduce_swing_dist := 0.0
var swing_dist := 0.0
var time := 0.0

func enter():
	reduce_swing_dist = 0.0
	swing_dist = 0.0
	time = .0
	swing_dist = player.get_contact_point().length()

func process(delta: float):
	tentacle_cast.global_rotation = Vector2.DOWN.angle_to(player.global_position.direction_to(player.connected_point))
	
	var point = player.get_contact_point()
	var dir = point.normalized()
	var current_dist = point.length()
	var motion = player.get_motion()
	var normal = player.get_contact_normal()
	
	player.animation_player.play("jump")
	if motion.x:
		player.flip(motion.x < 0)
	else:
		player.flip(player.velocity.x < 0)
	
	#if player.ground_cast.is_colliding():
		#var collision = player.ground_cast.get_collision_point()
		#var dist = player.global_position.distance_to(collision)
		#var relative = dist / player.ground_cast.target_position.y
		#reduce_swing_dist += 500 / max(relative, 0.01)
	#else:
		#reduce_swing_dist = 0
	
	var contact_ceiling: bool = normal.dot(Vector2.DOWN) > 0.8 #and normal.dot(dir) <= -0.8
	
	if contact_ceiling:
		# https://stackoverflow.com/questions/75195734/descending-pendulum-motion-in-physics-process
		var gravity_speed = 1500 #30000
		var air_resistance = -200
		var swing_length = swing_dist - reduce_swing_dist
		
		player.velocity.y += gravity_speed * delta
		player.velocity += (player.velocity.normalized() * air_resistance * delta).limit_length(player.velocity.length())

		#pendulum motion
		var theta=Vector2.RIGHT.angle_to(point) * -1 # angle between local x_axis & pivot point vector
		var sin_theta=sin(theta)
		var cos_theta=cos(theta)
		player.velocity.x = player.velocity.x + player.velocity.y*sin_theta*cos_theta - player.velocity.x*cos_theta*cos_theta
		player.velocity.y = player.velocity.y + player.velocity.x*sin_theta*cos_theta - player.velocity.y*sin_theta*sin_theta

		var tension = clamp(current_dist - swing_length, 0, 1) * gravity_speed
		player.velocity += dir * tension * delta
	
		if Input.is_action_pressed("pull"):
			player.velocity += dir * pull_speed
			
		player.velocity.x += motion.x * swing_move_force
	else:
		player.velocity += dir * pull_speed
	
	if player.is_on_wall() or player.is_on_ceiling() or player.is_on_floor():
		time += delta
		#if time >= stick_delay:
		player.state = Player.STICK
	else:
		time = .0

func handle(ev: InputEvent):
	if ev.is_action_released("fire"):
		player.state = Player.MOVE
