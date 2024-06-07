extends State

@export var speed := 100
@export var accel := 1000
@export var leave_slide_threshold := 0.2

@onready var player: Player = owner

var leave_motion := 0.0
var wall_dir := Vector2.ZERO

func enter():
	print("STICK")
	leave_motion = 0
	player.velocity = Vector2.ZERO
	wall_dir = player.get_wall_collision()

	if player.is_on_floor():
		player.state = Player.MOVE

func process(delta: float):
	var motion = player.get_motion()
	var motion_dot = motion.dot(wall_dir)
	
	#var other_valid_moves = player.get_wall_collisions()
	#
	#var other_move = motion.normalized()
	#if motion_dot != 0 and other_move in other_valid_moves:
		#wall_dir = other_move
		#return
		
	if motion_dot >= 1:
		leave_motion += delta
	else:
		leave_motion = 0
		
	var moved_away_from_wall = leave_motion >= leave_slide_threshold
	if player.is_on_floor() or not player.get_wall_collision() or moved_away_from_wall:
		player.state = Player.MOVE
		return
	
	var move_dir = wall_dir.rotated(PI/2)
	var move = motion * abs(move_dir)
	player.velocity = player.velocity.move_toward(move * speed, accel * delta)
	player.flip(wall_dir.x < 0)

	if not player.get_wall_collision():
		player.state = Player.MOVE

func handle(event: InputEvent):
	if event.is_action_pressed("jump"):
		if player.get_wall_collision().dot(Vector2.LEFT) == 0:
			player.state = Player.MOVE
		else:
			player.state = Player.WALL_JUMP
