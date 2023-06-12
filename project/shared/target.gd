class_name Target
extends CharacterBody2D

signal died

@export var team_index := 0

var is_dead := false : set = _set_is_dead
var _focused := false


func _ready()->void:
	input_pickable = true
	mouse_entered.connect(Callable(self, "_on_mouse_entered"))
	mouse_exited.connect(Callable(self, "_on_mouse_exited"))
	TargetTracker.add_target(self)


func _input(event:InputEvent)->void:
	if not _focused:
		return
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			_resolve_click()


func damage(_attack_array:Array)->void:
	pass


func _set_is_dead(value:bool)->void:
	if not is_dead:
		is_dead = true
		died.emit()
		queue_free()
	is_dead = value


func _resolve_click()->void:
	pass


func _on_mouse_entered()->void:
	if not SelectionManager.block_selection:
		_focused = true


func _on_mouse_exited():
	_focused = false
