class_name Target
extends CharacterBody2D

signal died

@export var team_index := 0

var is_dead := false : set = _set_is_dead


func damage(attack_array:Array)->void:
	pass


func _set_is_dead(value:bool)->void:
	if not is_dead:
		is_dead = true
		died.emit()
		queue_free()
