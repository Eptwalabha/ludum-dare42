extends Node2D

signal end_move()
signal dead(entity)

onready var level = get_parent()
onready var grid = level.get_node("Grid")

func _ready():
	pass

func _process(delta):
	var direction = _get_direction()
	if not direction:
		return
	var next_position = grid.request_move(self, direction)
	if next_position:
		level.tick()
		move_to(next_position)

func _get_direction():
	var x = 0
	var y = 0
	if Input.is_action_pressed("ui_up"):
		x = 0
		y -= 1
	if Input.is_action_pressed("ui_down"):
		x = 0
		y += 1
	if Input.is_action_pressed("ui_left"):
		x -= 1
		y = 0
	if Input.is_action_pressed("ui_right"):
		x += 1
		y = 0
	return Vector2(x, y)

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
	emit_signal("end_move")

func fall_to_death():
	$AnimationPlayer.play("death_fall")
	$AnimationPlayer.connect("animation_finished", self, "end_animation", [], CONNECT_ONESHOT)
	set_process(false)

func end_animation(t):
	emit_signal("dead", self)