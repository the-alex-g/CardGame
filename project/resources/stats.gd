class_name Stats
extends Resource

@export var health := 8
@export var armor := 0
@export var strength := 0
@export var dexterity := 0
@export var evasion_bonus := 0
@export var damage_dice := DiceCombiner.new()

var damage : int : get = _get_damage
var evasion : int : get = _get_evasion


func _init(i_health := 8, i_armor := 0,
		i_strength := 0, i_dexterity := 0,
		i_evasion_bonus := 0, i_damage_dice := DiceCombiner.new()
	)->void:
	health = i_health
	armor = i_armor
	strength = i_strength
	dexterity = i_dexterity
	evasion_bonus = i_evasion_bonus
	damage_dice = i_damage_dice


func add(to_add:Stats, add_sign := 1)->void:
	# setting sign to -1 performs a subtraction instead of an addition
	health += to_add.health * add_sign
	armor += to_add.armor * add_sign
	strength += to_add.strength * add_sign
	dexterity += to_add.dexterity * add_sign
	evasion_bonus += to_add.evasion_bonus * add_sign
	if add_sign == 1:
		damage_dice.add(to_add.damage_dice)
	elif add_sign == -1:
		damage_dice.subtract(to_add.damage_dice)


func subtract(to_subtract:Stats)->void:
	# same as calling "add" with a sign of -1
	add(to_subtract, -1)


func _get_evasion()->int:
	return 10 + dexterity + evasion_bonus


func _get_damage()->int:
	return damage_dice.value
