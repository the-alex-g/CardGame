class_name TargetingArea
extends Area2D

signal aquired_new_target(new_target)
signal updated_target_in_range(is_target_in_range)

var detection_range := 0.0 : set = _set_detection_range
var hit_range := 0.0 : set = _set_hit_range
var team_index := 0
var _target : Unit
var _is_target_in_range := false : set = _set_is_target_in_range

@onready var _targeting_area_collision : CollisionShape2D = $CollisionShape2D
@onready var _hit_area : Area2D = $HitArea
@onready var _hit_area_collision : CollisionShape2D = $HitArea/CollisionShape2D


func _is_closer_than_target(point:Vector2)->bool:
	# check if the given point is closer to you than the current target
	if _target == null:
		return true
	else:
		if global_position.distance_squared_to(point) < global_position.distance_squared_to(_target.global_position):
			return true
		else:
			return false


func _on_hit_area_body_entered(body:PhysicsBody2D)->void:
	# you can hit your target now
	if body == _target:
		_set_is_target_in_range(true)


func _on_hit_area_body_exited(body:PhysicsBody2D)->void:
	# you can't hit your target anymore
	if body == _target:
		_set_is_target_in_range(false)


func _on_target_died()->void:
	_find_new_target()


func _find_new_target()->void:
	# find the closest enemy unit and make it your target.
	var closest_unit : Unit
	for body in get_overlapping_bodies():
		if body is Unit:
			if body.team_index != team_index and not body.is_dead:
				if (closest_unit == null) or (global_position.distance_squared_to(body.global_position) < global_position.distance_squared_to(closest_unit.global_position)):
					closest_unit = body
	_set_target(closest_unit)


func _check_hit_area_for_target()->void:
	# can you hit the target? Used to process new targets.
	if _hit_area.get_overlapping_bodies().has(_target):
		_set_is_target_in_range(true)
	else:
		_set_is_target_in_range(false)


func _set_target(value:Unit)->void:
	# change target.
	_manage_target_died_signals(value)
	_target = value
	_check_hit_area_for_target()
	emit_signal("aquired_new_target", _target)


func _manage_target_died_signals(new_target:Unit)->void:
	if is_instance_valid(_target) and _target.died.is_connected(Callable(self, "_on_target_died")):
		_target.died.disconnect(Callable(self, "_on_target_died"))
	if new_target != null:
		new_target.died.connect(Callable(self, "_on_target_died"))


func _set_is_target_in_range(value:bool)->void:
	_is_target_in_range = value
	emit_signal("updated_target_in_range", _is_target_in_range)


func _on_body_entered(body:PhysicsBody2D)->void:
	# if the new guy is closer to you than your current target,
	# make the new guy your target
	if body is Unit:
		if body.team_index != team_index:
			if _is_closer_than_target(body.global_position):
				_set_target(body)


func _set_detection_range(value:float)->void:
	_targeting_area_collision.shape = _get_circle_shape(value)


func _set_hit_range(value:float)->void:
	_hit_area_collision.shape = _get_circle_shape(value)


func _get_circle_shape(radius:float)->CircleShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	return shape
