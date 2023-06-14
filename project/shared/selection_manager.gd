extends Node

enum ObjectTypes {NONE, TOWER, UNIT, CAPTAIN, SPELL}

var object : Node : set = _set_object
var card_selected : Card
var selected_object_type : int : get = _get_selected_object_type
var block_selection := false


func _set_object(value:Node)->void:
	if value != null and value != object:
		value.ready.connect(Callable(self, "_on_object_tree_entered"), CONNECT_ONE_SHOT)
	object = value


func _on_object_tree_entered()->void:
	object = null
	card_selected.object_placed()
	card_selected = null


func _get_selected_object_type()->int:
	if object is Tower:
		return ObjectTypes.TOWER
	elif object is Unit:
		return ObjectTypes.UNIT
	elif object is Captain:
		return ObjectTypes.CAPTAIN
	elif object is Spell:
		return ObjectTypes.SPELL
	else:
		return ObjectTypes.NONE
