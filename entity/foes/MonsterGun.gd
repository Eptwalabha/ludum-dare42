extends "res://entity/foes/Foe.gd"

func _ready():
	actions = [ MOVE, AIM, SHOOT, MOVE ]

func action_aim():
	look_entity(player)
	$Pivot/Sprite.play("aim")
	$Pivot/Sprite/ArmJoin/Gun.visible = true
	point_arm_at(player)

func point_arm_at(player):
	pass

func can_attack():
	return false