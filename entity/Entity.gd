extends Node2D

signal died(entity)

enum {
	MOVE,
	IDLE,
	SHOOT
}

onready var grid = get_parent()
export(int) var hp = 3
var dead


func _ready():
	pass

func tick():
	pass

func interact_with(entity):
	pass

func shot(bullet):
	pass

func get_direction():
	return false