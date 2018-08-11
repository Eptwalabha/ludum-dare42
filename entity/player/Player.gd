extends Node2D

signal end_move()
signal dead(entity)

onready var level = get_parent()
onready var grid = null
var dead = false
export(int) var weight = 0

func _ready():
	pass

func set_current_grid(current_grid):
	grid = current_grid

func _process(delta):
	var direction = _get_direction()
	if not direction:
		return
	var next_position = grid.request_move(self, direction)
	if next_position:
		level.tick()
		move_to(next_position)

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
	set_process(false)
	$AnimationPlayer.play("move")
	$Tween.interpolate_property(
			$Pivot, "position",
			$Pivot.position, Vector2(),
			$AnimationPlayer.current_animation_length,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
	grid.step_at(self)
	emit_signal("end_move")

func fall():
	$AnimationPlayer.play("death_fall")
	$AnimationPlayer.connect("animation_finished", self, "end_animation", [], CONNECT_ONESHOT)
	set_process(false)

func end_animation(t):
	emit_signal("dead", self)