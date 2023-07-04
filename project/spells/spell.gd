class_name Spell
extends Node

enum Type {HEAL, DAMAGE, RESURRECT}

@export var target_towers := false
@export var target_units := false
@export var captain_spell := false
@export var type : Type = Type.RESURRECT
# a heal spell needs a "targets" field and a "amount" field
# a damage spell needs a "targets" field and a "damage" field
# a resurrect spell needs a "targets" field and a "percent_health" field
@export var info := {"targets":7}
@export var benifical := false

var copy : Spell : get = _get_copy

@onready var _parent : Target = null if captain_spell else get_parent()


func _init(is_spell_benifical:bool, spell_target_towers:bool, spell_target_units:bool, spell_type:Type, spell_info:Dictionary, spell_captain_spell := false)->void:
	benifical = is_spell_benifical
	target_towers = spell_target_towers
	target_units = spell_target_units
	type = spell_type
	info = spell_info
	captain_spell = spell_captain_spell


func _ready()->void:
	if not captain_spell:
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


func _get_copy()->Spell:
	var self_copy := self.duplicate()
	self_copy.captain_spell = false
	return self_copy
