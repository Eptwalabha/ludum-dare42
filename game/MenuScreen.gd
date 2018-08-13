extends Node

func _ready():
	$AnimationPlayer.play("fadein")
	yield($AnimationPlayer, "animation_finished")
	find_node("StartGame").connect("pressed", self, "_on_TextureButton_pressed", [], CONNECT_ONESHOT)

func _on_TextureButton_pressed():
	$AnimationPlayer.play("fadeout")
	yield($AnimationPlayer, "animation_finished")
	game.reset()
	get_tree().change_scene("res://level/Level.tscn")
