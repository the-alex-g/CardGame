class_name Attack
extends Resource

var to_hit := 0
var damage := 0


func _init(to_hit_value:int, damage_value:int)->void:
	to_hit = to_hit_value
	damage = damage_value
