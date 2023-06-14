class_name Card
extends Control

signal played
signal clicked(card)

var card_info : Dictionary : set = _set_card_info
var cost : int : get = _get_cost
var _focused := false

@onready var _title : Label = $VBoxContainer/Title
@onready var _text : Label = $VBoxContainer/Text


func _input(event:InputEvent)->void:
	if not _focused:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			_clicked()


func object_placed()->void:
	played.emit()
	queue_free()


func select()->void:
	SelectionManager.object = card_info.object
	SelectionManager.card_selected = self
	$ColorRect.show()


func _set_card_info(value:Dictionary)->void:
	card_info = value
	_update_card_text()


func _get_cost()->int:
	return card_info.cost


func _update_card_text()->void:
	_title.text = card_info.name + " " + str(_get_cost())
	_text.text = card_info.text


func _clicked()->void:
	clicked.emit(self)


func _on_mouse_entered()->void:
	if not SelectionManager.block_selection:
		_focused = true


func _on_mouse_exited():
	if not SelectionManager.block_selection:
		_focused = false
