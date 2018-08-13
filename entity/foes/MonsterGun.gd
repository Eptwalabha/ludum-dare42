extends "res://entity/foes/Foe.gd"

func _ready():
	actions = [ JUMP, AIM, SHOOT, MOVE ]

func action_aim():
	look_entity(player)
	$Pivot/Sprite.play("aim")
	point_arm_at(player)
	aim = player.position

func point_arm_at(player):
	pass

func can_attack():
	return false