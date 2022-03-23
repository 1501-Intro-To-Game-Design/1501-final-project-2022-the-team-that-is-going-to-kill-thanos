extends Node2D

#Import the enemy and path scenes
export(PackedScene) var importPathScene
export(Array, PackedScene) var importEnemyScene
var enemyPathManager = []

var wave = 0
var inProgres = false
var rng = RandomNumberGenerator.new()
var enemys = []
var dP = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/ui".connect("nextRoundGo", self, "_on_nextRoundGo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateEnemyLocation(delta)
	if enemys.size() <= 0 and inProgres:
		inProgres = false
		$EnemySpawn.stop()
		$"/root/ui".waveEnd()

func start_wave():
	dP = (wave*5) +15 #can revise this later
	$"/root/ui".updateRound(wave)
	rng.randomize()
	while dP > 0: #picks a random unit, removes its danger point value from this waves allowence, then adds it to enemytospawnlist
		var value = rng.randf_range(0,importEnemyScene.size())
		var temp = importEnemyScene[value].instance()
		while (temp.spawned_num_wood + (temp.spawned_num_metal*3)) > dP +100: #Once toothpicks are added remove the +100
			value = rng.randf_range(0,importEnemyScene.size())
			temp = importEnemyScene[value].instance()
		dP -= (temp.spawned_num_wood + (temp.spawned_num_metal*3))
		print("dp is ", dP)
		enemys.append(importEnemyScene[value])
	inProgres = true 
	$EnemySpawn.start()

#Adds an instance of enemy and path and stores them in enemyPathManager
func addEnemyPath():
	var pathToFollow = importPathScene.instance()
	var enemy = enemys.pop_front().instance()
	enemy.position = pathToFollow.getPathLocation()
	add_child(pathToFollow)
	add_child(enemy)
	enemyPathManager.append([enemy, pathToFollow])

#Adds a new enemy and path when the timer timeouts
func _on_EnemySpawn_timeout():
	if inProgres:
		addEnemyPath()
		$EnemySpawn.start()

#Increases the path's offset and sets the enemy's position to the path's position
func updateEnemyLocation(delta):
	for i in enemyPathManager:
		if is_instance_valid(i[0]):
			i[1].addToOffset(i[0].current_speed * delta)
			i[0].position = i[1].getPathLocation()
	
func _on_nextRoundGo():
	$"/root/ui".waveInProgress()
	wave += 1
	start_wave()
