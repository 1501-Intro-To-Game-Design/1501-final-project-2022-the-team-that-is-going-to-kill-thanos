extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(PackedScene) var importPathScene
export(PackedScene) var importEnemyScene
var enemyPathManager = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in enemyPathManager:
		i[1].addToOffset(i[0].speed)
		i[0].position = i[1].getPathLocation()

func addEnemyPath():
	var pathToFollow = importPathScene.instance()
	var enemy = importEnemyScene.instance()
	enemy.position = pathToFollow.getPathLocation()
	add_child(pathToFollow)
	add_child(enemy)
	enemyPathManager.append([enemy, pathToFollow])

func _on_EnemySpawn_timeout():
	addEnemyPath()
