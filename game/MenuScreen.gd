extends Node

var amount = 0

func _ready():
	$AnimationPlayer.play("fadein")
	yield($AnimationPlayer, "animation_finished")
	find_node("StartGame").connect("pressed", self, "_on_TextureButton_pressed", [], CONNECT_ONESHOT)

func _process(delta):
	amount += delta
	$ParallaxBackground.scroll_offset.x = sin(amount) * 10
	$ParallaxBackground.scroll_offset.y = cos(amount) * 10
	
func _on_TextureButton_pressed():
	$AnimationPlayer.play("fadeout")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://game/StoryScreen.tscn")
