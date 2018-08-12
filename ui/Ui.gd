extends CanvasLayer

func _ready():
	player_hp_changed(game.hp)

func player_hp_changed(hp):
	$ControlNode/MarginContainer/HBoxContainer/Life.text = "life: %d" % hp