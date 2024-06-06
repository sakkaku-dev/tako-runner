extends State

@export var speed := 300
@export var accel := 800
@export var tentacle_cast: RayCast2D

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")
@onready var player: Player = owner

func process(delta: float):
	var dir = player.global_position.direction_to(tentacle_cast.get_global_mouse_position())
	tentacle_cast.global_rotation = Vector2.DOWN.angle_to(dir)
	
	var motion_x = player.get_motion().x
	
	if player.is_on_floor():
		player.animation_player.play("run" if motion_x != 0 or player.velocity.length() > 0 else "idle")
	else:
		player.animation_player.play("jump")
		
	if motion_x:
		player.flip(motion_x < 0)

	player.velocity.x = move_toward(player.velocity.x, motion_x * speed, accel * delta)
	player.velocity += gravity
	
	#if p.is_on_wall() or player.is_on_ceiling():
		##time += delta
		##if time >= stick_delay:
		#p.state = Player.State.STICK
		
	if not player.is_on_floor() and player.is_moving_against_wall() and player.velocity.y >= 0:
		player.state = Player.STICK

func handle(event: InputEvent):
	if event.is_action_pressed("jump"):
		if player.is_on_floor():
			player.state = Player.JUMP
		elif player.get_wall_collision():
			player.state = Player.WALL_JUMP
	elif event.is_action_pressed("fire") and tentacle_cast.is_colliding():
		player.connected_point = tentacle_cast.get_collision_point()
		player.state = Player.SWING

func just_released(action: String):
	if action == "jump":
		if player.velocity.y < 0:
			player.velocity.y = 0
