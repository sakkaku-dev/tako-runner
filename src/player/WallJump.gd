extends State

@export var jump_force := 400
@export var jump_angle := 70.0

@onready var player: Player = owner

func enter():
	var dir = player.get_wall_collision()
	if dir:
		dir = dir.rotated(deg_to_rad(jump_angle) * -sign(dir.x))
		
		player.velocity += dir * jump_force
		player.flip(sign(dir.x) < 0)
		
	player.state = Player.MOVE
