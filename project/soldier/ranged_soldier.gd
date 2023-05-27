class_name RangedSoldier
extends Soldier

signal shoot(ammo, from)


func _get_attack()->Attack:
	_shoot()
	return Attack.new(_roll_die(20) + dexterity, _get_damage())


func _shoot()->Ammo:
	var ammo := preload("res://ammo/ammo.tscn").instantiate()
	emit_signal("shoot", ammo, global_position)
	return ammo
