extends RigidBody2D

export var spawner = false
export (PackedScene) var to_spawn
export var spawn_cooldown = 1

var inactive_targets = []

export var groups_to_check = []
export var max_health = 10
var current_health = 1
export var damage = 2
export var attackSpeed = 1.0
var inCombat = false
var target
export (PackedScene) var resource

var stunned = false

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
var moving = false;
var homeTower
var morselNum

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	current_health = max_health
	current_speed = max_speed;
	$Health.max_value = max_health
	$Health.value = current_health
	prepareSpawnTimer()
	prepareAttackTimer()

func _go_To(loc): #This is just for when moarsals are told to go somewhere else
	destination = loc
	direction = destination - position
	rng.randomize()
	$AudioStreamPlayer2D.stream = movingSounds[rng.randf_range(0,movingSounds.size())] #picks radom sound and plays it
	$AudioStreamPlayer2D.play()
	moving = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkInCombat()
	#MOVING STUFF
	if moving and sqrt(pow((destination.x - self.global_position.x), 2) + pow((destination.y - self.global_position.y), 2)) < 2: #if youve arrived
		moving = false
	velocity.x = 0
	if moving:  
		position += direction.normalized() * current_speed * delta * 2

func checkInCombat():
	if inCombat:
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
		if not stunned:
			current_speed = max_speed

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

func setTarget(body):
	if not inCombat:
		if body.inCombat: #if target is in combat
			if body.target == self: #if target's target is me
				inCombat = true
				target = body
				$Attack.start()
		else:
			inCombat = true
			target = body
			$Attack.start()
	else: #if I'm in combat
		if not (body in inactive_targets):
			inactive_targets.append(body)

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed
	
func prepareSpawnTimer():
	$Spawn.start(spawn_cooldown)

func _on_Attack_timeout():
	if is_instance_valid(target):
		rng.randomize()
		$AudioStreamPlayer2D.stream = sounds[rng.randf_range(0,sounds.size())] #picks radom sound and plays it
		$AudioStreamPlayer2D.play()
		target.battle_action(damage)
			
			
func on_combat_end():
	inCombat = false
	$Attack.stop()
	for enemy in inactive_targets:
		checkType(enemy)
		enemy.checkType(self)
	

func battle_action(dmg):
	change_health(-1 * dmg)
		
func change_health(change):
	var rand_num = rng.randf_range(-0.1, 0.15)
	change = change + (change * rand_num)
	current_health += change
	$Health.value = current_health
	if(current_health <= 0):
		destroy()
	if(current_health > max_health):
		current_health = max_health
		
func get_percent_health():
	return(current_health/max_health)
	
func get_offset():
	return (get_parent().get_offset(self))

func destroy(dropResources = true):
	var r
	if(dropResources):
		r = resource.instance() #spawn resources
	
	if self.is_in_group("Morsels"): #decrease number of active morsels
		if is_instance_valid(homeTower):
			homeTower.babies -= 1
			homeTower.morselPositions[morselNum] = false
	
	if is_in_group("Enemies") and dropResources:
		for i in range(spawned_num_wood):
			r._spawn(true, global_position) # true = wood, false = metal
			get_parent().add_child(r)
		for i in range(spawned_num_metal):
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
	current_speed = max_speed


func _on_Spawn_timeout():
	#can add a new timer to stop movement for .5 secs or something
	var enemy_instance = to_spawn.instance()
	get_parent().add_enemy_to_path(self, enemy_instance)
