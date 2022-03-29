extends Node2D


var destination = Vector2.ZERO
var direction = Vector2.ZERO
export var speed = 1
export var max_health = 10
var current_health = 1
export var attackSpeed = 2
export var damage = 2

var target
var inactive_targets = []

var moving = false;
var clicked = false;
var alive = true
var inCombat = false
var hasBeenHit = true

#Resources
var items = []

#SOUNDS STUFF
export (Array, Resource) var sounds
export (Array, Resource) var movingSounds
export (Resource) var dieSound
export (Resource) var aliveSound
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health
	$Attack.wait_time = attackSpeed
	$Health.max_value = max_health
	$Health.value = current_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if alive:
		checkInCombat()
		if moving:
			$AnimatedSprite.play()
		else:
			$AnimatedSprite.animation = "Standing"
			$AnimatedSprite.stop()
		
		if direction.x >= 0 and moving: #moving right
			$AnimatedSprite.animation = "Running"
			$AnimatedSprite.flip_h = false		
		elif direction.x < 0 and moving: #moving left
			$AnimatedSprite.animation = "Running"
			$AnimatedSprite.flip_h = true
		
		var distance = sqrt(pow((destination.x - self.global_position.x), 2) + pow((destination.y - self.global_position.y), 2))
		if moving and distance < 2: #if you've arrived
			moving = false
		#MOVEMENT STUFF
		if moving:  
			position += direction.normalized() * speed * delta * 10
	else:
		$AnimatedSprite.animation = "Dead"
		$AnimatedSprite.stop()

		
		
func _input(event):
	if alive:
	   # Mouse in viewport coordinates.
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_RIGHT:
				if !clicked and hasBeenHit:
					destination = event.position 
					direction = destination - position
					clicked = true
					moving = true;
				else: 
					clicked = false
			
		
	

func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.


func _on_PickUp_area_entered(area:Area2D): #Resources
	if alive:
		var item = area.get_parent()
		if item.is_in_group("Resources"):
			item._pulled(self)
			items.append(item)

func checkInCombat():
	if inCombat:
		if not is_instance_valid(target):
			on_combat_end()

func battle_action(dmg):
	change_health(-1 * dmg)

func change_health(change):
	current_health += change;
	if(change < 0):
		hasBeenHit = true
	$Health.value = current_health
	if(current_health <= 0):
		die()
	if(current_health > max_health):
		current_health = max_health

func die():
	alive = false
	on_combat_end()
	_load_n_play(dieSound, -1)
	current_health = 0
	$Health.value = current_health
	$Health.visible = false
	$Respawn.start()

func _on_Respawn_timeout():
	alive = true
	_load_n_play(aliveSound, 15)
	current_health = max_health
	$Health.value = current_health
	$Health.visible = true
	for enemy in inactive_targets:
		checkType(enemy)
		enemy.checkType(self)

func _on_CombatRange_body_entered(body):
	checkType(body)

func checkType(body):
	if ("Enemies" in body.get_groups()):
		setTarget(body)

func setTarget(body):
	if alive:
		if not inCombat:
			if body.inCombat:
				if body.target == self:
					inCombat = true
					target = body
					hasBeenHit = false
					$Attack.start()
					$RegenTimer.stop()
					$RegenWait.stop()
			else:
				inCombat = true
				target = body
				hasBeenHit = false
				$Attack.start()
				$RegenTimer.stop()
				$RegenWait.stop()
		else:
			if not (body in inactive_targets):		
				inactive_targets.append(body)
	else:
		if not (body in inactive_targets):
			inactive_targets.append(body)

func _on_Attack_timeout():
	if is_instance_valid(target):
		rng.randomize()
		$AudioStreamPlayer2D.stream = sounds[rng.randf_range(0, sounds.size())]
		$AudioStreamPlayer2D.play()
		target.battle_action(damage)

func on_combat_end():
	hasBeenHit = true
	inCombat = false
	$Attack.stop()
	if alive:
		if(self.is_in_group("Player")):
			$RegenWait.start()
		for enemy in inactive_targets:
			checkType(enemy)
			enemy.checkType(self)

func _on_CombatRange_body_exited(body):
	if body in inactive_targets:
		inactive_targets.remove(inactive_targets.find(body))
	if body == target:
		on_combat_end()

		
func _load_n_play(sound, vol):
	if vol != -1:
		$AudioStreamPlayer2D.volume_db = vol
	else:
		$AudioStreamPlayer2D.volume_db = 24
	$AudioStreamPlayer2D.stream = sound
	$AudioStreamPlayer2D.play()


func _on_RegenTimer_timeout():
	change_health(1)


func _on_RegenWait_timeout():
	$RegenTimer.start()
