class_name Unit
extends CharacterBody2D

signal died
signal ranged_attack_ended(hit)

const FLEE_DISTANCE := 100

@export_category("Unit")
@export var unit_size := 7
@export var team_index := 0
@export var speed := 150.0
@export var attack_delay_time := 1.0
@export var color := Color.BLUE
@export var hit_radius := 45.0

@export_category("Unit Type")
@export_enum("Melee", "Ranged") var unit_type := "Melee"

var _target : Unit : set = _set_target
var _can_hit_target := false : set = _set_can_hit_target
var is_dead := false : set = _set_is_dead

@onready var _soldier_container : Node2D = $Soldiers
@onready var _attack_delay_timer : Timer = $AttackDelayTimer
@onready var _hit_area : Area2D = $HitArea


func _ready()->void:
	var collision_shape := CircleShape2D.new()
	collision_shape.radius = hit_radius
	$HitArea/CollisionShape2D.shape = collision_shape
	_populate_unit()


func _process(delta:float)->void:
	if is_dead:
		return
	
	if _target == null:
		return
	else:
		if not _can_hit_target: # you need to get closer
			# so, move the unit
			_move_towards_target(delta)
		else:
			if unit_type == "Ranged" and global_position.distance_squared_to(_target.global_position) < pow(FLEE_DISTANCE, 2):
				_move_away_from_target(delta)


func _populate_unit()->void:
	# add all the soldiers in the proper formation.
	_instance_soldier(Vector2.ZERO)
	for i in unit_size - 1:
		_instance_soldier(Vector2.RIGHT.rotated( TAU * i / (unit_size - 1) ) * 15.0)


func _instance_soldier(soldier_position:Vector2)->void:
	# add a soldier
	var soldier := Soldier.new() if unit_type == "Melee" else RangedSoldier.new()
	if unit_type == "Ranged":
		soldier.shoot.connect(Callable(self, "_on_soldier_shoot"))
	soldier.position = soldier_position
	soldier.color = color
	_soldier_container.add_child(soldier)


func _move_towards_target(delta:float)->void:
	var direction := get_angle_to(_target.global_position)
	_soldier_container.rotation = direction + PI/2
	move_and_collide(Vector2.RIGHT.rotated(direction) * speed * delta)


func _move_away_from_target(delta:float)->void:
	var direction := get_angle_to(_target.global_position)
	_soldier_container.rotation = direction + PI/2
	move_and_collide(Vector2.RIGHT.rotated(direction + PI) * speed * delta / 2)


func _attack()->void:
	# compile an array of soldier attacks and send it to the target
	if is_instance_valid(_target):
		var attack_array := []
		for soldier in _get_soldiers():
			if is_instance_valid(soldier):
				attack_array.append(soldier.attack)
		match unit_type:
			"Melee":
				_target.damage(attack_array)
			"Ranged":
				var attack_hit : bool = await ranged_attack_ended
				if attack_hit:
					_target.damage(attack_array)


func _get_soldier()->Soldier:
	return _get_soldiers().pick_random()


func _get_soldiers()->Array:
	return _soldier_container.get_children()


func _set_is_dead(value:bool)->void:
	if value:
		_attack_delay_timer.stop()
	is_dead = value


func _set_can_hit_target(value:bool)->void:
	_can_hit_target = value
	if _can_hit_target:
		_attack_delay_timer.start(attack_delay_time)
	else:
		_attack_delay_timer.stop()


func _on_detection_area_body_entered(body:PhysicsBody2D)->void:
	# if the new guy is closer to you than your current target,
	# make the new guy your target
	if is_dead:
		return
	
	if body is Unit:
		if body.team_index != team_index:
			if _is_closer_than_target(body.global_position):
				_set_target(body)


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
	if is_dead:
		return
	
	if body == _target:
		_set_can_hit_target(true)


func _on_hit_area_body_exited(body:PhysicsBody2D)->void:
	# you can't hit your target anymore
	if is_dead:
		return
	
	if body == _target:
		_set_can_hit_target(false)


func _on_attack_delay_timer_timeout()->void:
	_attack()


func _on_soldier_shoot(ammo:Ammo, from:Vector2)->void:
	ammo.global_position = from
	ammo.direction = get_angle_to(_target.global_position)
	ammo.bodies_to_ignore.append(self)
	get_parent().add_child(ammo)
	var hit : bool = await ammo.ended
	emit_signal("ranged_attack_ended", hit)


func _on_target_died()->void:
	_find_new_target()


func _find_new_target()->void:
	# find the closest enemy unit and make it your target.
	var closest_unit : Unit
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Unit:
			if body.team_index != team_index and not body.is_dead:
				if (closest_unit == null) or (global_position.distance_squared_to(body.global_position) < global_position.distance_squared_to(closest_unit.global_position)):
					closest_unit = body
	_set_target(closest_unit)


func _check_hit_area_for_target()->void:
	# can you hit the target? Used to process new targets.
	if _hit_area.get_overlapping_bodies().has(_target):
		_set_can_hit_target(true)
	else:
		_set_can_hit_target(false)


func _set_target(value:Unit)->void:
	# change target.
	if is_instance_valid(_target) and _target.died.is_connected(Callable(self, "_on_target_died")):
		_target.died.disconnect(Callable(self, "_on_target_died"))
	if value != null:
		value.died.connect(Callable(self, "_on_target_died"))
	_target = value
	_check_hit_area_for_target()


func damage(attack_array:Array)->void:
	# given an array of attacks, assign them to soldiers and check for death
	if is_dead:
		return
	
	for attack in attack_array:
		_get_soldier().deal_damage(attack)
		if _get_soldier_count() == 0:
			_die()
			break


func _get_soldier_count()->int:
	# returns the number of not-dead soldiers
	# doing a simple get_child_count (probably) won't work because
	# it (probably) doesn't account for the queued_for_deletion soldiers.
	# I admit I haven't tried it.
	var soldiers := 0
	for soldier in _get_soldiers():
		if not soldier.is_queued_for_deletion():
			soldiers += 1
	return soldiers


func _die()->void:
	if not is_dead:
		_set_is_dead(true)
		died.emit()
		queue_free()
