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
			AIM:
				action_aim()
			_:
				pass

func is_foe():
	return true

func interact_with_player(player):
	pass

func action_move():
	var direction_int = randi() % 4
	for i in range(0, 3):
		var direction = _get_direction((direction_int + i) % 4)
		var next = grid.request_move(self, direction)
		if next.is_available and next_position_valid(next):
			move_to(next.next_position)
			break

func next_position_valid(next):
	return next.type != -1

func action_aim():
	pass

func action_shoot():
	look_entity(player)
	var direction = (player.position - position).normalized()
	var bullet_position = position
	if get_node("Pivot/Sprite/ArmJoin"):
		bullet_position = get_node("Pivot/Sprite/ArmJoin").global_position
	level.spawn_bullet(self, bullet_position, direction, 2)
	$AnimationPlayer.play("shoot")

func action_chase():
	var manhattan = grid.manhattan_vector_to_player(self)
	var order = get_direction_priority_from_manhattan(manhattan)
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
