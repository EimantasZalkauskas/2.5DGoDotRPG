extends Control

var attackTimerRestartDuration = 0.1
var attack_ready = true
var roll_ready = true

onready var swordAttackReady = $SwordAttackReady
onready var swordAttackEmpty = $SwordAttackEmpty
onready var rollReady = $RollReady
onready var rollEmpty = $RollEmpty

signal attack_ready_status(value)

func on_attack():
	if attack_ready == true:
		swordAttackEmpty.rect_size.x = 15
		attack_ready = false
		attackCoolDownReset()
		

func attackCoolDownReset():
	if swordAttackEmpty.rect_size.x != 0:
		yield(get_tree().create_timer(0.1), "timeout")
		swordAttackEmpty.rect_size.x -= 1.5
		attackCoolDownReset()
	else:
		attack_ready = true

func on_roll():
	if roll_ready == true:
		rollEmpty.rect_size.x = 15
		roll_ready = false
		rollCoolDownReset()
		

func rollCoolDownReset():
	if rollEmpty.rect_size.x != 0:
		yield(get_tree().create_timer(0.1), "timeout")
		rollEmpty.rect_size.x -= 1.5
		rollCoolDownReset()
	else:
		roll_ready = true


func _ready():
	PlayerStats.connect("attack_cooldown", self, "on_attack")
	PlayerStats.connect("roll_cooldown", self, "on_roll")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

