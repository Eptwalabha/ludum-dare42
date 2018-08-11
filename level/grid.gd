extends TileMap

signal room_cleared()

onready var level = get_parent()
var visited = false
var cleared = false

func _ready():
	is_room_clear()
	pass

func request_move(entity, direction):
	var requested_position = _world_to_map(entity.position) + direction
	var cellv = get_cellv(requested_position)
	if cellv < 3 || cellv == 3:
		return map_to_world(requested_position)
	return false

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

func get_entity_at(position):
	var cell_pos = _world_to_map(position)
	for entity in get_children():
		if _world_to_map(entity.position) == cell_pos:
			return entity
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
		if not entity.dead:
			if is_falling(entity):
				entity.fall()

func _world_to_map(entity_position):
	return world_to_map(entity_position + position)