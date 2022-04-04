extends Node2D

#Import the enemy and path scenes
export(PackedScene) var importPathScene
export(Array, PackedScene) var enemyScene1
export(Array, PackedScene) var enemyScene2
export(Array, PackedScene) var enemyScene3
export(Array, PackedScene) var enemyScene4
var enemyPathManager = []

var wave = 0
var inProgres = false
var rng = RandomNumberGenerator.new()
var enemys = []
var enemyNum = 0
var dps = []
var dP = 0
var budget = 0
var endGate = false
var toPluck = 0 
var bossFight = false
signal player_life_lost(livesLost)

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/ui".connect("nextRoundGo", self, "_on_nextRoundGo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateEnemyLocation(delta)
	if enemyNum <= 0 and enemys.size() <= 0 and inProgres:
		dps.clear() #jsut in case theres 1 left
		inProgres = false
		$EnemySpawn.stop()
		$"/root/ui".waveEnd()
		for i in get_tree().get_nodes_in_group("Towers"):
			if i.morsel_tower:
				i.spawn_remainder()
	if enemyNum <= 0 and endGate:
		endGate = false
		$"/root/ui".enemysDead()

func start_wave():
	dP = (wave*8) +5 #can revise this later
	budget = dP
	$"/root/ui".updateRound(wave)
	while dP > 0: #picks a random unit, removes its danger point value from this waves allowence, then adds it to enemytospawnlist
		rng.randomize()
		var value
		var temp
		if wave > 4:
			value = rng.randi_range(0, 2)
			if value == 0:
				bossFight = true
			else:
				bossFight = false
		if budget *0.90 <= dP and wave >= 4 and bossFight:
			value = rng.randi_range(0,enemyScene4.size()-1)
			temp = enemyScene4[value].instance()
			dps.append(temp.spawned_num_wood + (temp.spawned_num_metal*3))
			dP -= (temp.spawned_num_wood + (temp.spawned_num_metal*3))
			enemys.append(enemyScene4[value])
		elif budget *0.65 <= dP and wave >= 3:
			value = rng.randi_range(0,enemyScene3.size()-1)
			temp = enemyScene3[value].instance()
			dps.append(temp.spawned_num_wood + (temp.spawned_num_metal*3))
			dP -= (temp.spawned_num_wood + (temp.spawned_num_metal*3))
			enemys.append(enemyScene3[value])
		elif budget *0.2 <= dP and wave >= 2:	
			value = rng.randi_range(0,enemyScene2.size()-1)
			temp = enemyScene2[value].instance()
			dps.append(temp.spawned_num_wood + (temp.spawned_num_metal*3))
			dP -= (temp.spawned_num_wood + (temp.spawned_num_metal*3))
			enemys.append(enemyScene2[value])
		else:
			value = rng.randi_range(0,enemyScene1.size()-1)
			temp = enemyScene1[value].instance()
			dps.append(temp.spawned_num_wood + (temp.spawned_num_metal*3))
			dP -= (temp.spawned_num_wood + (temp.spawned_num_metal*3))
			enemys.append(enemyScene1[value])
			#while (temp.spawned_num_wood + (temp.spawned_num_metal*3)) > dP:
				#value = rng.randi_range(0,enemyScene1.size())
				#temp = enemyScene1[value].instance()
	inProgres = true 
	$EnemySpawn.start()

#Adds an instance of enemy and path and stores them in enemyPathManager
func addEnemyPath():
	var pathToFollow = importPathScene.instance()
	var enemy = enemys.pop_at(toPluck).instance()
	enemy.connect("dead", self, "_enemy_killed")
	enemy.connect("alive", self, "_enemy_created")
	enemy.home = self
	enemy.position = pathToFollow.getPathLocation()
	enemy.followPath = pathToFollow
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

func add_to_offset(enemy_node, amount):
	for i in enemyPathManager:
		if i[0] == enemy_node:
			i[1].addToOffset(amount)
			i[0].position = i[1].getPathLocation()

#Adds a new enemy and path when the timer timeouts
func _on_EnemySpawn_timeout():
	if inProgres and enemys.size() > 0:
		rng.randomize()
		toPluck = rng.randi_range(0,enemys.size()-1)
		addEnemyPath()
		var temp = dps.pop_at(toPluck)
		if temp == 1:#if its toothpick
			$EnemySpawn.start(0.4) 
		elif temp <= 3: #if its soilder
			$EnemySpawn.start(1) 
		else: #if its a big boy
			$EnemySpawn.start(2.2) 

		

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

func _enemy_created():
	enemyNum += 1
