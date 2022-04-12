extends Node2D

var duration = 0
var slowEffect = 0.0
var allyBuff = 0.0
var pullBackChance = 0.0
var dealsDamage = false
var damage = 0.0
var towerFrom = null
var rampEffects = false
var slowingCap = 0
var rampSpeed = 0
var auraRange = 0
var inRange = []

var rng = RandomNumberGenerator.new()

var affectedEnemies = []
var affectedAllies = []

var rangePoints = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#initTestPolygon()
	if not rampEffects:
		$LifeTime.wait_time = duration
		$LifeTime.start()
	else:
		$"EffectArea/CollisionShape2D".shape.radius = auraRange


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass


func _on_LifeTime_timeout():
	if is_instance_valid(towerFrom):
		for i in towerFrom.centreOfField:
			if is_instance_valid(i[1]):
				if i[1] == self:
					towerFrom.centreOfField.remove(towerFrom.centreOfField.find(i))
	queue_free()

func _on_Area2D_body_entered(body):
	if is_instance_valid(body):
		if not body in inRange:
			inRange.append(body)
		var apply = body
		var pullBack = false
		for i in apply.pullingBack:
			if is_instance_valid(i[0]):
				if i[0] == self:
					pullBack = i[1]
		if not pullBack:
			if "Enemies" in apply.get_groups():
				var registered = false
				for i in affectedEnemies:
					if i[0] == apply:
						registered = true
				var speedDecrease = apply.max_speed * slowEffect
				apply.max_speed -= speedDecrease
				if not apply.stunned:
					apply.current_speed -= speedDecrease
				if apply.max_speed < apply.min_speed:
					speedDecrease -= apply.min_speed - apply.max_speed
					apply.max_speed = apply.min_speed
					if not apply.stunned:
						apply.current_speed = apply.min_speed
				if not registered:
					affectedEnemies.append([apply, speedDecrease, true, apply.max_speed + speedDecrease, 0])
					apply.pullingBack.append([self, false])
				else:
					for i in affectedEnemies:
						if i[0] == apply:
							i[1] = speedDecrease
							i[2] = true
			if "Morsels" in apply.get_groups():
				var healthIncrease = apply.max_health * allyBuff
				var speedIncrease = apply.max_speed * allyBuff
				var damageIncrease = apply.damage * allyBuff
				var registered = false
				for i in affectedAllies:
					if i[0] == apply:
						registered = true
				apply.max_health += healthIncrease
				apply.current_health += healthIncrease
				apply.max_speed += speedIncrease
				if not apply.stunned:
					apply.current_speed += speedIncrease
				apply.damage += damageIncrease
				if not registered:
					affectedAllies.append([apply, healthIncrease, speedIncrease, damageIncrease])
				else:
					for i in affectedAllies:
						if i[0] == apply:
							affectedAllies[1] = healthIncrease
							affectedAllies[2] = speedIncrease
							affectedAllies[3] = damageIncrease
				
func _on_Area2D_body_exited(body):
	if is_instance_valid(body):
		if body in inRange:
			inRange.remove(inRange.find(body))
		var apply = body
		var pullBack
		for i in apply.pullingBack:
			if is_instance_valid(i[0]):
				if i[0] == self:
					pullBack = i[1]
		if not pullBack:
			if "Enemies" in apply.get_groups():
				for i in affectedEnemies:
					if i[0] == apply:
						#print("*******")
						#print("slowed speed: " + String(apply.max_speed))
						apply.max_speed += i[1]
						#print("Buffed speed: " + String(apply.max_speed))
						#print("Old speed: " + String(i[3]))
						#print("********")
						if not apply.stunned:
							apply.current_speed += i[1]
				var pullRoll = rng.randf_range(0.01, 1.00)
				if(pullRoll <= pullBackChance):
					for i in apply.pullingBack:
						if is_instance_valid(i[0]):
							if i[0] == self:
								i[1] = true
					apply.tempMaxSpeed = apply.max_speed
					apply.tempSpeed = apply.current_speed
					apply.max_speed = -100
					apply.current_speed = -100
				for i in affectedEnemies:
					if is_instance_valid(i[0]):
						if i[0] == apply:
							i[2] = false
			if "Morsels" in apply.get_groups():
				for i in affectedAllies:
					if i[0] == apply:
						apply.max_health -= i[1]
						apply.change_health(-i[1], true)
						apply.max_speed -= i[2]
						if not apply.stunned:
							apply.current_speed -= i[2]
						apply.damage -= i[3]
		else:
			apply.max_speed = apply.tempMaxSpeed
			apply.current_speed = apply.tempSpeed
			for i in apply.pullingBack:
				if is_instance_valid(i[0]):
					if i[0] == self:
						i[1] = false
			for i in affectedEnemies:
				if is_instance_valid(i[0]):
					if i[0] == apply:
						i[2] = false

func _on_DamageFrequency_timeout():
	for i in affectedEnemies:
		if is_instance_valid(i[0]):
			if i[2] == true:
				i[0].change_health(-damage, false, true)
	for i in affectedAllies:
		if is_instance_valid(i[0]):
			i[0].change_health(0)
			
func initTestPolygon():
	for i in range(721):
		rangePoints.append(Vector2(cos(deg2rad(i/2)), sin(deg2rad(i/2))))
	for i in range(721):
		rangePoints[i].x *= $"EffectArea/CollisionShape2D".shape.radius
		rangePoints[i].y *= $"EffectArea/CollisionShape2D".shape.radius
	$Polygon2D.set_polygon(rangePoints)
	$Polygon2D.set_color(Color(1, 0.65, 0, 0.25))


func _on_RampTimer_timeout():
	for i in affectedEnemies:
		if is_instance_valid(i[0]):
			if i[4] < slowingCap:
				i[0].max_speed -= i[3] * rampSpeed
				if not i[0].stunned:
					i[0].current_speed -= i[3] * rampSpeed
				i[1] += i[3] * rampSpeed
				if i[0].max_speed < i[0].min_speed:
					i[1] -= i[0].min_speed - i[0].max_speed
					i[0].max_speed = i[0].min_speed
					if not i[0].stunned:
						i[0].current_speed = i[0].min_speed
				i[4] += rampSpeed
