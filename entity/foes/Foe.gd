extends "res://entity/Character.gd"

signal super_top(entity)

enum ACTION {
	MOVE,
	IDLE,
	SHOOT,
	CHASE,
	JUMP
}

var actions = []
export(int) var damage = 1
export(int) var action_index = 0
export(int) var attack_range = 1

func _ready():
	$Pivot.position = Vector2()

func tick():
	if dead or actions.size() == 0:
		return
	
	if pass_turn:
		pass_turn = false
		return

	if player_in_range() and can_attack():
		attack_player()
	else:
		action_index = (action_index + 1) % actions.size()
		match actions[action_index]:
			MOVE:
				action_move()
			SHOOT:
				action_shoot()
			CHASE:
				action_chase()
			JUMP:
				action_jump()
			_:
				pass

func is_foe():
	return true

func interact_with_player(player):
	pass

func action_move():
	pass

func action_shoot():
	pass

func action_chase():
	var manhattan = grid.manhattan_vector_to_player(self)
	var order = get_direction_priority_from_manhattan(manhattan)
	print(order)
	for i in order:
		var direction = _get_direction(i)
		var next = grid.request_move(self, direction)
		if next.is_available:
			move_to(next.next_position)
			break

func action_jump():
	pass

func player_in_range():
	return grid.manhattan_dist_to_player(self) <= attack_range

func can_attack():
	return true

func attack_player():
	level.get_node("Player").hit(damage)

func get_direction_priority_from_manhattan(manhattan):
	var dirx = [EAST, WEST]
	var diry = [SOUTH, NORTH]
	print(manhattan)
	if manhattan.x < 0:
		dirx = [WEST, EAST]
	if manhattan.y < 0:
		diry = [NORTH, SOUTH]
	if abs(manhattan.x) >= abs(manhattan.y):
		return [dirx[0], diry[0], dirx[1], diry[1]]
	return [diry[0], dirx[0], diry[1], dirx[1]]
	
	