extends "res://entity/Entity.gd"

var actions = [ IDLE, MOVE, IDLE ]
export(int) var action_index = 0
export(int) var explosion_radius = 3

func _ready():
	$Pivot.position = Vector2()
	action_index = action_index % actions.size()

func tick():
	if dead:
		return
	
	if pass_turn:
		pass_turn = false
		return

	action_index = (action_index + 1) % actions.size()
	match actions[action_index]:
		MOVE:
			move()
		_:
			pass

func move():
	var direction_int = randi() % 4
	for i in range(0, 3):
		var direction = _get_direction((direction_int + i) % 4)
		var next = grid.request_move(self, direction)
		if next.is_available:
			move_to(next.next_position)
			break

func move_to(next_position):
	$Pivot.position = - (next_position - position)
	position = next_position
	
	set_process(false)
	
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
	$AnimationPlayer.play("fall")
	yield($AnimationPlayer, "animation_finished")
	self.queue_free()

func _get_direction(direction):
	match direction:
		0: return Vector2(-1, 0)
		1: return Vector2(1, 0)
		2: return Vector2(0, -1)
		_: return Vector2(0, 1)

func interact_with_player(player):
	if dead:
		return
	pass_turn = true
	hp -= 1
	if hp > 0:
		$AnimationPlayer.play("hurt")
	else:
		fall()
	player.hit()

func _on_Area2D_area_entered(area):
	pass

func is_foe():
	return true