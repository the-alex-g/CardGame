extends Node2D

var _player_towers := 0

@onready var _ai : AI = $AI
@onready var _assets : Node2D = $Assets


func _ready()->void:
	_setup_ai_assets()


func _setup_ai_assets()->void:
	for asset in _assets.get_children():
		if asset is Tower and asset.team_index == _ai.team_index:
			_ai.add_tower(asset)
		elif asset is Unit and asset.team_index == _ai.team_index:
			_ai.add_unit(asset)
		elif asset is Tower and asset.team_index != _ai.team_index:
			_ai.add_enemy_tower(asset)
			_add_player_tower(asset)
		elif asset is Unit and asset.team_index != _ai.team_index:
			_ai.add_enemy_unit(asset)


func instance_unit(unit:Unit)->void:
	_assets.add_child(unit)
	if unit.team_index != _ai.team_index:
		_ai.add_enemy_unit(unit)


func instance_tower(tower:Tower)->void:
	_assets.add_child(tower)
	if tower.team_index != _ai.team_index:
		_ai.add_enemy_tower(tower)
	else:
		_add_player_tower(tower)


func _add_player_tower(tower:Tower)->void:
	_player_towers += 1
	tower.died.connect(Callable(self, "_on_player_tower_died"), CONNECT_ONE_SHOT)


func _on_player_tower_died()->void:
	_player_towers -= 1
	if _player_towers == 0:
		print("PLAYER LOSES")
