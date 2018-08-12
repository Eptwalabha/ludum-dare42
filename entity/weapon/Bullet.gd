extends "res://entity/Entity.gd"

var owner_entity = null
var damage = 1
var velocity = Vector2(1, 0)
var ttl = 5

func _ready():
	projectile = true
	$Pivot/Area2D.connect("body_entered", self, "_on_Area2D_body_entered")

func tick():
	if ttl == 0:
		queue_free()
		return
	$Pivot.position = - velocity
	position += velocity
	$Tween.interpolate_property(
			$Pivot, "position",
			$Pivot.position, Vector2(),
			0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	ttl -= 1

func set_owner(entity):
	owner_entity = entity

func _on_Area2D_body_entered(body):
	queue_free()
