extends Node

onready var current_grid = $Rooms/Start
onready var BulletFactory = preload("res://entity/weapon/BulletFactory.tscn").instance()

func _ready():
	center_camera()
	set_up_entities()

func set_up_entities():
	$Ui.connect_player($Player)
	$Player.set_current_grid(current_grid)
	$Player.set_level(self)
	$Player.connect("died", self, "reset")
	for entity in current_grid.get_children():
		entity.set_current_grid(current_grid)
		entity.set_level(self)
		entity.connect("died", self, "entity_died", [], CONNECT_ONESHOT)
	$Rooms/Start.connect("room_cleared", self, "room_cleared", [], CONNECT_ONESHOT)
	$Rooms/Start.player = $Player

func get_current_grid():
	return current_grid

func _process(delta):
	pass

func tick():
	prepare_entities_for_turn()
	$Player.set_process(false)
	for entity in current_grid.get_children():
		entity.tick()
	_timeout("_post_actions", 0.3)

func _post_actions():
	current_grid.update_entities()
	_update_player()
	if not current_grid.cleared:
		current_grid.is_room_clear()
	_apply_damages()

func _apply_damages():
	var any_hit = $Player.apply_damages()
	for entity in current_grid.get_children():
		if entity.dead:
			continue
		if entity.apply_damages():
			any_hit = true
	if any_hit:
		_timeout("_end_turn", 0.3)
	else:
		_end_turn()

func _end_turn():
	$Player.set_process(true)

func prepare_entities_for_turn():
	$Player.prepare_for_turn()
	for entity in current_grid.get_children():
		entity.prepare_for_turn()

func _update_player():
	if current_grid.is_falling($Player):
		$Player.fall()

func reset(entity):
	game.hp = 5
	$Player.dead = false
	get_tree().reload_current_scene()

func room_cleared():
	for entity in current_grid.get_children():
		entity.room_cleared()

func center_camera():
	var rect = $Rooms/Start.get_used_rect()
	$Camera2D.position = rect.size * $Rooms/Start.cell_size / 2

func next_level(door):
	print("load new level")

func spawn_damage(entity, amount):
	pass

func spawn_bullet(owner, position, direction, speed):
	var velocity = (direction * speed) * current_grid.cell_size
	var bullet = BulletFactory.shoot_at(position, velocity)
	bullet.set_owner(owner)
	bullet.damage = owner.damage
	current_grid.add_child(bullet)
	bullet.tick()

func _timeout(function_name, wait_time):
	$Timer.wait_time = wait_time
	$Timer.connect("timeout", self, function_name, [], CONNECT_ONESHOT)
	$Timer.start()

func entity_died(entity):
	entity.queue_free()