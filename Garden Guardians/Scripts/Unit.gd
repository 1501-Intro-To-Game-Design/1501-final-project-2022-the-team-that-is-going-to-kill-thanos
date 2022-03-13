extends RigidBody2D

export var groups_to_check = []
export var max_health = 10
var current_health = 1
export var damage = 2
export var max_speed = 50
var current_speed = 0
export var attackSpeed = 2
var inCombat = false
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health
	current_speed = max_speed;
	prepareAttackTimer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkInCombat()

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
			if !inCombat:
				inCombat = true
				target = body
				$Attack.start()
	pass

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed

func _on_Attack_timeout():
	target.battle_action(damage, self)
	print("someone attacked")
		
func battle_action(dmg, attacker):
	current_health -= dmg
	if(current_health <= 0):
		attacker.inCombat = false
		attacker.get_node("Attack").stop()
		print("someone died")
		destroy()
		
func change_health (change):
	current_health += change
	if(current_health <= 0):
		print("i died")
		destroy()
	if(current_health > max_health):
		current_health = max_health


func destroy():
	queue_free()
