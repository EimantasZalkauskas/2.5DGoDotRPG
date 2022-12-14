extends KinematicBody2D

export var MAX_SPEED = 100
export var ROLL_SPEED = 125
export var ACCELERATION = 500
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vec = Vector2.DOWN
var stats = PlayerStats
var actionUI = ActionsUi


onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitback = $HitboxPivot/SwordHitbox
onready var hurtBox = $HurtBox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var postActionCountdownTimer = $PostActionCoutdownTimer

func _ready():
	
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitback.knockback_vec = roll_vec

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	
	player_health_loss()

func move_state(delta):
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vec = input_vec.normalized()
	
	if input_vec != Vector2.ZERO:
		roll_vec = input_vec
		swordHitback.knockback_vec = input_vec
		animationTree.set("parameters/Idle/blend_position", input_vec)
		animationTree.set("parameters/Run/blend_position", input_vec)
		animationTree.set("parameters/Attack/blend_position", input_vec)
		animationTree.set("parameters/Roll/blend_position", input_vec)
		animationState.travel("Run")
		
		velocity = velocity.move_toward(input_vec * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	
	move()
	if Input.is_action_just_pressed("roll"):
		if actionUI.roll_ready == true:
			if stamina_reduced(2):
				state = ROLL
				stats.roll_cooldown()
				post_action_coutdown_init()
				stamina_regen_reset()
	
	if Input.is_action_just_pressed("attack"):
		if actionUI.attack_ready == true:
			if stamina_reduced(1):
				state = ATTACK
				stats.attack_cooldown()
				print(actionUI.attack_ready)
				post_action_coutdown_init()
				stamina_regen_reset()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func roll_state():
	velocity = roll_vec * ROLL_SPEED
	animationState.travel("Roll")
	move()

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity / 2
	state = MOVE

func attack_animation_finished():
	state = MOVE

func player_health_loss():
	if hurtBox.damage_area != null:
		stats.health -= hurtBox.damage_area.damage
		hurtBox.damage_area = null
		
func stamina_reduced(val):
	if stats.stamina >= val:
		stats.stamina -= val
		return true

func post_action_coutdown_init():
	postActionCountdownTimer.start(4)
	
func stamina_regen_reset():
	stats.update_stamina_regen_speed(1)

	

func _on_HurtBox_area_entered(area):
	hurtBox.check_area_overlap(area, true, blinkAnimationPlayer)
	

func _on_PostActionCoutdownTimer_timeout():
	stats.update_stamina_regen_speed(0.5)
