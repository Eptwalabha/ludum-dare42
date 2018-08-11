extends TileMap

onready var level = get_parent()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func request_move(entity, direction):
	var requested_position = world_to_map(entity.position) + direction
	var cellv = get_cellv(requested_position)
	if cellv < 3 || cellv == 3:
		return map_to_world(requested_position)
	return false

func decay_tile(entity):
	var entity_pos = world_to_map(entity.position)
	var i = get_cellv(entity_pos)
	if i != -1 and i < 2:
		set_cellv(entity_pos, i + 1)
	elif i == 3:
		return
	else:
		set_cellv(entity_pos, -1)

func is_falling(entity):
	var entity_pos = world_to_map(entity.position)
	return get_cellv(entity_pos) == -1

func get_entity_at(position):
	var cell_pos = world_to_map(position)
	for entity in get_children():
		if world_to_map(entity.position) == cell_pos:
			return entity
	return null

func move_toward_player(entity):
	return false