class_name AI
extends Node

@export var team_index := 1

var _money := 100
var _next_card_to_play : Dictionary
var _units := []
var _towers := []
var _enemy_units := []
var _enemy_towers := []

@onready var _deck : Deck = $Deck


func _ready()->void:
	_deck.draw_to_hand_size()
	_select_card_to_play()


func add_unit(unit:Unit)->void:
	_units.append(unit)
	unit.died.connect(Callable(self, "_on_unit_died").bind(unit), CONNECT_ONE_SHOT)


func add_tower(tower:Tower)->void:
	_towers.append(tower)
	tower.died.connect(Callable(self, "_on_tower_died").bind(tower), CONNECT_ONE_SHOT)


func add_enemy_unit(unit:Unit)->void:
	_enemy_units.append(unit)
	unit.died.connect(Callable(self, "_on_enemy_unit_died").bind(unit), CONNECT_ONE_SHOT)


func add_enemy_tower(tower:Tower)->void:
	_enemy_towers.append(tower)
	tower.died.connect(Callable(self, "_on_enemy_tower_died").bind(tower), CONNECT_ONE_SHOT)


func _select_card_to_play()->void:
	_next_card_to_play = Scriptorium.get_card(_deck.get_hand().pick_random())
	print("going to play ", _next_card_to_play.name)


func _on_money_gain_timer_timeout()->void:
	_money += 1
	if _money >= _next_card_to_play.cost:
		_play_card(_next_card_to_play)


func _play_card(card:Dictionary)->void:
	var card_successfully_played := false
	match card.type:
		"spell":
			card_successfully_played = _play_spell(card.object)
		"tower":
			card_successfully_played = _play_tower(card.object)
		"unit":
			card_successfully_played = _play_unit(card.object)
		"captain":
			card_successfully_played = _play_captain(card.object)
	if card_successfully_played:
		_money -= _next_card_to_play.cost
		_deck.play_card(card.name)
	_select_card_to_play()


func _play_spell(spell:Spell)->bool:
	if spell.benifical:
		if spell.target_towers and spell.target_units and not _enemy_towers.is_empty() and not _enemy_units.is_empty():
			match randi() % 2:
				0:
					_enemy_towers.pick_random().apply_spell(spell)
				1:
					_enemy_units.pick_random().apply_spell(spell)
			return true
		elif spell.target_towers and not _enemy_towers.is_empty():
			_enemy_towers.pick_random().apply_spell(spell)
			return true
		elif spell.target_units and not _enemy_units.is_empty():
			_enemy_units.pick_random().apply_spell(spell)
			return true
		return false
	else:
		if spell.target_towers and spell.target_units and not _towers.is_empty() and not _units.is_empty():
			match randi() % 2:
				0:
					_towers.pick_random().apply_spell(spell)
				1:
					_units.pick_random().apply_spell(spell)
			return true
		elif spell.target_towers and not _towers.is_empty():
			_towers.pick_random().apply_spell(spell)
			return true
		elif spell.target_units and not _units.is_empty():
			_units.pick_random().apply_spell(spell)
			return true
		return false


func _play_tower(tower:Tower)->bool:
	var tower_to_spawn_from : Tower = _towers.pick_random()
	var spawn_point := Vector2.ONE * -10000
	while not Geometry2D.is_point_in_polygon(spawn_point, [Vector2(0, 0), Vector2(get_window().size.x, 0), get_window().size, Vector2(0, get_window().size.y)]):
		spawn_point = tower_to_spawn_from.global_position + Vector2.RIGHT.rotated(randf() * TAU) * tower_to_spawn_from.tower_spawn_radius
	tower.global_position = spawn_point
	tower.team_index = team_index
	get_tree().current_scene.instance_tower(tower)
	add_tower(tower)
	return true


func _play_unit(unit:Unit)->bool:
	_towers.pick_random().spawn_unit(unit)
	add_unit(unit)
	return true


func _play_captain(captain:Captain)->bool:
	if _units.size() > 0:
		_units.pick_random().add_captain(captain)
		return true
	else:
		return false


func _on_tower_died(tower:Tower)->void:
	_towers.erase(tower)
	if _towers.size() == 0:
		print("AI LOSES")


func _on_unit_died(unit:Unit)->void:
	_units.erase(unit)


func _on_enemy_tower_died(tower:Tower)->void:
	_enemy_towers.erase(tower)


func _on_enemy_unit_died(unit:Unit)->void:
	_enemy_units.erase(unit)
