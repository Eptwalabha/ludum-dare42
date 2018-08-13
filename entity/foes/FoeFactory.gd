extends Node

func generate(type):
	var foe = $MonsterBarrel
	match type:
		"barrel" : foe = $MonsterBarrel
		"zombie" : foe = $MonsterZombie
		"gun" : foe = $MonsterGun
		"jump" : foe = $MonsterJump
		_ : foe = $MonsterBarrel
	return foe.duplicate()

func available_foes(level):
	if level <= 3:
		return ["barrel"]
	elif level <= 5:
		return ["barrel", "zombie"]
	elif level <= 10:
		return ["barrel", "zombie", "jump"]
	else:
		return ["barrel", "zombie", "jump", "gun"]