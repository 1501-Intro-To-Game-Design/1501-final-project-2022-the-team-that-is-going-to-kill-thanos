extends RigidBody2D

export var health = 10
export var damage = 2
export var speed = 50
export var attackSpeed = 2
var inCombat = false
var morselFighting

# Called when the node enters the scene tree for the first time.
func _ready():
	prepareAttackTimer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkInCombat()

func checkInCombat():
	if inCombat:
		speed = 0
	else:
		speed = 50

func _on_Enemy_body_entered(body):
	checkType(body)

func checkType(body):
	for group in body.get_groups():
		if group == "Traps":
			body.applyEffects($Enemy)
		if group == "Morsels":
			if !inCombat:
				inCombat = true
				morselFighting = body
				$Attack.start()
	pass

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed

func _on_Attack_timeout():
	morselFighting.health -= damage
	if (morselFighting.health <= 0):
		inCombat = false
		$Attack.stop()
		morselFighting.destroy()

func destroy():
	queue_free()
