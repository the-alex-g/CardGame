extends Node

enum ObjectTypes {NONE, TOWER, UNIT, CAPTAIN}

var object : Node2D : set = _set_object
var selected_object_type : int : get = _get_selected_object_type
var block_selection := false


func _ready()->void:
	object = load("res://soldier/captain/captain.tscn").instantiate()
	object.color = Color.RED


func _set_object(value:Node2D)->void:
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
	else:
		return ObjectTypes.NONE
