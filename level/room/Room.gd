extends TileMap

signal room_cleared()

var player = null
var cleared = false
export(bool) var spawn_chest_when_cleared = false
export(float) var percent_restoration = 1.0
export(int) var min_level = 0
export(int) var max_level = 30

var cells_to_restore = []

func _ready():
	init()

func init():
	for cell in get_used_cells():
		var cellv =  get_cellv(cell)
		if is_destructible_floor(cellv):
			cells_to_restore.append({
				"pos" : cell,
				"type" : cellv
			})
	var exit_pos = _world_to_map($Entities/Exit.position)
	set_cellv(exit_pos, 0)

func set_foes(foes):
	var p_pos = _world_to_map($Start.position)
	for foe in foes:
		var attempt = 0
		var added = false
		while not added and attempt < 5:
			var pos = random_position()
			if pos == null:
				break
			if manhattan_dist(pos, p_pos) > 3:
				foe.position = map_to_world(pos)
				$Entities.add_child(foe)
				added = true
			attempt += 1

func set_data(the_player, level):
	player = the_player
	player.set_level(level)
	player.set_room(self)
	for entity in $Entities.get_children():
		entity.set_level(level)
		entity.set_room(self)
		entity.connect("died", level, "entity_died", [], CONNECT_ONESHOT)

func set_percent_restoration(percent):
	percent_restoration = percent

func set_locked(locked):
	$Entities/Exit.locked = locked
	if locked:
		var key = preload("res://entity/items/Key.tscn").instance()
		var key_pos = random_position()
		if key_pos == null:
			$Entities/Exit.locked = false
		else:
			key.position = map_to_world(key_pos)
			set_cellv(key_pos, 3)
			$Entities.add_child(key)
			remove_cell_from_cells_to_restore(key_pos)

func remove_cell_from_cells_to_restore(cell):
	var new_cells = []
	for cell_data in cells_to_restore:
		if cell_data.pos != cell:
			new_cells.append(cell_data)
	cells_to_restore = new_cells

func random_position():
	var pos = null
	var size = cells_to_restore.size()
	var attempt = 0
	while pos == null and attempt < 20:
		var random_cell = cells_to_restore[randi() % size].pos
		if get_entity_at(random_cell) == null:
			pos = random_cell
		attempt += 1
	return pos

func spawn_random_chest():
	var pos = random_position()
	if pos == null:
		return
	var chest = preload("res://entity/items/Chest.tscn").instance()
	chest.position = map_to_world(pos)
	$Entities.add_child(chest)
	
func spawn_chest_when_cleared():
	spawn_chest_when_cleared = true

func get_entities():
	return $Entities.get_children()

func tick():
	for entity in $Entities.get_children():
		entity.tick()
	for projectile in $Projectiles.get_children():
		projectile.tick()

func reset():
	place_player()
	for projectile in $Projectiles.get_children():
		projectile.queue_free()
	restore_floor()

func restore_floor():
	for data in cells_to_restore:
		var cell = data.pos
		var type_ori = data.type
		var type = get_cellv(cell)
		if type == -1:
			set_cellv(cell, max(1, data.type))
		elif type != type_ori and randf() < percent_restoration:
			set_cellv(cell, max(1, type_ori))

func place_player():
	var entity = get_entity_at(_world_to_map($Start.position))
	if entity == null or entity == player:
		player.position = $Start.position
	else:
		var pos = random_position()
		if pos == null:
			player.position = $Start.position
		else:
			player.position = map_to_world(pos)

func start():
	place_player()
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

	if player and _world_to_map(player.position) == cell_pos:
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
	if spawn_chest_when_cleared:
		spawn_random_chest()
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
	var player_position = $Start.position
	if player:
		player_position = player.position
	var player_pos = _world_to_map(player_position)
	return Vector2(player_pos.x - pos.x, player_pos.y - pos.y)

func manhattan_dist_to_player(entity):
	var v = manhattan_vector_to_player(entity)
	return abs(v.x) + abs(v.y)

func manhattan_dist(pos1, pos2):
	var v = Vector2(pos1.x - pos2.x, pos1.y - pos2.y)
	return abs(v.x) + abs(v.y)

func add_projectile(projectile):
	$Projectiles.add_child(projectile)