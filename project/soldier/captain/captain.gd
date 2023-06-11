class_name Captain
extends Soldier

signal ranged_attack_resolved(hit)

@export var attack_cooldown_time := 1.0
@export var hit_range := 45.0
@export var unit_bonus := Stats.new(0, 2)

var _target : Unit
var root_unit : Unit

@onready var _attack_cooldown_timer : Timer = $AttackCooldownTimer
@onready var _hit_area : HitArea = $HitArea


func _ready():
	_hit_area.hit_range = hit_range


func _on_unit_targeting_update_target(new_target:Unit)->void:
	_target = new_target
	_hit_area.target = _target


func _on_hit_area_updated_target_in_range(is_target_in_range:bool)->void:
	if is_target_in_range:
		_attack_cooldown_timer.start(attack_cooldown_time)
	else:
		_attack_cooldown_timer.stop()


func _on_attack_cooldown_timer_timeout()->void:
	var attack_array := [_get_attack()]
	match soldier_type:
		"Melee":
			_target.damage(attack_array)
		"Ranged":
			var attack_hit : bool = await ranged_attack_resolved
			if attack_hit:
				_target.damage(attack_array)


func _on_shoot(ammo:Ammo, from:Vector2)->void:
	_add_ammo(ammo, from)
	
	var attack_hit : bool = await ammo.ended
	emit_signal("ranged_attack_resolved", attack_hit)


func _add_ammo(ammo:Ammo, from:Vector2)->void:
	ammo.global_position = from
	ammo.direction = get_angle_to(_target.global_position)
	ammo.bodies_to_ignore.append(root_unit)
	get_tree().current_scene.add_child(ammo)


func _on_hidden()->void:
	queue_free()
