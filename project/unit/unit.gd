class_name Unit
extends CharacterBody2D

signal dead

@export var unit_size := 7
@export var team_index := 0
@export var speed := 150.0
@export var attack_delay_time := 0.1

var _target : Unit : set = _set_target
var _can_hit_target := false

@onready var _soldier_container : Node2D = $Soldiers
@onready var _attack_delay_timer : Timer = $AttackDelayTimer


func _ready()->void:
	_populate_unit()


func _process(delta:float)->void:
	if _get_soldiers().size() == 0:
		dead.emit()
		queue_free()
	
	if _target == null:
		return
	else:
		if _can_hit_target:
			pass
		else:
			var direction := get_angle_to(_target.global_position)
			_soldier_container.rotation = direction + PI/2
			move_and_collide(Vector2.RIGHT.rotated(direction) * speed * delta)


func _populate_unit()->void:
	_instance_soldier(Vector2.ZERO)
	for i in unit_size - 1:
		_instance_soldier(Vector2.RIGHT.rotated( TAU * i / (unit_size - 1) ) * 15.0)


func _instance_soldier(soldier_position:Vector2)->void:
	var soldier : Soldier = load("res://soldier/soldier.tscn").instantiate()
	soldier.position = soldier_position
	_soldier_container.add_child(soldier)


func _attack()->void:
	for soldier in _get_soldiers():
		_target.damage(soldier.attack)


func _get_soldier()->Soldier:
	return _get_soldiers().pick_random()


func _get_soldiers()->Array:
	return _soldier_container.get_children()


func _on_detection_area_body_entered(body:PhysicsBody2D)->void:
	if body is Unit:
		if body.team_index != team_index:
			if _is_closer_than_target(body.global_position):
				_set_target(body)


func _is_closer_than_target(point:Vector2)->bool:
	if _target == null:
		return true
	else:
		if global_position.distance_squared_to(point) < global_position.distance_squared_to(_target.global_position):
			return true
		else:
			return false


func _on_hit_area_body_entered(body:PhysicsBody2D)->void:
	if body == _target:
		_can_hit_target = true
		_attack_delay_timer.start(attack_delay_time)


func _on_hit_area_body_exited(body:PhysicsBody2D)->void:
	if body == _target:
		_can_hit_target = false
		_attack_delay_timer.stop()


func _on_attack_delay_timer_timeout()->void:
	_attack()


func _on_target_dead()->void:
	_set_target(null)
	var closest_unit : Unit
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Unit:
			if (closest_unit == null) or (global_position.distance_squared_to(body.global_position) < global_position.distance_squared_to(closest_unit.global_position)):
				closest_unit = body
	_set_target(closest_unit)


func _set_target(value:Unit)->void:
	if _target != null:
		_target.dead.disconnect(Callable(self, "_on_target_dead"))
	if value != null:
		value.dead.connect(Callable(self, "_on_target_dead"), CONNECT_ONE_SHOT)
	_target = value


func damage(attack:Attack)->void:
	_get_soldier().deal_damage(attack)
