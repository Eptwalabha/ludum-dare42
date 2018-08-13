extends Node

var Room_1 = preload("res://level/room/Room_1.tscn")
var FoeFactory = preload("res://entity/foes/FoeFactory.tscn").instance()

func generate(level):
	var room = Room_1.instance()
	var foes = spawn_foes(level)
	room.position = Vector2()
	room.init()
	room.set_locked(is_door_locked(level))
	var spawn_chest = spawn_chest(level)
	if spawn_chest:
		room.spawn_random_chest()
	if not spawn_chest and spawn_chest_when_room_cleared(level):
		room.spawn_chest_when_cleared()
	room.set_foes(foes)
	room.percent_restoration = percent_restoration(level)
	return room

func nbr_foes(level):
	if level < 5:
		return 1
	elif level < 10:
		return randi() % 2 + 1
	elif level < 15:
		return randi() % 3 + 2
	elif level < 20:
		return randi() % 5 + 3
	elif level < 25:
		return randi() % 5 + 4
	else:
		return 5

func spawn_foes(level):
	var foes = []
	var available_foes = FoeFactory.available_foes(level)
	var nbr_foes = nbr_foes(level)
	for i in range(nbr_foes):
		var random_type = available_foes[randi() % available_foes.size()]
		var foe = FoeFactory.generate(random_type)
		foes.append(foe)
		pass
	return foes

func is_door_locked(level):
	if level < 3:
		return false
	elif level == 3:
		return true
	elif level < 10:
		return randf() < 0.5
	elif level < 20:
		return randf() < 0.8
	else:
		return true

func spawn_chest_when_room_cleared(level):
	if level < 5:
		return randf() < 0.8
	elif level < 10:
		return randf() < 0.5
	elif level < 20:
		return randf() < 0.2
	else:
		return false

func spawn_chest(level):
	if level == 1:
		return true
	elif level < 10:
		return randf() < 0.4
	elif level < 20:
		return randf() < 0.2
	else:
		return randf() < 0.1

func percent_restoration(level):
	if level < 10:
		return .9
	elif level < 20:
		return .7
	else:
		return .5