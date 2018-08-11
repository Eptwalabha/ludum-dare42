extends Node

onready var current_grid = $Rooms/Start

func _ready():
	$Player.connect("end_move", self, "end_tick")
	$Player.set_current_grid(current_grid)
	update_life()
	for room in $Rooms.get_children():
		room.connect("room_cleared", self, "room_cleared", [], CONNECT_ONESHOT)

func get_current_grid():
	return current_grid

func _process(delta):
	pass

func tick():
	for entity in current_grid.get_children():
		entity.tick()

func end_tick():
	current_grid.update_entities()
	_update_player()
	if not current_grid.cleared:
		current_grid.is_room_clear()

func _update_player():
	if current_grid.is_falling($Player):
		$Player.fall()
		$Player.dead = true
		$Player.connect("dead", self, "reset", [], CONNECT_ONESHOT)
	var item = current_grid.get_entity_at($Player.position)

func reset(entity):
	game.life -= 1
	update_life()
	if game.life == 0:
		get_tree().quit()
	get_tree().reload_current_scene()

func update_life():
	$Ui/Life.text = "life: %d" % game.life

func room_cleared():
	pass