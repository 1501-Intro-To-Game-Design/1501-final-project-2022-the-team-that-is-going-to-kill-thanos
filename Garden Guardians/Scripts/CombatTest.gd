extends Node2D

export(PackedScene) var importMovingEnemiesScene
export(PackedScene) var importMovingMorselsScene
var combatManager = []
# Called when the node enters the scene tree for the first time.
func _ready():
	initiateMorselsAndEnemies()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func initiateMorselsAndEnemies():
	var enemies = importMovingEnemiesScene.instance()
	var morsels = importMovingMorselsScene.instance()
	add_child(enemies)
	add_child(morsels)
	combatManager.append([enemies, morsels])
