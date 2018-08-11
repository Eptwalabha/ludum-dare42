extends Node

onready var current_grid = $Rooms/Start

func _ready():
	$Player.connect("end_move", self, "end_tick")
	$Player.set_current_grid(current_grid)
	$Player.connect("dead", self, "reset")
	$Player.connect("hp_changed", $Ui, "player_hp_changed")
	$Timer.connect("timeout", self, "end_tick")
	for room in $Rooms.get_children():
		room.connect("room_cleared", self, "room_cleared", [], CONNECT_ONESHOT)

func get_current_grid():
	return current_grid

func get_player():
	return $Player

func _process(delta):
	pass

func tick():
	$Player.set_process(false)
	for entity in current_grid.get_children():
		entity.tick()
	$Timer.wait_time = 0.3
	$Timer.start()

func end_tick():
	$Player.set_process(true)
	current_grid.update_entities()
	_update_player()
	if not current_grid.cleared:
		current_grid.is_room_clear()

func _update_player():
	if current_grid.is_falling($Player):
		$Player.fall()
		$Player.dead = true

func reset(entity):
	game.hp = 5
	get_tree().reload_current_scene()

func room_cleared():
	print("youpi")
	pass