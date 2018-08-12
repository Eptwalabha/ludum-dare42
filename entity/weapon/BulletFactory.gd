extends Node

func _ready():
	pass

func shoot_at(position, velocity):
	var bullet = $BulletRegular.duplicate()
	bullet.position = position
	bullet.velocity = velocity
	return bullet