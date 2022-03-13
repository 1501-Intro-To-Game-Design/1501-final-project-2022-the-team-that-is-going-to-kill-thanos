extends Node2D

export(PackedScene) var importPathScene
export(PackedScene) var importMorselScene
var morselPathManager = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateMorselLocation(delta)

func addMorselPath():
	var pathToFollow = importPathScene.instance()
	var morsel = importMorselScene.instance()
	pathToFollow.addToOffset(1015.11)
	morsel.position = pathToFollow.getPathLocation()
	add_child(pathToFollow)
	add_child(morsel)
	morselPathManager.append([morsel, pathToFollow])

func _on_MorselSpawn_timeout():
	addMorselPath()

func updateMorselLocation(delta):
	for i in morselPathManager:
		if is_instance_valid(i[0]):
			i[1].addToOffset(-1 * (i[0].speed * delta))
			i[0].position = i[1].getPathLocation()
