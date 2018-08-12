extends "res://entity/Entity.gd"

enum DIRECTION {
	EAST,
	SOUTH,
	WEST,
	NORTH
}

signal hp_changed(hp)
var max_hp = 5

var turn_action = null

func _ready():
	$Pivot.position = Vector2()

func move_to(next_position, animation):
	$Pivot.position = - (next_position - position)
	position = next_position
	var x = $Pivot.position.x
	if x != 0:
		$Pivot/Sprite.flip_h = x > 0
	
	$AnimationPlayer.play(animation)
	
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

func hit(entity, amount):
	var damage = {
		"from": entity,
		"amount": amount
	}
	stack_damages.append(damage)

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

func apply_damages():
	if dead:
		return
	var sum = 0
	var hit = false
	for damage in stack_damages:
		hit = true
		sum += damage.amount
		level.spawn_damage(self, damage.amount)
	hp -= sum
	if hit:
		hurt()
	if hp <= 0:
		died()
	stack_damages = []
	return hit

func hurt():
	$AnimationPlayer.play("hurt")

func died():
	dead = true
	$AnimationPlayer.play("fall")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("died", self)

func attack_entity(entity, damage):
	look_entity(entity)
	entity.hit(self, damage)
	$AnimationPlayer.play("attack")

func look_entity(entity):
	$Pivot/Sprite.flip_h = entity.position.x < position.x


func _on_Area2D_area_entered(area):
	var bullet = get_area_entity(area)
	if not bullet.projectile:
		return
	var entity = bullet.owner_entity
	if entity == self:
		return
	hit(entity, bullet.damage)
	bullet.queue_free()

func get_area_entity(area):
	return area.get_parent().get_parent()