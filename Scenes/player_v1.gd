extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D

@export var SPEED: float = 300.0
@export var SPRINT_SPEED: float = 550.0
@export var ACCELERATION: float = 1000.0
@export var SPRINT_ACCELERATION: float = 1300.0
@export var FRICTION: float = 1000.0
@export var JUMP_VELOCITY: float = -600.0
@export var GRAVITY: float = 1000.0  # Ajuste selon le ressenti désiré
const COYOTE_TIME: float = 0.1  # Temps après avoir quitté le sol où on peut encore sauter
const JUMP_BUFFER: float = 0.1  # Temps après avoir appuyé sur saut où il est encore pris en compte
const JUMP_CUT_MULTIPLIER: float = 0.5  # Permet d'annuler un saut en relâchant rapidement

#var velocity_y := 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_jumping: bool = false
var stored_max_speed: float = SPEED

func _physics_process(delta: float) -> void:
	# Gestion du Coyote Time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Gestion du Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer -= delta

	# Ajout de la gravité
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Gestion du sprint uniquement au sol
	var is_sprinting := Input.is_action_pressed("fire")  # Sprint activé ?
	var max_speed = SPRINT_SPEED if is_sprinting else SPEED
	var acceleration = SPRINT_ACCELERATION if is_sprinting else ACCELERATION

	# Si on est sur le sol, on met à jour la vitesse max autorisée
	if is_on_floor():
		stored_max_speed = max_speed

	# Gestion du saut
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0
		jump_buffer_timer = 0
		is_jumping = true  # On marque le saut

	# Jump Cut : permet d'annuler un saut en relâchant le bouton
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# Déplacement horizontal
	var direction := Input.get_axis("left", "right")
	var is_turning = direction != 0 and sign(direction) != sign(velocity.x) and velocity.x != 0

	# En l'air, on garde la vitesse max qui était active au moment du saut
	if not is_on_floor():
		max_speed = stored_max_speed

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Gestion des animations
	_update_animation(direction, is_turning, is_sprinting)

	move_and_slide()

func _update_animation(direction: float, is_turning: bool, is_sprinting: bool) -> void:
	if not is_on_floor():  
		sprite.play("jump")
	elif is_turning:
		sprite.play("turn")
	elif direction != 0:
		sprite.flip_h = direction < 0
		sprite.play("run" if not is_sprinting else "run")  
	else:
		sprite.play("idle")
