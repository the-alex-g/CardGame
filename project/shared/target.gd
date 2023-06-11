class_name Target
extends CharacterBody2D

@export var team_index := 0

var is_dead := false : set = _set_is_dead


func damage(attack_array:Array)->void:
	pass


func _set_is_dead(value:bool)->void:
	is_dead = value
