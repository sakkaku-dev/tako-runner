extends State

@export var speed := 100
@export var accel := 1000

func enter(p: Player):
	p.velocity = Vector2.ZERO

func process(p: Player, delta: float):
	var motion = p.get_motion()
	var move_dir = p.get_stick_normal().rotated(PI/2)
	
	var move = motion * abs(move_dir)
	p.velocity = p.velocity.move_toward(move * speed, accel * delta)

	if not p.is_stick_colliding():
		p.state = Player.State.MOVE
	elif Input.is_action_just_pressed("jump"):
		p.state = Player.State.JUMP
