class_name HitArea
extends Area2D

signal updated_target_in_range(is_target_in_range)

var target : Unit : set = _set_target
var hit_range := 0.0 : set = _set_hit_range

@onready var _collision_shape : CollisionShape2D = $CollisionShape2D


func _on_body_entered(body:PhysicsBody2D)->void:
	# you can hit your target now
	if body == target:
		_set_is_target_in_range(true)


func _on_body_exited(body:PhysicsBody2D)->void:
	# you can't hit your target anymore
	if body == target:
		_set_is_target_in_range(false)


func _check_hit_area_for_target()->void:
	# can you hit the target? Used to process new targets.
	if get_overlapping_bodies().has(target):
		_set_is_target_in_range(true)
	else:
		_set_is_target_in_range(false)


func _set_is_target_in_range(value:bool)->void:
	emit_signal("updated_target_in_range", value)


func _set_hit_range(value:float)->void:
	_collision_shape.shape = _get_circle_shape(value)


func _get_circle_shape(radius:float)->CircleShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	return shape


func _set_target(value:Unit)->void:
	target = value
	_check_hit_area_for_target()


func _on_targeting_area_aquired_new_target(new_target:Unit)->void:
	_set_target(new_target)
