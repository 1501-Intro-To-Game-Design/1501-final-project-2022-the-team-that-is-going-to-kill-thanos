extends Node2D

#Import the enemy and path scenes
export(PackedScene) var importPathScene
export(PackedScene) var importEnemyScene
var enemyPathManager = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateEnemyLocation(delta)

#Adds an instance of enemy and path and stores them in enemyPathManager
func addEnemyPath():
	var pathToFollow = importPathScene.instance()
	var enemy = importEnemyScene.instance()
	enemy.position = pathToFollow.getPathLocation()
	add_child(pathToFollow)
	add_child(enemy)
	enemyPathManager.append([enemy, pathToFollow])

#Adds a new enemy and path when the timer timeouts
func _on_EnemySpawn_timeout():
	addEnemyPath()

#Increases the path's offset and sets the enemy's position to the path's position
func updateEnemyLocation(delta):
	for i in enemyPathManager:
		if is_instance_valid(i[0]):
			i[1].addToOffset(i[0].current_speed * delta)
			i[0].position = i[1].getPathLocation()
