class_name Unit
extends Target

signal ranged_attack_ended(hit)

const FLEE_DISTANCE := 100

@export_category("Unit")
@export var unit_size := 7
@export var speed := 150.0
@export var attack_delay_time := 1.0
@export var color := Color.BLUE
@export var detection_radius := 1024.0
@export var hit_radius := 45.0

@export_category("Unit Type")
@export_enum("Melee", "Ranged") var unit_type := "Melee"

var _target : Target
var _captain : Captain
var _is_target_in_range := false : set = _set_is_target_in_range

@onready var _soldier_container : Node2D = $Soldiers
@onready var _attack_delay_timer : Timer = $AttackDelayTimer
@onready var _targeting_area : TargetingArea = $TargetingArea


func _ready()->void:
	_update_targeting_area()
	_populate_unit()
	_add_captain(load("res://soldier/captain/captain.tscn").instantiate())


func _process(delta:float)->void:
	if is_dead:
		return
	
	if _target == null:
		return
	else:
		if not _is_target_in_range: # you need to get closer
			# so, move the unit
			_move_towards_target(delta)
		else:
			if unit_type == "Ranged" and global_position.distance_squared_to(_target.global_position) < pow(FLEE_DISTANCE, 2):
				pass
				#_move_away_from_target(delta)


func _update_targeting_area()->void:
	_targeting_area.hit_range = hit_radius
	_targeting_area.detection_range = detection_radius
	_targeting_area.team_index = team_index


func _populate_unit()->void:
	# add all the soldiers in the proper formation.
	_instance_soldier(Vector2.ZERO)
	for i in unit_size - 1:
		_instance_soldier(Vector2.RIGHT.rotated(TAU * i / (unit_size - 1) ) * 15.0)


func _instance_soldier(soldier_position:Vector2)->void:
	# add a soldier
	var soldier := Soldier.new()
	if unit_type == "Ranged":
		soldier.shoot.connect(Callable(self, "_on_soldier_shoot"))
	soldier.soldier_type = unit_type
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
	var soldiers := []
	for soldier in _soldier_container.get_children():
		if soldier.visible:
			soldiers.append(soldier)
	return soldiers


func _set_is_dead(value:bool)->void:
	if value:
		_attack_delay_timer.stop()
	super._set_is_dead(value)


func _set_is_target_in_range(value:bool)->void:
	_is_target_in_range = value
	if _is_target_in_range:
		_attack_delay_timer.start(attack_delay_time)
	else:
		_attack_delay_timer.stop()


func _on_attack_delay_timer_timeout()->void:
	_attack()


func _on_soldier_shoot(ammo:Ammo, from:Vector2)->void:
	_instance_ammunition(ammo, from)
	var hit : bool = await ammo.ended
	emit_signal("ranged_attack_ended", hit)


func _instance_ammunition(ammo:Ammo, from:Vector2)->void:
	ammo.global_position = from
	ammo.direction = get_angle_to(_target.global_position)
	ammo.bodies_to_ignore.append(self)
	get_tree().current_scene.add_child(ammo)


func damage(attack_array:Array)->void:
	# given an array of attacks, assign them to soldiers and check for death
	if is_dead:
		return
	
	for attack in attack_array:
		if _get_soldier_count() == 0 and _captain != null:
			_captain.deal_damage(attack)
		elif _get_soldier_count() > 0:
			_get_soldier().deal_damage(attack)
		if _get_soldier_count() == 0 and _captain == null:
			_set_is_dead(true)
			break


func _get_soldier_count()->int:
	# returns the number of not-dead soldiers
	return _get_soldiers().size()


func _on_targeting_area_aquired_new_target(new_target:Target)->void:
	if is_dead:
		return
	
	_target = new_target


func _on_targeting_area_updated_target_in_range(is_target_in_range:bool)->void:
	if is_dead:
		return
	
	_set_is_target_in_range(is_target_in_range)


func _add_captain(captain:Captain)->void:
	_instance_captain(captain)
	_apply_captain_bonus(captain.unit_bonus)
	_targeting_area.aquired_new_target.connect(Callable(captain, "_on_unit_targeting_update_target"))


func _instance_captain(captain:Captain)->void:
	_get_soldiers()[0].hide()
	captain.root_unit = self
	_captain = captain
	add_child(captain)


func _apply_captain_bonus(unit_bonus:Stats)->void:
	for soldier in _get_soldiers():
		soldier.captain_bonus = unit_bonus
