extends Node2D

#Import the enemy and path scenes
export var importPathSceneArray = []
export(Array, PackedScene) var enemyScene1
export(Array, PackedScene) var enemyScene2
export(Array, PackedScene) var enemyScene3
export(Array, PackedScene) var enemyScene4
var enemyPathManager = []
var rng = RandomNumberGenerator.new()
var wave = 0
var inProgres = false
var enemys = []
var enemystoKill = 0
var dps = []
var dP = 0
var budget = 0
var toPluck = 0 
var bossFight = true
var difficulty_multiplier = 1.0
signal player_life_lost(livesLost)

#wave stuff
var thresh1 = 0.8
var thresh2 = 0.8
var thresh3 = 0.9
var deincroment = -1

var firstWaveEnd = true
var secondWaveEnd = false
var thirdWaveEnd = false
# Called when the node enters the scene tree for the first time.
func _ready():
	wave = 0
	$"/root/ui".updateRound(wave)
	rng.randomize()
	$"/root/ui".connect("nextRoundGo", self, "_on_nextRoundGo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateEnemyLocation(delta)
	if enemys.size() <= 0 and inProgres and enemystoKill == 0:
		dps.clear() #jsut in case theres 1 left
		inProgres = false
		$EnemySpawn.stop()
		$"/root/ui".waveEnd()
		if firstWaveEnd:
			firstWaveEnd = false
			secondWaveEnd = true
			get_parent().get_node("Plate10").show()
			get_parent().get_node("VegetableTutorial").show()
			$"/root/ui".metal = 2
			$"/root/ui".wood += 8
			$"/root/ui".update()
		elif secondWaveEnd:
			secondWaveEnd = false
			thirdWaveEnd = true
			get_parent().get_node("FruitUpgrades").show()
			get_parent().get_node("Plate/FUpgradeMenu").show()
			$"/root/ui".wood += 50
		elif thirdWaveEnd:
			thirdWaveEnd = false
			get_parent().get_node("Complete").show()
			
		for i in get_tree().get_nodes_in_group("Towers"):
			if i.morsel_tower:
				i.spawn_remainder()

func check_stacking(unit_to_check):
	var index = -1
	for i in range (0, enemyPathManager.size()):
		if enemyPathManager[i][0] == unit_to_check:
			index = i
	if index != -1:
		for i in range (0, enemyPathManager.size()):
			if enemyPathManager[i][2] == enemyPathManager[index][2] and enemyPathManager[index][1].get_unit_offset() - 0.002 < enemyPathManager[i][1].get_unit_offset() and enemyPathManager[index][1].get_unit_offset() + 0.002 > enemyPathManager[i][1].get_unit_offset() and index != i:
				add_to_offset(enemyPathManager[index][0], .003)

func start_wave():
	if wave == 1:
		for i in range(10):
			enemys.append(enemyScene1[0])
			dps.append(1)
		enemystoKill = 10
	elif wave == 2:
		for i in range(3):
			enemys.append(enemyScene1[0])
			dps.append(1)
		enemys.append(enemyScene2[0])
		dps.append(4)
		for i in range(4):
			enemys.append(enemyScene1[0])
			dps.append(1)
		enemys.append(enemyScene2[1])
		dps.append(4)
		enemys.append(enemyScene1[0])
		dps.append(1)
		enemystoKill = 10
	elif wave == 3:
		for i in range(5):
			enemys.append(enemyScene1[0])
			dps.append(1)
		enemys.append(enemyScene2[0])
		dps.append(4)
		enemys.append(enemyScene1[0])
		dps.append(1)
		enemys.append(enemyScene2[1])
		dps.append(4)
		for i in range(3):
			enemys.append(enemyScene1[0])
			dps.append(1)
		enemys.append(enemyScene3[0])
		dps.append(4)
		for i in range(3):
			enemys.append(enemyScene1[0])
			dps.append(1)
			enemys.append(enemyScene1[0])
			dps.append(1)
			enemys.append(enemyScene3[0])
			dps.append(4)
		enemys.append(enemyScene3[1])
		dps.append(9)
		enemys.append(enemyScene1[0])
		dps.append(1)
		enemys.append(enemyScene1[0])
		dps.append(1)
		enemystoKill = 24
	
	$"/root/ui".updateRound(wave)
	inProgres = true 
	$EnemySpawn.start()

#Adds an instance of enemy and path and stores them in enemyPathManager
func addEnemyPath():
	var rand_num = rng.randi_range(0, importPathSceneArray.size()-1)
	var pathToFollow = importPathSceneArray[rand_num].instance()
	var enemy = enemys.pop_at(toPluck).instance()
	enemy.connect("dead", self, "_enemy_killed")
	enemy.connect("alive", self, "_enemy_created")
	enemy.home = self
	enemy.position = pathToFollow.getPathLocation()
	enemy.followPath = pathToFollow
	enemy.path = "Path " + String(rand_num)
	if enemy.get_class() == "Fork":
		enemy.max_health -= 10
	elif enemy.get_class() == "Tongs":
		enemy.max_health -= 2
	add_child(pathToFollow)
	add_child(enemy)
	enemyPathManager.append([enemy, pathToFollow, rand_num])
	
func add_enemy_to_path(spawner, spawned):
	var pathToFollow = null
	for i in enemyPathManager:
		if i[0] == spawner:
			spawned.position = i[1].getPathLocation()
			pathToFollow = importPathSceneArray[i[2]].instance()
			add_child(pathToFollow)
			add_child(spawned)
			enemyPathManager.append([spawned, pathToFollow, i[2]])
			enemyPathManager[enemyPathManager.size()-1][1].addToUnitOffset(i[1].get_unit_offset() + 0.003)
			enemyPathManager[enemyPathManager.size()-1][0].position = enemyPathManager[enemyPathManager.size()-1][1].getPathLocation()
			spawned.connect("dead", self, "_enemy_killed")
			spawned.connect("alive", self, "_enemy_created")
			spawned.home = self
			spawned.path = "Path" + String(i[2])
			check_stacking(spawned)

func remove_from_array(unit_to_remove):
	for i in enemyPathManager:
		if i[0] == unit_to_remove:
			enemyPathManager.remove(enemyPathManager.find(i))

func add_to_offset(enemy_node, amount):
	for i in enemyPathManager:
		if i[0] == enemy_node:
			i[1].addToUnitOffset(amount)
			i[0].position = i[1].getPathLocation()
			check_stacking(enemy_node)

#Adds a new enemy and path when the timer timeouts
func _on_EnemySpawn_timeout():
	if inProgres and enemys.size() > 0:
		rng.randomize()
		toPluck = rng.randi_range(0,enemys.size()-1)
		addEnemyPath()
		var temp = dps.pop_at(toPluck)
		if temp <= 1:#if its toothpick
			$EnemySpawn.start(2 - (deincroment * 0.09375)) #0.5
		elif temp <= 4: #if its soilder
			$EnemySpawn.start(4 - (deincroment * 0.1875)) #1
		else: #if its a big boy
			$EnemySpawn.start(7 - (deincroment * 0.25))#3

		

#Increases the path's offset and sets the enemy's position to the path's position
func updateEnemyLocation(delta):
	for i in enemyPathManager:
		if is_instance_valid(i[0]):
			i[1].addToOffset(i[0].current_speed * delta)
			i[0].position = i[1].getPathLocation()
			if i[1].get_unit_offset() >= 1:
				i[0].destroy(false)
				if i[0].spawned_num_wood + i[0].spawned_num_metal*3 >= 20:
					emit_signal("player_life_lost", 5)
				elif i[0].spawned_num_wood + i[0].spawned_num_metal*3 >= 5:
					emit_signal("player_life_lost", 3)
				elif i[0].spawned_num_wood + i[0].spawned_num_metal*3 >= 3:
					emit_signal("player_life_lost", 2)
				else:
					emit_signal("player_life_lost", 1)
				get_parent().get_node("ColorRect").show()
				var t = Timer.new()
				t.set_wait_time(0.2)
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				get_parent().get_node("ColorRect").hide()
				t.queue_free()


func get_offset(enemy_node):
	for i in enemyPathManager:
		if i[0] == enemy_node:
			return i[1].get_offset()

func set_offset(enemy_node, offset):
	for i in enemyPathManager:
		if i[0] == enemy_node:
			i[1].setOffset(offset)
			i[0].position = i[1].getPathLocation()

func _on_nextRoundGo():
	$"/root/ui".waveInProgress()
	wave += 1
	start_wave()

func _enemy_killed():
	enemystoKill -= 1

func _enemy_created():
	enemystoKill += 1
