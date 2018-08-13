extends CanvasLayer

func _ready():
	player_hp_changed(game.hp)
	player_key_count_changed(game.key)

func connect_player(player):
	player.connect("hp_changed", self, "player_hp_changed")
	player.connect("key_count_changed", self, "player_key_count_changed")

func player_hp_changed(hp):
	$ControlNode/MarginContainer/HBoxContainer/Life.text = "life: %d" % hp
	
func player_key_count_changed(amount):
	$ControlNode/MarginContainer/HBoxContainer/Key.text = "key: %d" % amount

func level_changed(level):
	$ControlNode/MarginContainer/HBoxContainer/Level.text = "basement: %d" % level