class_name Deck
extends Node

signal update_hand(new_hand)

@export var hand_size := 4

var _deck := [
	"captain",
	"captain",
	"legion",
	"legion",
	"legion",
	"tower",
	"fireball",
	"fireball",
]
var _hand := []
var _discard := []


func _ready()->void:
	_deck.shuffle()


func draw_to_hand_size()->void:
	for i in hand_size - _hand.size():
		draw_card()
	update_hand.emit(_hand)


func get_hand()->Array:
	return _hand


func play_card(card:String)->void:
	_hand.erase(card)
	_discard.append(card)
	draw_card()
	update_hand.emit(_hand)


func draw_card()->void:
	if _deck.size() == 0:
		_shuffle_deck()
	_hand.append(_deck[0])
	_deck.remove_at(0)


func _shuffle_deck()->void:
	_deck = _discard.duplicate(true)
	_discard.clear()
	_deck.shuffle()
