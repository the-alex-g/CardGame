class_name Soldier
extends Node2D

signal shoot(ammo, from)

@export var stats := Stats.new(8, 0, 0, 0, 0, DiceCombiner.new([8], 0))
@export_enum("Melee", "Ranged") var soldier_type := "Melee"

var attack : Attack : get = _get_attack
var captain_bonus : Stats : set = _set_captain_bonus

@export var color := Color.BLUE


func _draw()->void:
	draw_circle(Vector2.ZERO, 5.0, color)


func deal_damage(incoming_attack:Attack)->void:
	if incoming_attack.to_hit >= stats.evasion:
		incoming_attack.damage = max(1, incoming_attack.damage - stats.armor)
		stats.health -= incoming_attack.damage
		if stats.health <= 0:
			hide()


func _get_attack()->Attack:
	if not visible:
		return Attack.new(0, 0)
	
	if soldier_type == "Ranged":
		_shoot()
	return Attack.new(1 + randi() % 20 + stats.strength, stats.damage)


func _shoot()->Ammo:
	var ammo := preload("res://ammo/ammo.tscn").instantiate()
	emit_signal("shoot", ammo, global_position)
	return ammo


func _set_captain_bonus(value:Stats)->void:
	if not captain_bonus == null:
		stats.subtract(captain_bonus)
	captain_bonus = value
	stats.add(captain_bonus)
