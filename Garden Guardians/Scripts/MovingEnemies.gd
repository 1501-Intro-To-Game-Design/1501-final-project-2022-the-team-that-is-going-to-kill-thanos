extends Node2D

#Import the enemy and path scenes
export(PackedScene) var importPathScene
export(Array, PackedScene) var importEnemyScene
var enemyPathManager = []

var wave = 0
var inProgres = false
var rng = RandomNumberGenerator.new()
var enemys = []
var enemyNum = 0
var dps = []
var dP = 0
var endGate = false

signal player_life_lost(livesLost)

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/ui".connect("nextRoundGo", self, "_on_nextRoundGo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateEnemyLocation(delta)
	print(enemyNum)
	if enemys.size() <= 0 and inProgres:
		dps.clear() #jsut in case theres 1 left
		inProgres = false
		$EnemySpawn.stop()
		$"/root/ui".waveEnd()
	if enemyNum <= 0 and endGate:
		endGate = false
		$"/root/ui".enemysDead()

func start_wave():
	dP = (wave*5) +15 #can revise this later
	$"/root/ui".updateRound(wave)
	rng.randomize()
	while dP > 0: #picks a random unit, removes its danger point value from this waves allowence, then adds it to enemytospawnlist
		var value = rng.randf_range(0,importEnemyScene.size())
		var temp = importEnemyScene[value].instance()
		while (temp.spawned_num_wood + (temp.spawned_num_metal*3)) > dP:
			value = rng.randf_range(0,importEnemyScene.size())
			temp = importEnemyScene[value].instance()
		dps.append(temp.spawned_num_wood + (temp.spawned_num_metal*3))
		dP -= (temp.spawned_num_wood + (temp.spawned_num_metal*3))
		print("dp is ", dP)
		enemys.append(importEnemyScene[value])
	inProgres = true 
	$EnemySpawn.start()

#Adds an instance of enemy and path and stores them in enemyPathManager
func addEnemyPath():
	var pathToFollow = importPathScene.instance()
	var enemy = enemys.pop_front().instance()
	enemy.connect("dead", self, "_enemy_killed")
	enemy.connect("alive", self, "_enemy_created")
	enemy.home = self
	enemy.position = pathToFollow.getPathLocation()
	add_child(pathToFollow)
	add_child(enemy)
	enemyPathManager.append([enemy, pathToFollow])
	enemyNum += 1
	endGate = true 
	
func add_enemy_to_path(spawner, spawned):
	var pathToFollow = importPathScene.instance()
	spawned.position = pathToFollow.getPathLocation()
	add_child(pathToFollow)
	add_child(spawned)
	enemyPathManager.append([spawned, pathToFollow])
	
	for i in enemyPathManager:
		if i[0] == spawner:
			enemyPathManager[enemyPathManager.size()-1][1].addToOffset(i[1].get_offset() + 20)
			enemyPathManager[enemyPathManager.size()-1][0].position = enemyPathManager[enemyPathManager.size()-1][1].getPathLocation()

#Adds a new enemy and path when the timer timeouts
func _on_EnemySpawn_timeout():
	if inProgres:
		addEnemyPath()
		$EnemySpawn.start(dps.pop_front()/2) #1dp = wait 0.5 seconds

#Increases the path's offset and sets the enemy's position to the path's position
func updateEnemyLocation(delta):
	for i in enemyPathManager:
		if is_instance_valid(i[0]):
			i[1].addToOffset(i[0].current_speed * delta)
			i[0].position = i[1].getPathLocation()
			if i[1].get_unit_offset() >= 1:
				i[0].destroy(false)
				emit_signal("player_life_lost", i[0].spawned_num_wood + (i[0].spawned_num_metal*3))

func get_offset(enemy_node):
	for i in enemyPathManager:
		if i[0] == enemy_node:
			return i[1].get_offset()
	
func _on_nextRoundGo():
	$"/root/ui".waveInProgress()
	wave += 1
	start_wave()

func _enemy_killed():
	enemyNum -= 1
	print("dead")

func _enemy_created():
	enemyNum += 1
	print("spawned")
