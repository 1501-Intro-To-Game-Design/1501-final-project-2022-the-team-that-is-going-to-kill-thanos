extends RigidBody2D
export var armored = false
export var chefs_knife = false
export var ranged_morsel = false
var ranged_enemies = []
var can_attack = false
export var spawner = false
export (PackedScene) var to_spawn
export (PackedScene) var proj_scene
export var spawn_cooldown = 1.0
var original_mod
var ranged_attacking = false
var followPath
var resource_kill_time = 1

var inactive_targets = []

var enemies = []
export var groups_to_check = []
export var max_health = 10.0
var current_health = 1
export var damage = 2.0
export var attackSpeed = 1.0
var inCombat = false
var target
export (PackedScene) var resource

var stunned = false
var pullingBack = []

export var spawned_num_wood = 0
export var spawned_num_metal = 0

#SOUNDS STUFF
export (Array, Resource) var sounds
export (Array, Resource) var movingSounds #This is just for morsals
var rng = RandomNumberGenerator.new()

#MOVING STUFF
var velocity = Vector2.ZERO
var destination = Vector2.ZERO
var direction = Vector2.ZERO
export var max_speed = 50
var current_speed = 0
var min_speed = 0
var tempSpeed = 0
var tempMaxSpeed = 0
var moving = false;
var homeTower
var morselNum
var isTraitor = false

signal dead
signal alive
var home

export var spawns_on_death = false
export (PackedScene) var death_spawn_scene
export var num_spawn_on_death = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if ranged_morsel and "Enemies" in get_groups():
		get_parent().get_parent().get_node("Player").connect("died", self, "_on_player_died")
	original_mod = $Sprite.get_self_modulate()
	if(is_instance_valid($AnimationPlayer)):
		$AnimationPlayer.playback_speed = util.g_speed
	max_speed *= util.g_speed
	spawn_cooldown /= util.g_speed
	attackSpeed /= util.g_speed
	resource_kill_time /= util.g_speed
	rng.randomize()
	current_health = max_health
	current_speed = max_speed;
	min_speed = 5 + (max_speed*0.20)
	tempSpeed = current_speed
	tempMaxSpeed = max_speed
	$Health.max_value = max_health
	$Health.value = current_health
	if spawner:
		prepareSpawnTimer()
	prepareAttackTimer()
	if ranged_morsel:
		$RangedAttack.start(attackSpeed + 1)

func _go_To(loc): #This is just for when moarsals are told to go somewhere else
	destination = loc
	direction = destination - position
	rng.randomize()
	$AudioStreamPlayer2D.volume_db = 0 + util.g_sound
	$AudioStreamPlayer2D.stream = movingSounds[rng.randf_range(0,movingSounds.size())] #picks radom sound and plays it
	$AudioStreamPlayer2D.play()
	moving = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkInCombat()
	if (not inCombat) and (can_attack) and (ranged_morsel) and ranged_attacking:
		ranged_attack() 
	#MOVING STUFF
	if moving and sqrt(pow((destination.x - self.global_position.x), 2) + pow((destination.y - self.global_position.y), 2)) < 2.5: #if youve arrived
		moving = false
		print("arrived")
		if(is_instance_valid($AnimationPlayer) and not inCombat and not ranged_attacking):
			$AnimationPlayer.stop()
			$AnimationPlayer.play("Idle")
	velocity.x = 0
	if moving:  
		if is_in_group("Morsels") and not inCombat:
			current_speed = max_speed
		position += direction.normalized() * current_speed * delta * 2
		if(is_instance_valid($AnimationPlayer) and $AnimationPlayer.current_animation != "RangedAttack" and not inCombat):	
			$AnimationPlayer.play("Move")
	var checkAffected = false
	for i in pullingBack:
		if not is_instance_valid(i[0]):
			if i[1] == true:
				max_speed = tempMaxSpeed
				min_speed = tempSpeed
				i[0] = false

func ranged_attack():
	if ranged_enemies.size() > 0:
		var lowest = 1000
		var index = -1
		for i in range(0, ranged_enemies.size()):
			var distance = sqrt(pow((ranged_enemies[i].get_global_position().x - self.get_global_position().x), 2) + pow((ranged_enemies[i].get_global_position().y - self.get_global_position().y), 2))
			if(distance < lowest):
				lowest = distance
				index = i
		can_attack = false
		var t = Timer.new()
		if(is_instance_valid($AnimationPlayer) and is_instance_valid(ranged_enemies[index])):
			$AnimationPlayer.play("RangedAttack")
		else:
			if not inCombat and not moving:	
				$AnimationPlayer.play("RESET")
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Idle")
		t.set_wait_time(.2 / util.g_speed)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		if(ranged_morsel):
			$RangedAttack.start(attackSpeed + 1)
		
		if index < ranged_enemies.size():
			if is_instance_valid(ranged_enemies[index]):
				var projectile = proj_scene.instance()
				get_parent().add_child(projectile)
				projectile.damage = damage/2
				rng.randomize()
				$AudioStreamPlayer2D.stream = sounds[rng.randf_range(0,sounds.size())] #picks radom sound and plays it
				$AudioStreamPlayer2D.volume_db = 0 + util.g_sound
				$AudioStreamPlayer2D.play()
				projectile.position = $ShootPoint.get_global_position()
				projectile.target = ranged_enemies[index]
		else:
			if not inCombat:
				$AnimationPlayer.play("Idle")
	else:
		if not $AnimationPlayer.get_current_animation() == "Move" and not inCombat:
			$AnimationPlayer.play("Idle")

func checkInCombat():
	if inCombat:
		if(ranged_morsel):
			$RangedAttack.stop()
			ranged_attacking = false
		if is_instance_valid(target):
			if "Player" in target.get_groups():
				if not target.alive:
					on_combat_end()
				else:
					current_speed = 0
			else:
				current_speed = 0
		else:
			on_combat_end()
	else:
		if not stunned and not ranged_attacking:
			current_speed = max_speed
		if enemies.size() > 0:
			for enemy in enemies:
				checkType(enemy)

func _on_Enemy_body_entered(body):
	checkType(body)
	

func start_stun(duration):
	stunned = true
	current_speed = 0
	$StunTimer.start(duration)

func checkType(body):
	for group in body.get_groups():
		if group == "Traps" and "Traps" in groups_to_check:
			body.applyEffects($Enemy)
		if (group == "Morsels" and "Morsels" in groups_to_check) or (group == "Enemies" and "Enemies" in groups_to_check):
			setTarget(body)
		if (group == "Player" and "Player" in groups_to_check):
			if body.alive:
				setTarget(body)
		if (group == "Traitor" and "Traitor" in groups_to_check):
			setTarget(body)

func setResourceTarget(body):
	if not inCombat:
		inCombat = true
		target = body
		$ResourceKillTimer.start(resource_kill_time)
		$AnimationPlayer.play("ResourceKill")
		$Regen.stop()
		$RegenWait.stop()

func setTarget(body):
	if not inCombat:
		if body.inCombat: #if target is in combat
			if body.target == self or body.is_in_group("Player"): #if target's target is me
				inCombat = true
				target = body
				ranged_attacking = false
				if(is_instance_valid($AnimationPlayer)):
					$AnimationPlayer.play("RESET")
					$AnimationPlayer.stop()
					$AnimationPlayer.play("Attack")
				$Attack.start()
				$Regen.stop()
				$RegenWait.stop()
		else:
			inCombat = true
			target = body
			ranged_attacking = false
			body.setTarget(self)
			if(is_instance_valid($AnimationPlayer)):
				$AnimationPlayer.play("RESET")
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Attack")
			$Attack.start()
			$Regen.stop()
			$RegenWait.stop()
	else: #if I'm in combat
		if not (body in inactive_targets):
			inactive_targets.append(body)

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed
	
func prepareSpawnTimer():
	$Spawn.start(spawn_cooldown)
	var t = Timer.new()
	t.set_wait_time(3.1 / util.g_speed)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Spawn")
	t.queue_free()	

func _on_Attack_timeout():
	if is_instance_valid(target):
		rng.randomize()
		$AudioStreamPlayer2D.stream = sounds[rng.randf_range(0,sounds.size())] #picks radom sound and plays it
		$AudioStreamPlayer2D.volume_db = 0 + util.g_sound
		$AudioStreamPlayer2D.play()
		if not chefs_knife or target.is_in_group("Player"):
			target.battle_action(damage)
		else:
			target.battle_action(target.max_health)
		if target != null:
			if(is_instance_valid($AnimationPlayer)):
				$AnimationPlayer.play("RESET")
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Attack")
			
			
func on_combat_end():
	inCombat = false
	$Attack.stop()
	if(self.is_in_group("Morsels")):
		$RegenWait.start()
	for enemy in inactive_targets:
		if(is_instance_valid(enemy)):
			checkType(enemy)
			enemy.checkType(self)
	can_attack = false
	if ranged_morsel:
		$RangedAttack.start(attackSpeed + 1)
		if(ranged_enemies.size() > 0):
			ranged_attacking = true
	#if(is_instance_valid($AnimationPlayer) and not inCombat):
		#$AnimationPlayer.play("RESET")
		#$AnimationPlayer.stop()
	if self.is_in_group("Morsels"):
		if(is_instance_valid($AnimationPlayer) and not inCombat):
			$AnimationPlayer.play("Idle")
		
	elif self.is_in_group("Enemies"):
		if(is_instance_valid($AnimationPlayer) and not inCombat):	
			$AnimationPlayer.play("Move")
		
func yellow_glow():
	var t = Timer.new()
	t.set_wait_time(.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	$Sprite.self_modulate = Color(1, .65, .1, 1)
	yield(t, "timeout")
	$Sprite.self_modulate = original_mod
	t.queue_free()	

func battle_action(dmg):
	change_health(-1 * dmg)

func change_health(change, direct = false, pierce = false):
	if not direct:
		var rand_num = rng.randf_range(0, 0.12)
		change = change + (change * rand_num)
	var lowest_dmg = change * .1
	if not pierce:
		if(armored and change < 0):
			change = change - 0.2
			change = (0.7 * change)
	if(change < 0):
		red_glow()
	elif(change > 0):
		green_glow()
	else:
		yellow_glow()
	if(change < 0 and change > lowest_dmg):
		change = lowest_dmg
	current_health += change
	$Health.value = current_health
	if(current_health <= 0):
		if self.is_in_group("Morsels"): #decrease number of active morsels
			if is_instance_valid(homeTower):
				homeTower.morsel_death(self)
		if(spawns_on_death):
			for i in range (num_spawn_on_death):
				var enemy_instance = death_spawn_scene.instance()
				enemy_instance.spawned_num_wood = 0
				enemy_instance.spawned_num_metal = 0
				enemy_instance.get_node("Sprite").self_modulate = Color(.4, .3, .29)
				enemy_instance.connect("dead", home, "_enemy_killed")
				get_parent().add_enemy_to_path(self, enemy_instance)
				get_parent().add_to_offset(enemy_instance, -15 + (i*20))
				emit_signal("alive")
		destroy()
	if(current_health > max_health):
		current_health = max_health
		if not (self.is_in_group("Enemies")):
			$Regen.stop()
	if(not inCombat and change < 0 and not(self.is_in_group("Enemies"))):
		$RegenWait.start()
		
func get_percent_health():
	return(current_health/max_health)
	
func get_offset():
	return (get_parent().get_offset(self))

func set_offset(offset):
	get_parent().set_offset(self, offset)

func destroy(dropResources = true):
	var r
	if self.is_in_group("Morsels"): #decrease number of active morsels
		if is_instance_valid(homeTower):
			homeTower.babies -= 1
			homeTower.morselPositions[morselNum] = false
	if is_in_group("Enemies"):
		emit_signal("dead")
		if dropResources:
			for i in range(spawned_num_wood):
				r = resource.instance() #spawn resources
				r._spawn(true, global_position) # true = wood, false = metal
				get_parent().add_child(r)
			for i in range(spawned_num_metal):
				r = resource.instance() #spawn resources
				r._spawn(false, global_position) # true = wood, false = metal
				get_parent().add_child(r)
	queue_free()


func _on_Area2D_body_exited(body):
	if body in inactive_targets: #if body in array
		inactive_targets.remove(inactive_targets.find(body))
	if ("Player" in body.get_groups()) and (body == target):
		on_combat_end()


func _on_StunTimer_timeout():
	stunned = false
	if not ranged_attacking:
		current_speed = max_speed


func _on_Spawn_timeout():
	#can add a new timer to stop movement for .5 secs or something
	#.9
	var enemy_instance = to_spawn.instance()
	enemy_instance.spawned_num_wood = 0
	enemy_instance.spawned_num_metal = 0
	enemy_instance.get_node("Sprite").self_modulate = Color(.4, .3, .29)
	enemy_instance.connect("dead", home, "_enemy_killed")
	get_parent().add_enemy_to_path(self, enemy_instance)
	emit_signal("alive")
	if not inCombat:
		$AnimationPlayer.play("Move")
	else:
		$AnimationPlayer.play("Attack")
	prepareSpawnTimer()


func _on_RangedAttack_timeout():
	can_attack = true


func _on_RegenWait_timeout():
	$Regen.start()


func _on_Regen_timeout():
	change_health(max_health*0.15)


func _on_ResourceKillTimer_timeout():
	#start animation + pause timer thing
	if is_instance_valid(target):
		target.get_parent().queue_free()
	on_combat_end()


func _on_Area2D_area_entered(area):
	var item = area.get_parent()
	if item.is_in_group("Resources"):
		if("Resources" in groups_to_check):
			setResourceTarget(area)

func red_glow():
	var t = Timer.new()
	t.set_wait_time(.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	$Sprite.self_modulate = Color(1, 0, 0, 1)
	yield(t, "timeout")
	$Sprite.self_modulate = original_mod
	t.queue_free()

func green_glow():
	var t = Timer.new()
	t.set_wait_time(.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	$Sprite.self_modulate = Color(0, 1, 0, 1)
	yield(t, "timeout")
	$Sprite.self_modulate = original_mod
	t.queue_free()


func _on_RangedAttackAnimTimer_timeout():
	if(is_instance_valid($AnimationPlayer)):	
		$AnimationPlayer.play("RangedAttack")
	
func posess():
	remove_from_group("Enemies")
	add_to_group("Traitor")
	groups_to_check = []
	groups_to_check.append("Enemies")
	emit_signal("dead")
	isTraitor = true
	current_speed *= -1
	max_speed *= -1
	tempMaxSpeed *= -1
	tempSpeed *= -1
	min_speed *= -1
	$Sprite.set_modulate(Color(0.368627, 0.058824, 0.556863))
	$Area2D.monitoring = false
	$Area2D.monitoring = true


func _on_Area2D_body_entered(body):
	checkType(body)


func _on_RangeArea_body_entered(body):
	if(body.is_in_group("Enemies")):
		ranged_enemies.append(body)
		if not inCombat:
			ranged_attacking = true
			current_speed = 0


func _on_RangeArea_body_exited(body):
	if(body.is_in_group("Enemies")):
		ranged_enemies.remove(ranged_enemies.find(body))
		if ranged_enemies.size() == 0:
			ranged_attacking = false
			current_speed = max_speed
			if not inCombat:
				if moving:
					$AnimationPlayer.play("RESET")
					$AnimationPlayer.stop()
					$AnimationPlayer.play("Move")
				else:
					$AnimationPlayer.play("RESET")
					$AnimationPlayer.stop()
					$AnimationPlayer.play("Idle")


func _on_Range2_body_entered(body):
	if(body.is_in_group("Morsels")):
		ranged_enemies.append(body)
		if not inCombat:
			ranged_attacking = true
			current_speed = 0
	if(body.is_in_group("Player") and body.alive):
		ranged_enemies.append(body)
		if not inCombat:
			ranged_attacking = true
			current_speed = 0


func _on_Range2_body_exited(body):
	if(body.is_in_group("Morsels") or body.is_in_group("Player")):
		ranged_enemies.remove(ranged_enemies.find(body))
		if ranged_enemies.size() == 0:
			ranged_attacking = false
			current_speed = max_speed
			if not inCombat:
				$AnimationPlayer.play("RESET")
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Move")

func _on_player_died():
	for i in ranged_enemies:
		if "Player" in i.get_groups():
			ranged_enemies.remove(ranged_enemies.find(i))
			ranged_attacking = false
			on_combat_end()
	print(ranged_enemies)
