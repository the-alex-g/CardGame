extends Node

enum ObjectTypes {NONE, TOWER, UNIT, CAPTAIN, SPELL}

var object : Node : set = _set_object
var selected_object_type : int : get = _get_selected_object_type
var block_selection := false


func _ready()->void:
	object = load("res://soldier/captain/captain.tscn").instantiate()


func _set_object(value:Node)->void:
	object = value
	if object != null:
		object.ready.connect(Callable(self, "_on_object_tree_entered"), CONNECT_ONE_SHOT)


func _on_object_tree_entered()->void:
	object = null


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
