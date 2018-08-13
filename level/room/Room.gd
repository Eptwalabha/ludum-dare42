extends TileMap

signal room_cleared()

var player = null
var visited = false
var cleared = false

var cells_to_restore = []

func _ready():
	init_room()

func init_room():
	for cell in get_used_cells():
		var cellv =  get_cellv(cell)
		if is_destructible_floor(cellv):
			cells_to_restore.append(cell)

func set_foes(foes):
	for foe in foes:
		$Entities.add_child(foe)

func set_data(the_player, level):
	player = the_player
	player.set_level(level)
	player.set_room(self)
	for entity in $Entities.get_children():
		entity.set_level(level)
		entity.set_room(self)
		entity.connect("died", level, "entity_died", [], CONNECT_ONESHOT)

func get_entities():
	return $Entities.get_children()

func tick():
	for entity in $Entities.get_children():
		entity.tick()
	for projectile in $Projectiles.get_children():
		projectile.tick()

func reset():
	player.position = $Start.position
	for projectile in $Projectiles.get_children():
		projectile.queue_free()
	restore_floor()

func restore_floor():
	for cell in cells_to_restore:
		var type = get_cellv(cell)
		if type > 1 or type == -1:
			set_cellv(cell, 1)

func start():
	player.position = $Start.position
	is_room_cleared()

func request_move(entity, direction):
	var requested_position = _world_to_map(entity.position) + direction
	var cellv = get_cellv(requested_position)
	var target_entity = get_entity_at(requested_position)
	var response = {
		"is_available": false,
		"entity": target_entity,
		"type": -1
	}
	if can_walk_on_floor(cellv):
		response.is_available = target_entity == null or target_entity == entity or target_entity.walkable
		response.next_position = map_to_world(requested_position)
		response.type = get_cellv(requested_position)
	return response

func can_walk_on_floor(type):
	return type <= 3

func is_destructible_floor(type):
	return type != -1 and type <=2

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
	for entity in $Entities.get_children():
		if entity.dead:
			continue
		if _world_to_map(entity.position) == cell_pos:
			return entity
	if _world_to_map(player.position) == cell_pos:
		return player
	return null

func move_toward_player(entity):
	return false

func is_room_cleared():
	if cleared:
		return true
	for entity in $Entities.get_children():
		if entity.is_foe() and not entity.dead:
			return false
	cleared = true
	emit_signal("room_cleared")
	for entity in $Entities.get_children():
		entity.room_cleared()
	return true

func update_entities():
	for entity in $Entities.get_children():
		if entity.dead:
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

func add_projectile(projectile):
	$Projectiles.add_child(projectile)