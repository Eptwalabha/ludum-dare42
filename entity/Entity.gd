extends Node2D

signal died(entity)

var grid = null
var level = null

export(int) var hp = 3
export(int, 0, 3) var weight = 1
var pass_turn = false
var walkable = false
var dead = false
var projectile = false
var stack_damages = []

func _ready():
	pass


func set_current_grid(current_grid):
	grid = current_grid

func set_level(current_level):
	level = current_level

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

func is_player():
	return false

func room_cleared():
	pass

func prepare_for_turn():
	set_process(false)

func apply_damages():
	pass