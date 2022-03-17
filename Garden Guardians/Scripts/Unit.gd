extends RigidBody2D

var inactive_targets = []

export var groups_to_check = []
export var max_health = 10
var current_health = 1
export var damage = 2
export var attackSpeed = 1.0
var inCombat = false
var target
export (PackedScene) var resource

export var spawned_num_wood = 0
export var spawned_num_metal = 0

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
	current_health = max_health
	current_speed = max_speed;
	$Health.max_value = max_health
	$Health.value = current_health
	prepareAttackTimer()

func _go_To(loc):
	destination = loc
	moving = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkInCombat()
	#MOVING STUFF
	if moving and sqrt(pow((destination.x - self.global_position.x), 2) + pow((destination.y - self.global_position.y), 2)) < 2: #if youve arrived
		moving = false
	velocity.x = 0
	if moving:  
		position += direction.normalized() * current_speed * delta * 10

func checkInCombat():
	if inCombat:
		current_speed = 0
	else:
		current_speed = max_speed

func _on_Enemy_body_entered(body):
	checkType(body)

func checkType(body):
	for group in body.get_groups():
		if group == "Traps" and "Traps" in groups_to_check:
			body.applyEffects($Enemy)
		if (group == "Morsels" and "Morsels" in groups_to_check) or (group == "Enemies" and "Enemies" in groups_to_check):
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
			else: #if not in combat
				if not (body in inactive_targets):
					inactive_targets.append(body)
	pass

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed

func _on_Attack_timeout():
	if is_instance_valid(target):
		target.battle_action(damage, self)
			
			
func on_combat_end():
	inCombat = false
	$Attack.stop()
	for enemy in inactive_targets:
		checkType(enemy)
		enemy.checkType(self)
	

func battle_action(dmg, attacker):
	if(current_health - dmg <= 0): #if dead
		attacker.on_combat_end()
		if self.is_in_group("Morsels"):
			if is_instance_valid(homeTower):
				homeTower.babies -= 1
				homeTower.morselPositions[morselNum] = false
	change_health(-1 * dmg)
		
func change_health(change):
	current_health += change
	$Health.value = current_health
	if(current_health <= 0):
		destroy()
	if(current_health > max_health):
		current_health = max_health


func destroy():
	var r = resource.instance() #spawn resources
	if is_in_group("Enemies"):
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
