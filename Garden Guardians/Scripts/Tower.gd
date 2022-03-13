extends Node2D

var enemies = []
var can_attack = false
var can_spawn = false
export var attack_cooldown = 1
export var spawn_cooldown = 1
export var attacking_tower = true
export var morself_tower = false

export(PackedScene) var projectileScene


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AttackCooldown.wait_time = attack_cooldown
	$SpawnCooldown.wait_time = spawn_cooldown


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#detect closest enemy, and call attack function on it
	if(attacking_tower):
		if enemies.size() > 0:
			var lowest = 1000
			var index = -1
			for i in range(0, enemies.size()):
				var distance = sqrt(pow((enemies[i].get_global_position().x - self.get_global_position().x), 2) + pow((enemies[i].get_global_position().y - self.get_global_position().y), 2))
				if(distance < lowest):
					lowest = distance
					index = i
			if not (index == -1):
				if(can_attack):
					can_attack = false
					$AttackCooldown.wait_time = attack_cooldown
					attack(enemies[index])
	if(morself_tower):
		pass
		can_spawn = false
		#do morself spawning stuff, if can_spawn is true, that is when the cooldown has passed (can spawn new morsels)
				
func attack(enemy):
	#spawn a projectile at shootPoint, and set projectile's target to closest enemy
	var projectile = projectileScene.instance()
	get_parent().add_child(projectile)
	projectile.position = $ShootPoint.get_global_position()
	projectile.target = enemy

func _on_Range_area_entered(area):
	if(area.is_in_group("Enemies")):
		enemies.append(area)


func _on_Cooldown_timeout():
	can_attack = true


func _on_Range_area_exited(area):
	if(area.is_in_group("Enemies")):
		enemies.remove(enemies.find(area))


func _on_SpawnCooldown_timeout():
	can_spawn = true
