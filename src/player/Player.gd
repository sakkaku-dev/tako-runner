class_name Player
extends CharacterBody2D

enum {
	MOVE,
	STICK,
	SWING,
	JUMP,
	WALL_JUMP,
	PULL,
}

@export var input: PlayerInput
@export var raycast: RayCast2D
@export var ground_cast: RayCast2D
@export var stick_cast: RayCast2D

@export var sticky_delay := 0.3

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity_vector") * ProjectSettings.get("physics/2d/default_gravity")
@onready var koyori_timer = $KoyoriTimer
@onready var contact = $Contact
@onready var jump_buffer = $JumpBuffer
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $CollisionShape2D/Sprite2D

@onready var left_wall_cast = $LeftWallCast
@onready var right_wall_cast = $RightWallCast
@onready var top_wall_cast = $TopWallCast
@onready var bot_wall_cast = $BotWallCast
@onready var wall_casts = [top_wall_cast, left_wall_cast, right_wall_cast, bot_wall_cast]

@onready var states := {
	MOVE: $States/Move,
	SWING: $States/Swing,
	STICK: $States/Stick,
	JUMP: $States/Jump,
	WALL_JUMP: $States/WallJump

}

var connected_point:
	set(v):
		connected_point = v
		if v:
			contact.show()
			contact.global_position = v
		else:
			contact.hide()

var state = MOVE:
	set(s):
		_get_state().exit()
		state = s
		_get_state().enter()

func _get_state(s = state):
	return states[s]
	
func _ready():
	contact.hide()
	jump_buffer.jump.connect(func(): self.state = JUMP)
	
func _physics_process(delta):
	_get_state().process(delta)
	move_and_slide()
	
	#var last_collision = get_last_slide_collision()
	#if last_collision:
		#var n = last_collision.get_normal()
		#stick_cast.target_position = -n * 20

func get_motion():
	return Vector2(
		input.get_action_strength("move_left") - input.get_action_strength("move_right"),
		input.get_action_strength("move_down") - input.get_action_strength("move_up")
	)

func _on_player_input_just_received(ev: InputEvent):
	#if ev.is_action_pressed("jump"):
		#if (koyori_timer.can_jump() or connected_point != null):
			#self.state = JUMP
		#else:
			#jump_buffer.buffer_jump()
	#elif ev.is_action_pressed("fire") and raycast.is_colliding():
		#self.connected_point = raycast.get_collision_point()
		#self.state = SWING
	#else:
	_get_state().handle(ev)

func get_wall_collision():
	for cast in wall_casts:
		if cast.is_colliding():
			return cast.get_collision_normal()
	
	return Vector2.ZERO

func is_moving_against_wall():
	return is_on_wall() and get_wall_collision()

func remove_contact():
	self.connected_point = null

func get_contact_normal():
	return raycast.get_collision_normal()

func get_contact_distance() -> float:
	if connected_point == null:
		return 0.0
	return global_position.distance_to(connected_point)

func get_contact_direction() -> Vector2:
	if connected_point == null:
		return Vector2.ZERO
	return global_position.direction_to(connected_point)

func get_contact_point() -> Vector2:
	if connected_point == null:
		return Vector2.ZERO
	return connected_point - global_position

func flip(flipped: bool):
	sprite_2d.scale.x = -1 if flipped else 1
