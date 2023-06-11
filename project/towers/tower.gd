class_name Tower
extends Target

@export var health := 10


func damage(attack_array:Array)->void:
	for attack in attack_array:
		health -= attack.damage
	if health <= 0:
		_set_is_dead(true)


func _draw()->void:
	draw_circle(Vector2.ZERO, 30, Color.BLANCHED_ALMOND)
