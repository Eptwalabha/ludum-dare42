extends "res://entity/Character.gd"

signal super_top(entity)

enum ACTION {
	MOVE,
	IDLE,
	SHOOT,
	CHASE
}

var actions = []
export(int) var damage = 1
export(int) var action_index = 0

func _ready():
	$Pivot.position = Vector2()

func tick():
	if dead or actions.size() == 0:
		return
	
	if pass_turn:
		pass_turn = false
		return

	action_index = (action_index + 1) % actions.size()
	match actions[action_index]:
		MOVE:
			action_move()
		SHOOT:
			action_shoot()
		CHASE:
			action_chase()
		_:
			pass

func is_foe():
	return true

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

func action_move():
	pass

func action_shoot():
	pass

func action_chase():
	pass
