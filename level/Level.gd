extends Node

var room = null
onready var BulletFactory = preload("res://entity/weapon/BulletFactory.tscn").instance()
onready var RoomFactory = preload("res://level/room/RoomFactory.tscn").instance()
var cleared_level = 0

func _ready():
	room = RoomFactory.generate(game.level)
	get_node("Room").add_child(room)
	center_camera()
	set_up_entities()

func set_up_entities():
	$Ui.connect_player($Player)
	room.set_data($Player, self)
	$Player.connect("died", self, "reset")
	room.connect("room_cleared", self, "room_cleared", [], CONNECT_ONESHOT)
	$Player.set_process(true)
	room.start()

func get_room():
	return room

func tick():
	$Player.set_process(false)
	room.tick()
	_timeout("_post_actions", 0.3)

func _post_actions():
	room.update_entities()
	_update_player()
	if not room.cleared:
		room.is_room_cleared()
	_apply_damages()

func _apply_damages():
	var any_hit = $Player.apply_damages()
	for entity in room.get_entities():
		if entity.dead:
			continue
		if entity.apply_damages():
			any_hit = true
	if any_hit:
		_timeout("_end_turn", 0.3)
	else:
		_end_turn()

func _end_turn():
	if cleared_level == 1:
		cleared_level = 2
		_timeout("restore_room", 0.3)
	else:
		$Player.set_process(true)

func _update_player():
	if room.is_falling($Player):
		$Player.fall()

func reset(entity):
	if game.hp > 0:
		room.reset()
		$Player.revive()
	else:
		game.hp = 5
		get_tree().reload_current_scene()

func player_revive():
	$Player.set_process(true)

func room_cleared():
	cleared_level = 1

func restore_room():
	room.restore_floor()
	$Player.set_process(true)

func center_camera():
	var rect = room.get_used_rect()
	var size = rect.size * room.cell_size
	var vsize = get_viewport().get_visible_rect().size
	var ratiox = size.x / (vsize.x - 100)
	var ratioy = size.y / (vsize.y - 100)
	var ratio = max(ratiox, ratioy)
	$Camera2D.position = size / 2
	$Camera2D.zoom = Vector2(ratio, ratio)

func next_level(door):
	print("load new level")
	game.level += 1
	get_tree().reload_current_scene()

func spawn_damage(entity, amount):
	pass

func spawn_bullet(owner, position, direction, speed):
	var velocity = (direction * speed) * room.cell_size
	var bullet = BulletFactory.shoot_at(position, velocity)
	bullet.set_owner(owner)
	bullet.damage = owner.damage
	room.add_projectile(bullet)

func _timeout(function_name, wait_time):
	$Timer.wait_time = wait_time
	$Timer.connect("timeout", self, function_name, [], CONNECT_ONESHOT)
	$Timer.start()

func entity_died(entity):
	entity.queue_free()