extends "res://entity/foes/Foe.gd"

var actions = [ IDLE, MOVE, IDLE ]
export(int) var action_index = 0
export(int) var explosion_radius = 3

func _ready():
	$Pivot.position = Vector2()
	action_index = action_index % actions.size()

func tick():
	if dead:
		return

	action_index = (action_index + 1) % actions.size()
	match actions[action_index]:
		MOVE:
			var direction = get_direction()
			var next_position = grid.request_move(self, direction)
			if next_position:
				move_to(next_position)
		_:
			pass

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

func shot(bullet):
	hp -= 1
	if hp <= 0:
		explode()

func fall():
	dead = true
	$AnimationPlayer.play("fall")
	yield($AnimationPlayer, "animation_finished")
	self.queue_free()

func get_direction ():
	match randi() % 4:
		0: return Vector2(-1, 0)
		1: return Vector2(1, 0)
		2: return Vector2(0, -1)
		_: return Vector2(0, 1)
