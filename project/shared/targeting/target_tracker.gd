extends Node

var targets := []


func add_target(new_target:Target)->void:
	targets.append(new_target)
	new_target.connect("died", Callable(self, "_on_target_died").bind(new_target), CONNECT_ONE_SHOT)


func _on_target_died(target:Target)->void:
	targets.erase(target)
