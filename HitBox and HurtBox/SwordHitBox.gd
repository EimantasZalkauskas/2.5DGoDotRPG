extends "res://HitBox and HurtBox/HitBox.gd"


onready var collisionShape2D = $CollisionShape2D
var knockback_vec = Vector2.ZERO

func _ready():
	collisionShape2D.disabled = true
