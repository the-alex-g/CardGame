class_name SoldierContainer
extends Node2D

signal dead
signal ranged_attack_ended(hit)

var unit_size : int
var unit_type : String
var color : Color
var attacks : Array : get = _get_attacks
var _captain : Captain

@onready var _soldiers : Node2D = $Soldiers


func _ready()->void:
	assert(get_parent() is Unit, "There is a SoldierContainer who's parent is not a Unit")


func damage(attack_array:Array)->void:
	for attack in attack_array:
		if _get_soldier_count() == 0 and _captain != null:
			_captain.deal_damage(attack)
		elif _get_soldier_count() > 0:
			_get_soldier().deal_damage(attack)
		if _get_soldier_count() == 0 and _captain == null:
			dead.emit()
			break


func populate_unit()->void:
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
	_soldiers.add_child(soldier)


func _get_attacks()->Array:
	var attack_array := []
	for soldier in _get_soldiers():
		if is_instance_valid(soldier):
			attack_array.append(soldier.attack)
	return attack_array


func _on_soldier_shoot(ammo:Ammo, from:Vector2)->void:
	_instance_ammunition(ammo, from)
	var hit : bool = await ammo.ended
	ranged_attack_ended.emit(hit)


func _instance_ammunition(ammo:Ammo, from:Vector2)->void:
	ammo.global_position = from
	ammo.direction = get_parent().angle_to_target
	ammo.bodies_to_ignore.append(get_parent())
	get_tree().current_scene.add_child(ammo)


func _get_soldier()->Soldier:
	return _get_soldiers().pick_random()


func _get_soldiers()->Array:
	var soldiers := []
	for soldier in _soldiers.get_children():
		if soldier.visible:
			soldiers.append(soldier)
	return soldiers


func _get_soldier_count()->int:
	# returns the number of not-dead soldiers
	return _get_soldiers().size()


func add_captain(captain:Captain)->void:
	_instance_captain(captain)
	_apply_captain_bonus(captain.unit_bonus)


func _instance_captain(captain:Captain)->void:
	_soldiers.get_children()[0].hide()
	captain.root_unit = get_parent()
	if _captain != null:
		_captain.queue_free()
	_captain = captain
	add_child(_captain)


func _apply_captain_bonus(unit_bonus:Stats)->void:
	for soldier in _get_soldiers():
		soldier.captain_bonus = unit_bonus
