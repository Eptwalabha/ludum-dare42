extends Node

func _ready():
	$Control/VBoxContainer/Label.text = "Too bad, you died at level -%d" % game.level

func _on_Menu_pressed():
	get_tree().change_scene("res://game/MenuScreen.tscn")
