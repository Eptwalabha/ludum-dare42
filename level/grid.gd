extends TileMap

signal room_cleared()

var player = null setget set_player
var visited = false
var cleared = false

func _ready():
	is_room_clear()

func set_player(current_player):
	player = current_player

func request_move(entity, direction):
	var requested_position = _world_to_map(entity.position) + direction
	var cellv = get_cellv(requested_position)
	var target_entity = get_entity_at(requested_position)
	var response = {
		"is_available": false,
		"entity": target_entity
	}
	if can_walk_on_floor(cellv):
		response.is_available = target_entity == null or target_entity == entity or target_entity.walkable
		response.next_position = map_to_world(requested_position)
		response.type = get_cellv(requested_position)
	return response

func can_walk_on_floor(type):
	return type <= 3

func step_at(entity):
	var entity_pos = _world_to_map(entity.position)
	var i = get_cellv(entity_pos)
	if i >= 0 and i <= 2:
		i += entity.weight
		if i > 2:
			set_cellv(entity_pos, -1)
		else:
			set_cellv(entity_pos, i)

func explode_at(pos, radius):
	var explosion_pos = _world_to_map(pos)
	set_sellv(explosion_pos, -1)

func is_falling(entity):
	var entity_pos = _world_to_map(entity.position)
	return get_cellv(entity_pos) == -1

func get_entity_at(cell_pos):
	for entity in get_children():
		if entity.dead or entity.projectile:
			continue
		if _world_to_map(entity.position) == cell_pos:
			return entity
	if _world_to_map(player.position) == cell_pos:
		return player
	return null

func move_toward_player(entity):
	return false

func is_room_clear():
	for entity in get_children():
		if entity.is_foe() and not entity.dead:
			return false
	cleared = true
	emit_signal("room_cleared")
	return true

func update_entities():
	for entity in get_children():
		if entity.dead and entity.projectile:
			continue
		if is_falling(entity):
			entity.fall()

func _world_to_map(entity_position):
	return world_to_map(entity_position + position)

func manhattan_vector_to_player(entity):
	var pos = _world_to_map(entity.position)
	var player_pos = _world_to_map(player.position)
	return Vector2(player_pos.x - pos.x, player_pos.y - pos.y)

func manhattan_dist_to_player(entity):
	var v = manhattan_vector_to_player(entity)
	return abs(v.x) + abs(v.y)
