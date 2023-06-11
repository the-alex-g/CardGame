class_name TargetingSystem
extends Node2D

signal aquired_new_target(new_target)
signal updated_target_in_range(is_target_in_range)

var hit_range := 0.0 : set = _set_hit_range
var team_index := 0
var _target : Target

@onready var _hit_area : HitArea = $HitArea


func _is_closer_than_target(point:Vector2)->bool:
	# check if the given point is closer to you than the current target
	if _target == null:
		return true
	else:
		return global_position.distance_squared_to(point) < global_position.distance_squared_to(_target.global_position)


func find_new_target()->void:
	# find the closest enemy unit and make it your target.
	var closest_target : Target
	for target in TargetTracker.targets:
			if target.team_index != team_index and not target.is_dead:
				if (closest_target == null) or (global_position.distance_squared_to(target.global_position) < global_position.distance_squared_to(closest_target.global_position)):
					closest_target = target
	if closest_target != _target:
		_set_target(closest_target)


func _set_target(value:Target)->void:
	# change target.
	_target = value
	emit_signal("aquired_new_target", _target)


func _set_hit_range(value:float)->void:
	_hit_area.hit_range = value


func _on_hit_area_updated_target_in_range(is_target_in_range):
	emit_signal("updated_target_in_range", is_target_in_range)
