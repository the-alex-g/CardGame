class_name HUD
extends CanvasLayer

signal update_money(new_amount)

var _current_hand := []
var _money := 100 : set = _set_money

@onready var _hand_manager : HandManager = $HandManager
@onready var _deck : Deck = $Deck
@onready var _money_label : Label = $Money


func _ready()->void:
	_deck.draw_to_hand_size()
	_set_money(100)


func _on_deck_update_hand(new_hand:Array)->void:
	_hand_manager.clear()
	for card_name in new_hand:
		_hand_manager.add_new_card(card_name)
	_current_hand = new_hand


func _on_hand_manager_card_played(card_name:String)->void:
	_deck.play_card(card_name)
	_set_money(_money - Scriptorium.cards[card_name].cost)


func _on_money_gain_timer_timeout()->void:
	_set_money(_money + 1)


func _set_money(value:int)->void:
	_money = value
	_money_label.text = str(_money)
	update_money.emit(_money)
