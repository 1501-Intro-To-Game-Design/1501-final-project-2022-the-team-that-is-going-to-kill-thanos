extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(PackedScene) var importPathScene
var enemyPathManager = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func addPath():
	var pathToFollow = importPathScene.instance()
	add_child(pathToFollow)
	enemyPathManager.append(pathToFollow)
	
func _on_EnemySpawn_timeout():
	addPath()
