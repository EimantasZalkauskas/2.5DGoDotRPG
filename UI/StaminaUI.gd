extends Control

var stamina = 6 setget set_stamina
var max_stamina =  6 setget set_max_stamina

onready var staminaUIFull = $StaminaUIFull
onready var staminaUIEmpty = $StaminaUIEmpty


func set_stamina(value):
	stamina = clamp(value, 0, max_stamina)
	if staminaUIFull != null:
		staminaUIFull.rect_size.x = stamina * 10

func set_max_stamina(value):
	max_stamina = max(value, 1)
	self.stamina = min(stamina, max_stamina)
	if staminaUIEmpty != null:
		staminaUIEmpty.rect_size.x = max_stamina * 10

func _ready():
	self.max_stamina = PlayerStats.max_stamina
	self.stamina = PlayerStats.stamina
	PlayerStats.connect("stamina_changed", self, "set_stamina")
	PlayerStats.connect("max_stamina_change", self, "set_max_stamina")
