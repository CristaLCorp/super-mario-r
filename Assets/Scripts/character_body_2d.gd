extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D

@export var SPEED = 300.0
@export var SPRINT_SPEED = 600.0
@export var ACCELERATION = 1200.0
@export var SPRINT_ACCELERATION = 1600.0
@export var FRICTION = 800.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 1200.0  # Ajuste selon le ressenti désiré
const COYOTE_TIME = 0.1  # Temps après avoir quitté le sol où on peut encore sauter
const JUMP_BUFFER = 0.1  # Temps après avoir appuyé sur saut où il est encore pris en compte
const JUMP_CUT_MULTIPLIER = 0.5  # Permet d'annuler un saut en relâchant rapidement

#var velocity_y := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var is_jumping := false

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

	# Gestion du saut
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0  # On annule le coyote time pour éviter un double saut
		jump_buffer_timer = 0  # On annule le buffer car le saut est déclenché
		is_jumping = true

	# Jump Cut : permet d'annuler un saut en relâchant le bouton
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# Gestion du sprint
	var is_sprinting := Input.is_action_pressed("fire")  # Assigner "sprint" à une touche (comme Shift ou B)
	var max_speed = SPRINT_SPEED if is_sprinting else SPEED
	var acceleration = SPRINT_ACCELERATION if (is_sprinting and is_on_floor()) else ACCELERATION

	# Déplacement horizontal
	var direction := Input.get_axis("left", "right")
	
	# Vérifie si le joueur appuie dans la direction opposée au mouvement
	var is_turning = direction != 0 and sign(direction) != sign(velocity.x) and velocity.x != 0

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Gestion des animations
	_update_animation(direction, is_turning, is_sprinting)
	
	move_and_slide()
	
func _update_animation(direction: float, is_turning: bool, is_sprinting: bool) -> void:
	if not is_on_floor():  # Si le joueur est en l'air
		sprite.play("jump")
	elif is_turning:  # Si le joueur change brusquement de direction
		sprite.play("turn")
	elif direction != 0:  # Si le joueur court
		sprite.flip_h = direction < 0
		sprite.play("run" if not is_sprinting else "run")
	else:  # Si le joueur est immobile
		sprite.play("idle")
