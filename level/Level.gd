extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Player.connect("end_move", self, "end_tick")
	print($Grid.get_used_rect())
	update_life()

func _process(delta):
	pass

func tick():
	for entity in $Grid.get_children():
		entity.tick()

func end_tick():
	$Grid.decay_tile($Player)
	if $Grid.is_falling($Player):
		$Player.fall_to_death()
		$Player.connect("dead", self, "reset", [], CONNECT_ONESHOT)
	var item = $Grid.get_entity_at($Player.position)

func reset(entity):
	game.life -= 1
	update_life()
	if game.life == 0:
		get_tree().quit()
	get_tree().reload_current_scene()

func update_life():
	$Ui/Life.text = "life: %d" % game.life