extends Node2D

var AOE_percent = 0.0
var rng = RandomNumberGenerator.new()
var target = null
export var speed = 20
export var damage = 2.0
export var damageCap = -1.000
export var stun = false
export var explosive = false
export var field = false
export var piercing = false
export var dot_dmg = false
var ratatouille = false
var stun_chance = 0.15
var stun_duration = 0.75
var enemies = []
var towerFrom
var current_enemies_in_range = []
#EffectField Variables
var duration
var slowEffect
var allyBuff
var pullBackChance
var DOTDamage
var hit_enemies = []
export(PackedScene) var effectField
# Called when the node enters the scene tree for the first time.
func _ready():
	speed *= util.g_speed
	rng.randomize()
	if field:
		initTowerStats()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move towards target (closest enemy)
	if is_instance_valid(target):
		var direction = (target.global_position - self.global_position).normalized()
		position += direction * speed * delta
	else:
		queue_free()

func _on_Area2D_body_entered(body):
	if is_instance_valid(target):
		if(body == target):
			var targeted_enemy = null
			if(ratatouille):
				hit_enemies.append(target)
				if(current_enemies_in_range.size() > 0):
					for i in range(current_enemies_in_range.size()):
						var lowest = 1000
						var index = -1
						var distance = sqrt(pow((current_enemies_in_range[i].get_global_position().x - self.get_global_position().x), 2) + pow((current_enemies_in_range[i].get_global_position().y - self.get_global_position().y), 2))
						if(distance < lowest and not current_enemies_in_range[i] in hit_enemies):
							lowest = distance
							index = i
						if not (index == -1):
							targeted_enemy = current_enemies_in_range[i]
						else:
							targeted_enemy = null
				else:
					targeted_enemy = null
				if targeted_enemy != null:
					hit_enemies.append(targeted_enemy)
					
			if dot_dmg:
				body.dot_dmg_start()
			if piercing:
				target.change_health(-1 * damage, false, true)
			else:
				target.change_health(-1 * damage)
			var pullBack
			for i in target.pullingBack:
				if i[1] == true:
					pullBack = true
			if stun and not pullBack:
				var my_random_number = rng.randf_range(0.00, 1.00)
				if my_random_number <= stun_chance:
					target.start_stun(stun_duration)
			if explosive:
				for enemy in enemies:
					if not (enemy == target):
						enemy.change_health(-1 * (damage * AOE_percent))
			if field:
				var initField = effectField.instance()
				initField.position = position
				initFieldStats(initField)
				get_parent().add_child(initField)
				if is_instance_valid(towerFrom):
					towerFrom.centreOfField.append([target.get_offset(), initField])
			if ratatouille:
				if targeted_enemy != null:
					damage += 0.2
					target = targeted_enemy
				else:
					queue_free()
			else:
				queue_free()
	else:
		queue_free()

func initTowerStats():
	duration = towerFrom.duration
	slowEffect = towerFrom.slowEffect
	allyBuff = towerFrom.allyBuff
	pullBackChance = towerFrom.pullBackChance
	DOTDamage = towerFrom.DOTDamage
func initFieldStats(initField):
	if is_instance_valid(towerFrom):
		initField.towerFrom = towerFrom
	initField.duration = duration
	initField.slowEffect = slowEffect
	initField.allyBuff = allyBuff
	initField.pullBackChance = pullBackChance
	initField.damage = DOTDamage


func _on_AOE2D_body_entered(body):
	if(body.is_in_group("Enemies")):
		enemies.append(body)


func _on_AOE2D_body_exited(body):
	if(body.is_in_group("Enemies")):
		enemies.remove(enemies.find(body))


func _on_RatRange_body_entered(body):
	if body.is_in_group("Enemies"):
		current_enemies_in_range.append(body)


func _on_RatRange_body_exited(body):
	if body.is_in_group("Enemies"):
		current_enemies_in_range.remove(current_enemies_in_range.find(body))
