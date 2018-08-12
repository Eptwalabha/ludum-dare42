extends "res://entity/Entity.gd"

enum DIRECTION {
	EAST,
	SOUTH,
	WEST,
	NORTH
}

signal hp_changed(hp)
var max_hp = 5

func _ready():
	$Pivot.position = Vector2()

func move_to(next_position):
	$Pivot.position = - (next_position - position)
	position = next_position
	var x = $Pivot.position.x
	if x != 0:
		$Pivot/Sprite.flip_h = x > 0
	
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

func _get_direction(direction):
	match direction:
		EAST: return Vector2(1, 0)
		SOUTH: return Vector2(0, 1)
		WEST: return Vector2(-1, 0)
		NORTH: return Vector2(0, -1)

func fall():
	if dead:
		return
	dead = true
	$AnimationPlayer.play("fall")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("died", self)

func hit(amount):
	_add_hp(- amount)
	if dead:
		fall()
	else:
		print("aie")
		set_process(false)
		$AnimationPlayer.play("hurt")
		yield($AnimationPlayer, "animation_finished")
		set_process(true)

func heal(amount):
	_add_hp(amount)

func _add_hp(amount):
	hp += amount
	if hp <= 0:
		dead = true
		emit_signal("died", self)
	elif hp > max_hp:
		hp = max_hp
	emit_signal("hp_changed", hp)