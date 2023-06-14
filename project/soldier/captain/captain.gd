class_name Captain
extends Soldier

signal ranged_attack_resolved(hit)

enum Type {ATTACK, BOOST_SPELL, OFFENSE_SPELL}

@export var attack_cooldown_time := 1.0
@export var hit_range := 45.0
@export var unit_bonus := Stats.new(0, 2)
@export var type : Type
@export var spell := Spell.new(false, true, Spell.Type.DAMAGE, {"targets":1, "damage":4}, true)

var target : Target : set = _set_target
var root_unit : Unit

@onready var _attack_cooldown_timer : Timer = $AttackCooldownTimer
@onready var _hit_area : HitArea = $HitArea


func _init()->void:
	# this function is, for some unfathomable reason, necessary
	# in order to instance this scene in the scriptorium.
	pass


func _ready():
	_hit_area.hit_range = hit_range
	if type == Type.BOOST_SPELL:
		_attack_cooldown_timer.start()


func _on_unit_targeting_update_target(new_target:Target)->void:
	_set_target(new_target)


func _on_hit_area_updated_target_in_range(is_target_in_range:bool)->void:
	if type != Type.BOOST_SPELL:
		if is_target_in_range:
			_attack_cooldown_timer.start(attack_cooldown_time)
		else:
			_attack_cooldown_timer.stop()


func _on_attack_cooldown_timer_timeout()->void:
	if type == Type.ATTACK:
		_attack()
	elif type == Type.BOOST_SPELL:
		root_unit.apply_spell(spell.copy)
	elif type == Type.OFFENSE_SPELL:
		target.apply_spell(spell.copy)


func _attack()->void:
	var attack_array := [_get_attack()]
	match soldier_type:
		"Melee":
			target.damage(attack_array)
		"Ranged":
			var attack_hit : bool = await ranged_attack_resolved
			if attack_hit:
				target.damage(attack_array)


func _on_shoot(ammo:Ammo, from:Vector2)->void:
	_add_ammo(ammo, from)
	
	var attack_hit : bool = await ammo.ended
	emit_signal("ranged_attack_resolved", attack_hit)


func _add_ammo(ammo:Ammo, from:Vector2)->void:
	ammo.global_position = from
	ammo.direction = get_angle_to(target.global_position) + get_parent().rotation
	ammo.bodies_to_ignore.append(root_unit)
	get_tree().current_scene.add_child(ammo)


func _on_hidden()->void:
	queue_free()


func _set_target(value:Target)->void:
	target = value
	_hit_area.target = target
