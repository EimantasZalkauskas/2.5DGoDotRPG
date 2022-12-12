extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var TARGET_WANDER_RANGE = 6

enum {
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				check_state_wander_idle()
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				check_state_wander_idle()
			accelerate_towards_point(wanderController.targetPosition, delta)
			
			if global_position.distance_to(wanderController.targetPosition) <= TARGET_WANDER_RANGE:
				check_state_wander_idle()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				check_state_wander_idle()
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vec() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(position, delta):
	var direction = global_position.direction_to(position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func check_state_wander_idle():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_HurtBox_area_entered(area):
	knockback = area.knockback_vec * 120
	hurtbox.create_hit_effect(area, false, blinkAnimationPlayer)
	stats.health -= hurtbox.damage_area.damage


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
