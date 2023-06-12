class_name Tower
extends Target

signal left_mouse_button_pressed

@export var health := 30
@export var tower_spawn_radius := 300
@export var tower_radius := 30

var _waiting_for_tower_spawn := false : set = _set_waiting_for_tower_spawn
var _tower_spawn_circle : PackedVector2Array


func _ready()->void:
	for i in 33:
		_tower_spawn_circle.append(Vector2.RIGHT.rotated(TAU * i / 32) * tower_spawn_radius)
	super._ready()


func _input(event:InputEvent)->void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("left_mouse_button_pressed")
	super._input(event)


func damage(attack_array:Array)->void:
	for attack in attack_array:
		health -= attack.damage
	if health <= 0:
		_set_is_dead(true)


func _draw()->void:
	if _waiting_for_tower_spawn:
		draw_polyline(_tower_spawn_circle, Color.RED, 1.0)
	draw_circle(Vector2.ZERO, tower_radius, Color.BLANCHED_ALMOND)


func _resolve_click()->void:
	if not _waiting_for_tower_spawn:
		match SelectionManager.selected_object_type:
			SelectionManager.ObjectTypes.TOWER:
				_locate_tower()
			SelectionManager.ObjectTypes.UNIT:
				_spawn_unit()


func _locate_tower()->void:
	_set_waiting_for_tower_spawn(true)
	while _waiting_for_tower_spawn:
		await left_mouse_button_pressed
		_spawn_tower()


func _spawn_tower()->void:
	var mouse_position := get_global_mouse_position()
	if global_position.distance_squared_to(mouse_position) <= pow(tower_spawn_radius, 2):
		var tower_to_spawn := SelectionManager.object
		tower_to_spawn.global_position = mouse_position
		get_parent().add_child(tower_to_spawn)
		_set_waiting_for_tower_spawn(false)


func _spawn_unit()->void:
	var unit_to_spawn := SelectionManager.object
	unit_to_spawn.global_position = global_position + Vector2.RIGHT.rotated(TAU * randf()) * (tower_radius + 30)
	get_parent().add_child(unit_to_spawn)


func _set_waiting_for_tower_spawn(value:bool)->void:
	_waiting_for_tower_spawn = value
	SelectionManager.block_selection = value
	queue_redraw()
