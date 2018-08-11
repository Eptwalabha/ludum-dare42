extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Player.connect("end_move", self, "end_tick")

func _process(delta):
	
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func tick():
	pass

func end_tick():
	$Grid.decay_tile($Player)
	if $Grid.is_falling($Player):
		$Player.fall_to_death()
		$Player.connect("dead", self, "reset", [], CONNECT_ONESHOT)

func reset():
	get_tree().reload_current_scene()