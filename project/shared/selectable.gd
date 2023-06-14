class_name Selectable
extends Area2D

signal clicked

@export var radius := 20.0 : set = _set_radius

var _selected := false


func _ready()->void:
	_set_radius(radius)


func _input(event:InputEvent)->void:
	if not _selected:
		return
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()


func _set_radius(value:float)->void:
	radius = value
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape


func _on_mouse_entered()->void:
	if not SelectionManager.block_selection:
		_selected = true


func _on_mouse_exited():
	if not SelectionManager.block_selection:
		_selected = false
