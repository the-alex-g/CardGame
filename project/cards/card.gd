class_name Card
extends Control

var card_info : Dictionary
var _focused := false

@onready var _title : Label = $VBoxContainer/Title
@onready var _text : Label = $VBoxContainer/Text


func _ready()->void:
	card_info = Scriptorium.card
	_update_card_text()


func _input(event:InputEvent)->void:
	if not _focused:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			_clicked()


func _update_card_text()->void:
	_title.text = card_info.name
	_text.text = card_info.text


func _clicked()->void:
	SelectionManager.object = card_info.object
	SelectionManager.card_selected = self


func object_placed()->void:
	queue_free()


func _on_mouse_entered()->void:
	if not SelectionManager.block_selection:
		_focused = true


func _on_mouse_exited():
	if not SelectionManager.block_selection:
		_focused = false
