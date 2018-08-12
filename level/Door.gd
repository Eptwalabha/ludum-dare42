extends "res://entity/Entity.gd"

export(bool) var locked = true
var opened = false
var enabled = false

export(String, FILE) var next_scene

func _ready():
	$Position2D/Sprite/KeyPad.visible = locked

func enable():
	enabled = true
	if locked:
		$Position2D/Sprite/KeyPad.play("enable")
	else:
		open()
	
func open():
	if locked:
		return
	$Position2D/Sprite/KeyPad.visible = false
	$Position2D/Sprite.play("open")
	opened = true
	walkable = true
	$Position2D/Area2D.connect("area_entered", self, "_on_Area2D_area_entered")

func unlock():
	locked = false
	open()

func _on_Area2D_area_entered(area):
	if area.get_parent().get_parent().is_player():
		level.next_level(self)

func interact_with_player(player):
	if enabled and locked and game.key > 0:
		player.use_key()
		unlock()

func room_cleared():
	enable()