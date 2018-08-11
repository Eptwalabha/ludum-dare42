extends Control

func _ready():
	player_hp_changed(game.hp)

func player_hp_changed(hp):
	$HBoxContainer/Life.text = "life: %d" % hp