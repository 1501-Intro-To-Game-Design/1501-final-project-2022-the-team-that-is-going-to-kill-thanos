extends Node2D

var enemies = []
var babies = 0
export var max_babies = 3

var can_attack = false
var can_spawn = false
export var attack_cooldown = 1
export var spawn_cooldown = 1

export var attacking_tower = false
export var morsel_tower = false
var rank = 0; #1-3 normal, 4 offshoot, 5 super duper tower

export(PackedScene) var projectileScene
export(PackedScene) var morsalScene
var tower = 0 #defult

#this holds all info about the towers, format is [tower family (0-3 is fruits, 4-8 is morsals, etc )][INFO]
#list false or 0 or null as aproperite when not relivent (itll get ignored anyways)
#LEGEND: A-attacking M-morsel T-Tower P-Projectile
# each tower holds the following info in order [AT?, MT?, ACooldown, PDamage, PSpeed, PSprite, MspawnCooldown, MMaxBabies, MHealth, MDamage, MSpeed, MAttackSpeed, MSprite] (13 things, 0-12)



# Called when the node enters the scene tree for the first time.

func _ready():
	$SpawnCooldown.start(spawn_cooldown)
	print($SpawnCooldown.time_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
					$AttackCooldown.start()
					attack(enemies[index])
	if(morsel_tower):
		if can_spawn and (babies < max_babies):
			make_Baby()
			babies += 1
			$SpawnCooldown.start(spawn_cooldown)
			can_spawn = false
		#do morsel spawning stuff, if can_spawn is true, that is when the cooldown has passed (can spawn new morsels)
				
func attack(enemy):
	#spawn a projectile at shootPoint, and set projectile's target to closest enemy
	var projectile = projectileScene.instance()
	get_parent().add_child(projectile)
	projectile.position = $ShootPoint.get_global_position()
	projectile.target = enemy

func make_Baby():
	var morsel = morsalScene.instance()
	get_parent().add_child(morsel)
	
	if(babies == 0):
		morsel.position = $ShootPoint.get_global_position() + Vector2(-10, -15) #in the future replace this with (go to the neerest point on the path)
	elif(babies == 1):
		morsel.position = $ShootPoint.get_global_position() + Vector2(0, -10) #in the future replace this with (go to the neerest point on the path)
	elif(babies == 2):
		morsel.position = $ShootPoint.get_global_position() + Vector2(10, -10) #in the future replace this with (go to the neerest point on the path)
	elif(babies == 3):
		morsel.position = $ShootPoint.get_global_position() + Vector2(-10, -5) #in the future replace this with (go to the neerest point on the path)
	

func _on_Range_area_entered(area):
	if(area.get_parent().is_in_group("Enemies")):
		enemies.append(area)


func _on_Cooldown_timeout(): #for attack timer
	can_attack = true


func _on_Range_area_exited(area):
	if(area.get_parent().is_in_group("Enemies")):
		enemies.remove(enemies.find(area))


func _on_SpawnCooldown_timeout():
	can_spawn = true
