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
signal player_life_lost(livesLost)
var wave_hardness_multiplier = 1

#wave stuff
var thresh1 = 0.8
var thresh2 = 0.8
var thresh3 = 0.9
var deincroment = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	reset_state()
	$"/root/ui".updateRound(wave)
	rng.randomize()
	$"/root/ui".connect("nextRoundGo", self, "_on_nextRoundGo")
	$"/root/ui".connect("restart", self, "reset_state")

func reset_state():
	print("yo")
	enemys.clear()
	enemystoKill = 0
	dps.clear()
	dP = 0
	budget = 0
	toPluck = 0 
	deincroment = 0
	thresh1 = 0.8
	thresh2 = 0.8
	thresh3 = 0.9
	wave = 0
	wave_hardness_multiplier = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateEnemyLocation(delta)
	if enemys.size() <= 0 and inProgres and enemystoKill == 0:
		dps.clear() #jsut in case theres 1 left
		inProgres = false
		$EnemySpawn.stop()
		$"/root/ui".waveEnd()
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
	#Threshhold movers
	if wave == 5:
		thresh1 -= 0.1
	elif wave == 8:
		thresh1 -= 0.15
	elif wave == 11:
		thresh1 -= 0.1
		thresh2 -= 0.1
	elif wave == 15:
		 #dp = 160 || .02 = .3
		thresh1 -= 0.15
		thresh2 -= 0.1
		thresh3 -= 0.1
	elif wave == 20:
		thresh1 -= 0.15
		thresh2 -= 0.1
	elif wave == 25:
		thresh1 -= 0.1
		thresh2 -= 0.15
		thresh3 -= 0.1
	
	enemystoKill = 0
	dP = int(stepify(((wave * (wave + 1))/2 * wave_hardness_multiplier) + 4, 1.0)) # = (wave*7) -1
	#5, 7, 10, 14, 19, 25, 31, 38, 46, 55
	print(dP)
	if wave > 3:
		dP += 3
	budget = dP
	$"/root/ui".updateRound(wave)
	rng.randomize()
	var value
	var temp
	if wave > 9:
		value = rng.randi_range(0, 2)
		if value == 0:
			bossFight = true
		else:
			bossFight = false
	while dP > 0: #picks a random unit, removes its danger point value from this waves allowence, then adds it to enemytospawnlist	
		if budget *thresh3 <= dP and wave >= 10 and bossFight:
			value = rng.randi_range(0,enemyScene4.size()-1)
			temp = enemyScene4[value].instance()
			dps.append(36)
			dP -= (36)
			enemys.append(enemyScene4[value])
			enemystoKill += 1
		elif budget *thresh2 <= dP and wave > 5:
			value = rng.randi_range(0,enemyScene3.size()-1)
			temp = enemyScene3[value].instance()
			dps.append(9)
			dP -= (9)
			enemystoKill += 1
			enemys.append(enemyScene3[value])
		elif budget *thresh1 <= dP and wave > 2:	
			value = rng.randi_range(0,enemyScene2.size()-1)
			temp = enemyScene2[value].instance()
			dps.append(4)
			dP -= (4)
			enemys.append(enemyScene2[value])
			enemystoKill += 1
		else:
			value = rng.randi_range(0,enemyScene1.size()-1)
			temp = enemyScene1[value].instance()
			dps.append(1)
			dP -= 1
			enemys.append(enemyScene1[value])
			enemystoKill += 1
			#while (temp.spawned_num_wood + (temp.spawned_num_metal*3)) > dP:
				#value = rng.randi_range(0,enemyScene1.size())
				#temp = enemyScene1[value].instance()
	if wave < 20:
		deincroment += 1
	inProgres = true 
	$EnemySpawn.start()

#Adds an instance of enemy and path and stores them in enemyPathManager
func addEnemyPath():
	var rand_num = rng.randi_range(0, importPathSceneArray.size() - 1)
	var pathToFollow = importPathSceneArray[rand_num].instance()
	var enemy = enemys.pop_at(toPluck).instance()
	enemy.connect("dead", self, "_enemy_killed")
	enemy.connect("alive", self, "_enemy_created")
	enemy.home = self
	enemy.position = pathToFollow.getPathLocation()
	enemy.followPath = pathToFollow
	enemy.path = "Path " + String(rand_num)
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
			$EnemySpawn.start(2 - (deincroment * 0.09375)) #0.5, 
		elif temp <= 4: #if its soilder
			$EnemySpawn.start(5 - (deincroment * 0.1875)) #2
		else: #if its a big boy
			$EnemySpawn.start(8 - (deincroment * 0.25))#4

		

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
					emit_signal("player_life_lost", 10)
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
	wave_hardness_multiplier += 0.02
	if wave > 20:
		wave_hardness_multiplier += 0.01
	start_wave()

func _enemy_killed():
	enemystoKill -= 1

func _enemy_created():
	enemystoKill += 1
