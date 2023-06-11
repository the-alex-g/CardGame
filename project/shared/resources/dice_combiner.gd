class_name DiceCombiner
extends Resource

var die_sizes := []
var bonus := 0
var value : int : get = _get_value


func _init(dice := [], initial_bonus := 0)->void:
	die_sizes = dice
	bonus = initial_bonus


func _get_value()->int:
	var total := bonus
	for die in die_sizes:
		total += 1 + (randi() % die)
	return total


func add(to_add:DiceCombiner)->void:
	die_sizes.append_array(to_add.die_sizes)
	bonus += to_add.bonus


func subtract(to_subtract:DiceCombiner)->void:
	for die in to_subtract.die_sizes:
		if die_sizes.has(die):
			die_sizes.erase(die)
	bonus -= to_subtract.bonus
