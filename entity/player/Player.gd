extends Node2D

signal end_move()
signal dead(entity)
signal hp_changed(hp)
signal key_count_changed(amount)

onready var level = get_parent()
onready var grid = null
var dead = false
var moving_direction = Vector2()
var hp = 4
export(int) var weight = 0

func _ready():
	pass

func set_current_grid(current_grid):
	grid = current_grid

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
	else:
		if entity:
			entity.interact_with_player(self)
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

func fall():
	if dead:
		return
	dead = true
	$AnimationPlayer.play("death_fall")
	$AnimationPlayer.connect("animation_finished", self, "end_animation", [], CONNECT_ONESHOT)
	set_process(false)

func end_animation(t):
	emit_signal("dead", self)

func _on_Area2D_area_entered(area):
	pass

func hit():
	game.hp -= 1
	emit_signal("hp_changed", game.hp)
	set_process(false)
	if game.hp > 0:
		$AnimationPlayer.play("hurt")
		yield($AnimationPlayer, "animation_finished")
		set_process(true)
	else:
		fall()

func heal(amount):
	game.hp += amount
	emit_signal("hp_changed", game.hp)

func pick_key():
	game.key += 1
	emit_signal("key_count_changed", game.key)

func use_key():
	game.key -= 1
	emit_signal("key_count_changed", game.key)
	