class_name Soldier
extends Node2D

@export var health := 8
@export var armor_values : PackedStringArray = []
@export var damage_values : PackedStringArray = []
@export var strength := 0
@export var dexterity := 0

var attack : Attack : get = _get_attack


func _draw()->void:
	draw_circle(Vector2.ZERO, 5.0, Color.BLUE)


func deal_damage(incoming_attack:Attack)->void:
	if incoming_attack.to_hit >= _get_evasion():
		incoming_attack.damage = max(1, incoming_attack.damage - _get_armor())
		health -= incoming_attack.damage
		if health <= 0:
			queue_free()


func _get_attack()->Attack:
	return Attack.new(_roll_die(20) + dexterity, _get_damage())


func _get_damage()->int:
	var damage := _parse_value_array(damage_values)
	damage += min(strength, damage)
	return damage


func _get_armor()->int:
	return _parse_value_array(armor_values)


func _get_evasion()->int:
	return 10 + dexterity


func _parse_value_array(array:PackedStringArray)->int:
	var final_value := 0
	for value in array:
		if value.begins_with("+"):
			final_value += int(value)
		else:
			final_value += _roll_die(int(value))
	return final_value


func _roll_die(size:int)->int:
	return 1 + randi() % size
