extends "res://entity/foes/Foe.gd"

func _ready():
	actions = [ IDLE, MOVE, IDLE ]

func action_move():
	var direction_int = randi() % 4
	for i in range(0, 3):
		var direction = _get_direction((direction_int + i) % 4)
		var next = grid.request_move(self, direction)
		if next.is_available:
			move_to(next.next_position)
			break

func _get_direction(direction):
	match direction:
		0: return Vector2(-1, 0)
		1: return Vector2(1, 0)
		2: return Vector2(0, -1)
		_: return Vector2(0, 1)