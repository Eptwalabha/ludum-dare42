extends Node

var Room_1 = preload("res://level/room/Room_1.tscn")
var FoeFactory = preload("res://entity/foes/FoeFactory.tscn").instance()

func generate(level):
	var room = Room_1.instance()
	var foes = spawn_foes(level)
	room.position = Vector2()
	room.set_foes(foes)
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
	print("level ", level, " nbr ", nbr_foes, " available ", available_foes)
	return foes

func is_door_locked(level):
	if level < 3:
		return false
	elif level == 3:
		return true
	elif level < 10:
		return rand() < 0.5
	elif level < 20:
		return rand() < 0.8
	else:
		return true