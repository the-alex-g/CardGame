extends Node

var cards := {
	"fireball":{"type":"spell", "cost":10, "info":{"target_towers":false, "target_units":true, "type":Spell.Type.DAMAGE, "spell_info":{"targets":3, "damage":3}}, "text":"deal 3 damage to 3 soldiers"},
	"tower":{"type":"tower", "cost":150, "info":{"health":30, "spawn_radius":300, "size":30}, "text":"create a tower with 30 health"},
	"legion":{"type":"unit", "cost":100, "info":{"size":7, "unit_type":"Melee", "speed":100.0, "attack_delay":1.0, "hit_radius":30.0, "stats":Stats.new()}, "text":"create a melee unit: size - 7, health - 8, speed - 6, dps - 4"},
	"captain":{"type":"captain", "cost":50, "info":{"stats":Stats.new(), "attack_type":"Melee", "attack_delay":1.0, "hit_range":30.0, "unit_bonus":Stats.new(), "type":Captain.Type.ATTACK, "spell":null}, "text":"create a melee captain: health - 8, dps - 4, unit gets +1 armor"}
}


func get_card(key := "")->Dictionary:
	if key == "":
		key = cards.keys().pick_random()
	var card_data : Dictionary = cards[key]
	var card_info_to_return : Dictionary = {"name":key, "cost":card_data.cost, "text":card_data.text}
	match card_data.type:
		"spell":
			card_info_to_return["object"] = _get_spell_from_info(card_data.info)
		"tower":
			card_info_to_return["object"] = _get_tower_from_info(card_data.info)
		"unit":
			card_info_to_return["object"] = _get_unit_from_info(card_data.info)
		"captain":
			card_info_to_return["object"] = _get_captain_from_info(card_data.info)
	return card_info_to_return


func _get_spell_from_info(info:Dictionary)->Spell:
	return Spell.new(info.target_towers, info.target_units, info.type, info.spell_info)


func _get_tower_from_info(info:Dictionary)->Tower:
	var tower : Tower = load("res://towers/tower.tscn").instantiate()
	tower.health = info.health
	tower.tower_spawn_radius = info.spawn_radius
	tower.tower_radius = info.size
	return tower


func _get_unit_from_info(info:Dictionary)->Unit:
	var unit : Unit = load("res://unit/unit.tscn").instantiate()
	unit.unit_size = info.size
	unit.unit_type = info.unit_type
	unit.speed = info.speed
	unit.attack_delay_time = info.attack_delay
	unit.hit_radius = info.hit_radius
	unit.soldier_stats = info.stats
	return unit


func _get_captain_from_info(info:Dictionary)->Captain:
	var captain : Captain = load("res://soldier/captain/captain.tscn").instantiate()
	captain.stats = info.stats
	captain.soldier_type = info.attack_type
	captain.attack_cooldown_time = info.attack_delay
	captain.hit_range = info.hit_range
	captain.unit_bonus = info.unit_bonus
	captain.type = info.type
	captain.spell = info.spell
	return captain
