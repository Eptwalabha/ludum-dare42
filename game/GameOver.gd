extends Node

func _ready():
	$AnimationPlayer.play_backwards("fadeout")
	yield($AnimationPlayer, "animation_finished")
	find_node("Play").connect("pressed", self, "_on_Play_pressed", [], CONNECT_ONESHOT)

func _on_Play_pressed():
	$AnimationPlayer.play("fadeout")
	yield($AnimationPlayer, "animation_finished")
	game.reset()
	get_tree().change_scene("res://level/Level.tscn")
