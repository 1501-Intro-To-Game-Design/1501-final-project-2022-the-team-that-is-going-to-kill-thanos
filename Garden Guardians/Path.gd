extends Path2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(PackedScene) var importEnemyScene
var enemy = []

func addEnemy():
	var enemyToAdd = importEnemyScene.instance()
	add_child(enemyToAdd)
	enemyToAdd.position = $Pathway.position
	enemy.append(enemyToAdd)
#enemy.position = $Pathway.position
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in enemy:
		$Pathway.set_offset($Pathway.get_offset() + i.speed)
		i.position = $Pathway.position

func _on_StartEnemy_timeout():
	addEnemy()
