extends CharacterBody2D

var speed : float = 200

var jump_height : float = 100
var time_to_peak : float = 0.5
var time_to_fall : float = 0.3

var _coyote_time : float = 0.0
var _jump_buffer : float = 0.0
var _jumped : bool = false

var _jump_velocity : float = ((2.0 * jump_height) / time_to_peak)


func _get_gravity() -> float:
	if velocity.y >= 0 and Input.is_action_pressed("jump"):
		return ((2.0 * jump_height) / (time_to_peak ** 2))
	else:
		pass
		_jumped = false
		return ((2.0 * jump_height) / (time_to_fall ** 2))

func _jump() -> void:
	velocity.y = -_jump_velocity
	_jumped = true

func _physics_process(delta) -> void:
	if is_on_floor():
		_coyote_time = 0.1
		if Input.is_action_just_pressed("jump") or _jump_buffer > 0.0:
			_jump()
	else:
		velocity.y += _get_gravity() * delta
		if _coyote_time > 0 and Input.is_action_just_pressed("jump"):
			_jump()
		elif Input.is_action_just_pressed("jump"):
			_jump_buffer = 0.2
			
		_coyote_time -= delta
		_jump_buffer -= delta
		
	
	velocity.x = clamp(Input.get_axis("left", "right")*100, -1.0, 1.0) * speed
	
	move_and_slide()
	print(velocity)
