class_name HandManager
extends HBoxContainer

signal card_played(card_name)

var _money := 0


func add_new_card(card_name:String)->void:
	var card_instance : Card = load("res://cards/card.tscn").instantiate()
	card_instance.played.connect(Callable(self, "_on_card_played").bind(card_name), CONNECT_ONE_SHOT)
	card_instance.clicked.connect(Callable(self, "_on_card_clicked"))
	add_child(card_instance)
	card_instance.set_deferred("card_info", Scriptorium.get_card(card_name))


func clear()->void:
	for card in get_children():
		card.queue_free()


func _on_card_played(card_name:String)->void:
	card_played.emit(card_name)


func _on_card_clicked(card:Card)->void:
	if card.cost <= _money:
		card.select()


func _on_hud_update_money(new_amount:int)->void:
	_money = new_amount
