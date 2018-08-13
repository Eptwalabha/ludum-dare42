extends "res://entity/Character.gd"

signal key_count_changed(amount)

func _ready():
	hp = game.hp
	set_process(false)

func modify_hp(sum):
	hp += sum
	game.hp = hp
	emit_signal("hp_changed", hp)

func _process(delta):
	if dead:
		return

	var direction = _get_direction()
	if not direction:
		return

	var destination = grid.request_move(self, direction)
	var entity = destination.entity
	if destination.is_available:
		move_to(destination.next_position)
		if entity:
			entity.interact_with_player(self)
			if entity.is_foe():
				attack_entity(entity, 1)
	else:
		if entity:
			entity.interact_with_player(self)
			if entity.is_foe():
				attack_entity(entity, 1)
			level.tick()

func _get_direction():
	var direction = Vector2()
	if Input.is_action_pressed("ui_up"):
		direction = Vector2(0, direction.y - 1)
	if Input.is_action_pressed("ui_down"):
		direction = Vector2(0, direction.y + 1)
	if Input.is_action_pressed("ui_left"):
		direction = Vector2(direction.x - 1, 0)
	if Input.is_action_pressed("ui_right"):
		direction = Vector2(direction.x + 1, 0)
	return direction

func move_to(next_position):
	$Pivot.position = - (next_position - position)
	position = next_position
	level.tick()

	$AnimationPlayer.play("move")
	$Tween.interpolate_property(
			$Pivot, "position",
			$Pivot.position, Vector2(),
			$AnimationPlayer.current_animation_length,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	grid.step_at(self)
	$AnimationPlayer.play("idle")

func pick_key():
	game.key += 1
	emit_signal("key_count_changed", game.key)

func use_key():
	game.key -= 1
	emit_signal("key_count_changed", game.key)

func is_player():
	return true
