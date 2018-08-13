extends "res://entity/Entity.gd"

var opened = false

func interact_with_player(player):
	if opened:
		return
	opened = true
	player.heal(randi() % 2 + 1)
	$AnimationPlayer.play("disapear")
	yield($AnimationPlayer, "animation_finished")
	queue_free()