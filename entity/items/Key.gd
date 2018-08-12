extends "res://entity/Entity.gd"

var picked = false

func _ready():
	$AnimationPlayer.play("idle")
	walkable = true

func interact_with_player(player):
	if picked:
		return
	player.pick_key()
	$AnimationPlayer.play("picked_up")
	yield($AnimationPlayer, "animation_finished")
	queue_free()