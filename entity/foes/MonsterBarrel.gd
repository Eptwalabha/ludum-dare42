extends "res://entity/foes/Foe.gd"

func _ready():
	actions = [ IDLE, MOVE, IDLE ]

func can_attack():
	return false

func next_position_valid(next):
	return true