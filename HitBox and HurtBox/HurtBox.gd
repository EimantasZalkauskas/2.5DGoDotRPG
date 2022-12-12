extends Area2D


const HitEffect = preload("res://Effects/HitEffect.tscn")
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export(float) var collision_disabled_on_hit_leangth = 0.5

var damage_area = null
var player = null

onready var collisionShape = $CollisionShape2D


func create_hit_effect(area, player, blinkAnimationPlayer):
	if player == true:
		player_getting_hit()
	animation()
	blinking(blinkAnimationPlayer)
	collision_shape_status()
	damage_area = area
	
	

func check_area_overlap(area, player, blinkAnimationPlayer):
	yield(get_tree().create_timer(0.5), "timeout")
	if overlaps_area(area):
		create_hit_effect(area, player, blinkAnimationPlayer)
		check_area_overlap(area, player,  blinkAnimationPlayer)


func animation():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func blinking(blinkAnimationPlayer):
	blinkAnimationPlayer.play("Start")
	yield(get_tree().create_timer(0.5), "timeout")	
	blinkAnimationPlayer.play("Stop")

func player_getting_hit():
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func collision_shape_status():
	collisionShape.disabled = true
	yield(get_tree().create_timer(collision_disabled_on_hit_leangth), "timeout")	
	collisionShape.disabled = false


