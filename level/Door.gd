extends "res://entity/Entity.gd"

export(bool) var locked = false
export(bool) var opened = false

export(String, FILE) var next_scene

func open():
	if locked:
		return
	opened = true
	walkable = true
	$Position2D/Area2D.connect("area_entered", self, "_on_Area2D_area_entered")

func _on_Area2D_area_entered(area):
	if area.get_parent().get_parent() == level.get_player():
		level.next_level(self)

func interact_with_player(player):
	if locked and game.key > 0:
		player.use_key()
		unlock()

func unlock():
	locked = false
	open()