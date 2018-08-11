extends TileMap

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

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