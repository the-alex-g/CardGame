class_name Unit
extends Target

const FLEE_DISTANCE := 100

@export_category("Unit")
@export var unit_size := 7
@export var speed := 50.0
@export var attack_delay_time := 1.0
@export var color := Color.BLUE
@export var hit_radius := 30.0

@export_category("Unit Type")
@export_enum("Melee", "Ranged") var unit_type := "Melee"

var angle_to_target : float : get = _get_angle_to_target
var _target : Target
var _is_target_in_range := false : set = _set_is_target_in_range

@onready var _soldier_container : SoldierContainer = $SoldierContainer
@onready var _attack_delay_timer : Timer = $AttackDelayTimer
@onready var _targeting_system : TargetingSystem = $TargetingSystem


func _ready()->void:
	_update_targeting_system()
	_update_soldier_container()
	super._ready()


func _process(delta:float)->void:
	if is_dead:
		return
	
	_targeting_system.find_new_target()
	
	if _target == null:
		return
	else:
		if not _is_target_in_range: # you need to get closer
			# so, move the unit
			_move_towards_target(delta)
#		else:
#			if unit_type == "Ranged" and global_position.distance_squared_to(_target.global_position) < pow(FLEE_DISTANCE, 2):
#				_move_away_from_target(delta)


func _update_targeting_system()->void:
	_targeting_system.hit_range = hit_radius
	_targeting_system.team_index = team_index


func _update_soldier_container()->void:
	_soldier_container.unit_size = unit_size
	_soldier_container.unit_type = unit_type
	_soldier_container.color = color
	_soldier_container.populate_unit()


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
		var attack_array : Array = _soldier_container.attacks
		match unit_type:
			"Melee":
				_target.damage(attack_array)
			"Ranged":
				var attack_hit : bool = await _soldier_container.ranged_attack_ended
				if attack_hit:
					_target.damage(attack_array)


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


func damage(attack_array:Array)->void:
	# given an array of attacks, assign them to soldiers and check for death
	if is_dead:
		return
	
	_soldier_container.damage(attack_array)


func heal(heal_array:Array)->void:
	_soldier_container.heal(heal_array)


func resurrect(number:int, percent_health:float)->void:
	_soldier_container.resurrect(number, percent_health)


func _get_angle_to_target()->float:
	return get_angle_to(_target.global_position)


func _on_targeting_system_aquired_new_target(new_target:Target)->void:
	if is_dead:
		return
	
	_target = new_target


func _on_targeting_system_updated_target_in_range(is_target_in_range:bool)->void:
	if is_dead:
		return
	
	_set_is_target_in_range(is_target_in_range)


func _on_selectable_clicked()->void:
	match SelectionManager.selected_object_type:
		SelectionManager.ObjectTypes.CAPTAIN:
			_add_captain(SelectionManager.object)
		SelectionManager.ObjectTypes.SPELL:
			apply_spell(SelectionManager.object)


func _add_captain(captain:Captain)->void:
	_targeting_system.aquired_new_target.connect(Callable(captain, "_on_unit_targeting_update_target"))
	captain.set_deferred("target", _target)
	_soldier_container.add_captain(captain)


func _on_soldier_container_dead()->void:
	_set_is_dead(true)


func apply_spell(spell:Spell)->void:
	if spell.target_units:
		add_child(spell)
	else:
		print("invalid target")
