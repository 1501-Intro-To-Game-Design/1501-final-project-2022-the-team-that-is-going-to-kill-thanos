extends RigidBody2D

export var groups_to_check = []
export var max_health = 10
var current_health = 1
export var damage = 2
export var attackSpeed = 2
var inCombat = false
var target
export (PackedScene) var resource

#MOVING STUFF
var velocity = Vector2.ZERO
var destination = Vector2.ZERO
var direction = Vector2.ZERO
export var max_speed = 50
var current_speed = 0
var moving = false;

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
	if moving and abs((destination - position).x) < 1 and abs((destination - position).y) < 1: #if youve arived
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
				if body.inCombat:
					if body.target == self:
						inCombat = true
						target = body
						$Attack.start()
				else:
					inCombat = true
					target = body
					$Attack.start()
	pass

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed

func _on_Attack_timeout():
	if is_instance_valid(target):
		target.battle_action(damage, self)
			
func battle_action(dmg, attacker):
	if(current_health - dmg <= 0):
		attacker.inCombat = false
		attacker.get_node("Attack").stop()
	change_health(-1 * dmg)
		
func change_health(change):
	current_health += change
	$Health.value = current_health
	if(current_health <= 0):
		destroy()
	if(current_health > max_health):
		current_health = max_health


func destroy():
	var r = resource.instance()
	if is_in_group("Enemies"):
		r._spawn(true, global_position) # true = wood, false = metal
		get_parent().add_child(r)
	queue_free()
