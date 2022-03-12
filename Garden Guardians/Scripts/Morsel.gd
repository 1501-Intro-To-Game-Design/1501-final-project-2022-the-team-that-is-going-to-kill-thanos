extends RigidBody2D

export var health = 10
export var damage = 2
export var speed = 50
export var attackSpeed = 3
var inCombat = false
var enemyFighting


# Called when the node enters the scene tree for the first time.
func _ready():
	prepareAttackTimer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkInCombat()

func prepareAttackTimer():
	$Attack.wait_time = attackSpeed

func checkInCombat():
	if inCombat:
		speed = 0
	else:
		speed = 50


func _on_Area2D_body_entered(body):
	checkType(body)

func checkType(body):
	for group in body.get_groups():
		if group == "Enemies":
			if !inCombat:
				inCombat = true
				enemyFighting = body
				$Attack.start()
	pass

func _on_Attack_timeout():
	enemyFighting.health -= damage
	if (enemyFighting.health <= 0):
		inCombat = false
		$Attack.stop()
		enemyFighting.destroy()

func destroy():
	queue_free()
