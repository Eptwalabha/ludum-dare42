extends Node

func _ready():
	$Control/VBoxContainer/Label.text = "Too bad"

func _on_Menu_pressed():
	get_tree().change_scene("res://game/MenuScreen.tscn")