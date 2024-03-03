extends State

@export var speed := 300
@export var accel := 800
@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")

func process(p: Player, delta: float):
	var motion_x = p.get_motion().x
	p.velocity.x = move_toward(p.velocity.x, motion_x * speed, accel * delta)
	p.velocity += gravity
