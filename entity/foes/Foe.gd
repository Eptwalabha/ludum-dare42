extends "res://entity/Character.gd"

signal super_top(entity)

enum ACTION {
	MOVE,
	IDLE,
	SHOOT,
	CHASE,
	JUMP,
	AIM
}

var actions = []
export(int) var damage = 1
export(int) var action_index = 0
export(int) var attack_range = 1
var cool_down = 0
var player
var aim = null

func _ready():
	$Pivot.position = Vector2()

func set_level(current_level):
	level = current_level
	player = level.get_node("Player")

func tick():
	if dead or actions.size() == 0:
		return
	
	if cool_down > 0:
		cool_down -= 1
		return

	if player_in_range() and can_attack():
		attack_player()
	else:
		match actions[action_index]:
			MOVE:
				action_move()
			SHOOT:
				action_shoot()
			CHASE:
				action_chase()
			JUMP:
				action_jump()
			AIM:
				action_aim()
			_:
				pass
		action_index = (action_index + 1) % actions.size()

func is_foe():
	return true

func interact_with_player(player):
	pass

func next_position_valid(next):
	return next.type != -1

func action_move():
	var random_order = _random_order()
	_move_to(random_order)

func action_aim():
	aim = player.position

func action_shoot():
	look_entity(player)
	var direction = (player.position - position).normalized()
	if aim:
		direction = (aim - position).normalized()
		aim = null
	var bullet_position = position
	if get_node("Pivot/Sprite/ArmJoin"):
		bullet_position = get_node("Pivot/Sprite/ArmJoin").global_position
	level.spawn_bullet(self, bullet_position, direction, 1.5)
	$AnimationPlayer.play("shoot")

func action_chase():
	var manhattan = grid.manhattan_vector_to_player(self)
	var order = get_direction_priority_from_manhattan(manhattan)
	_move_to(order)

func action_jump():
	var random_order = _random_order()
	_move_to(random_order, 2, "jump")

func _random_order():
	var direction_int = randi() % 4
	var order = []
	for i in range(0, 4):
		order.append((direction_int + i) % 4)
	return order

func _move_to(order, distance = 1, animation = "move"):
	var picky = null
	var moved = false
	for i in order:
		var direction = _get_direction(i % 4) * distance
		var next = grid.request_move(self, direction)
		if next.is_available:
			if not next_position_valid(next):
				picky = next
			else:
				move_to(next.next_position, animation)
				moved = true
				break
	if not moved and picky:
		move_to(picky.next_position, animation)

func player_in_range():
	return grid.manhattan_dist_to_player(self) <= attack_range

func can_attack():
	return true

func attack_player():
	attack_entity(player, damage)
	cool_down = 1

func get_direction_priority_from_manhattan(manhattan):
	var dirx = [EAST, WEST]
	var diry = [SOUTH, NORTH]
	if manhattan.x < 0:
		dirx = [WEST, EAST]
	if manhattan.y < 0:
		diry = [NORTH, SOUTH]
	if abs(manhattan.x) >= abs(manhattan.y):
		return [dirx[0], diry[0], dirx[1], diry[1]]
	return [diry[0], dirx[0], diry[1], dirx[1]]
