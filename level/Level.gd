extends Node

onready var current_grid = $Rooms/Start

func _ready():
	$Player.connect("end_move", self, "end_tick")
	$Player.set_current_grid(current_grid)
	$Player.connect("dead", self, "reset")
	$Ui.connect_player($Player)
	$Timer.connect("timeout", self, "end_tick")
	center_camera()
	for room in $Rooms.get_children():
		room.connect("room_cleared", self, "room_cleared", [], CONNECT_ONESHOT)
	set_up_entities()
	$Rooms/Start.player = $Player

func set_up_entities():
	$Player.set_current_grid(current_grid)
	$Player.set_level(self)
	for entity in current_grid.get_children():
		entity.set_current_grid(current_grid)
		entity.set_level(self)

func get_current_grid():
	return current_grid

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
	for entity in current_grid.get_children():
		entity.room_cleared()

func center_camera():
	var rect = $Rooms/Start.get_used_rect()
	$Camera2D.position = rect.size * $Rooms/Start.cell_size / 2

func next_level(door):
	print("load new level")