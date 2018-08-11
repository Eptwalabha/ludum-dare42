extends "res://entity/Entity.gd"

var opened = false

func _ready():
	pass

func interact_with_player(player):
	if opened:
		return
	opened = true
	player.heal(10)
	$AnimationPlayer.play("disapear")
	yield($AnimationPlayer, "animation_finished")
	queue_free()