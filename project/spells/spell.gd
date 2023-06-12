class_name Spell
extends Node

enum TargetTypes {UNIT, TOWER}
enum Type {HEAL, DAMAGE, RESURRECT}

@export var target_type : TargetTypes = TargetTypes.UNIT
@export var type : Type = Type.RESURRECT
# a heal spell needs a "targets" field and a "amount" field
# a damage spell needs a "targets" field and a "damage" field
# a resurrect spell needs a "targets" field and a "percent_health" field
@export var info := {"targets":7, "percent_health":1.0}

@onready var _parent : Target = get_parent()


func _ready()->void:
	match type:
		Type.HEAL:
			_resolve_healing()
		Type.DAMAGE:
			_resolve_damage()
		Type.RESURRECT:
			_resolve_resurrection()
	queue_free()


func _resolve_healing()->void:
	var heal_array := []
	for _i in info.targets:
		heal_array.append(info.amount)
	_parent.heal(heal_array)


func _resolve_damage()->void:
	var attack_array := []
	for _i in info.targets:
		attack_array.append(Attack.new(21, info.damage))
	_parent.damage(attack_array)


func _resolve_resurrection()->void:
	if _parent is Unit:
		_parent.resurrect(info.targets, info.percent_health)
