extends State

@export var jump_force := 300
@onready var player: Player = owner

func enter():
	print("JUMP")
	player.velocity += Vector2.UP * jump_force
	player.state = Player.MOVE
