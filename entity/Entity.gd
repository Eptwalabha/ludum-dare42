extends Node2D

signal died(entity)

enum {
	MOVE,
	IDLE,
	SHOOT
}

onready var grid = get_parent()
export(int) var hp = 3
export(int, 0, 3) var weight = 1
var pass_turn = false
var dead

func _ready():
	pass

func tick():
	pass

func interact_with(entity):
	pass

func interact_with_player(player):
	pass

func shot(bullet):
	pass

func get_direction():
	return false

func fall():
	pass

func is_foe():
	return false