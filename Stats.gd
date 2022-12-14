extends Node

export var max_health = 1 setget set_max_health
export var max_stamina = 0 setget set_max_stamina
export var stamina_regen_amount = 1
export var stamina_regen_speed = 1

var health = max_health setget set_health
var stamina = max_stamina setget set_stamina
var min_stamina = 0
var no_action = true

signal no_health
signal health_changed(value)
signal max_health_change(value)

signal no_stamina
signal stamina_changed(value)
signal max_stamina_change(value)

signal attack_cooldown(value)
signal roll_cooldown(value)

onready var constTimer = $ConstStaminaRegenTimer

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_change", max_health)

func set_max_stamina(value):
	max_stamina = value
	self.stamina = min(stamina, max_stamina)
	emit_signal("max_stamina_change", max_stamina)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_stamina(value):
	stamina = value
	stamina = clamp(stamina, min_stamina, max_stamina)
	emit_signal("stamina_changed", stamina)
	if stamina <= 0:
		emit_signal("no_stamina")


func set_stamina_regeneration(value):
	if stamina < max_stamina:
		stamina += value
		emit_signal("stamina_changed", stamina)

func update_stamina_regen_speed(value):
	stamina_regen_speed = value


func attack_cooldown():
	emit_signal("attack_cooldown")

func roll_cooldown():
	emit_signal("roll_cooldown")
	

func _ready():
	self.health = max_health
	self.stamina = max_stamina


func _on_ConstStaminaRegenTimer_timeout():
	set_stamina_regeneration(stamina_regen_amount)
	constTimer.start(stamina_regen_speed)
