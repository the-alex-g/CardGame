class_name Ammo
extends Area2D

signal ended(hit)

@export var speed := 400.0

var direction
var bodies_to_ignore := []


func _process(delta:float)->void:
	position += Vector2.RIGHT.rotated(direction) * speed * delta


func _draw()->void:
	draw_circle(Vector2.ZERO, 3, Color.BLACK)


func _on_life_timer_timeout()->void:
	emit_signal("ended", false)
	queue_free()


func _on_body_entered(body:PhysicsBody2D)->void:
	if not bodies_to_ignore.has(body):
		emit_signal("ended", true)
		queue_free()
