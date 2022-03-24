extends Node2D

var explosive = false
var stun_chance = 0.15
var stun_duration = 0.4
var target_type = "closest"

var num_projectiles = 1

var enemies = []
var babies = 0
export var max_babies = 3
var AOE_percent = 0.0

var can_attack = false
var can_spawn = false
export var attack_cooldown = 1.0
export var spawn_cooldown = 1.0

var targeted_enemies = []

export var attacking_tower = false
export var morsel_tower = false

var rank = 0; #1-3 normal, 4 offshoot, 5 super duper tower

export(PackedScene) var projectileScene
export(PackedScene) var morsalScene
var combination_scene = load("res://Scenes/CombinationNode.tscn")
export(PackedScene) var upgrade
export(PackedScene) var offshoot_upgrade
var tower = 0 #defult

#SOUND STUFF
export (Array, Resource) var sounds
var rng = RandomNumberGenerator.new()

var morselPositions = [false, false, false, false]

export var combinable = false
var dragging = false
var plate = null

var mouse_pos = null
var comb_node = null

var hovering = false

#this holds all info about the towers, format is [tower family (0-3 is fruits, 4-8 is morsals, etc )][INFO]
#list false or 0 or null as aproperite when not relivent (itll get ignored anyways)
#LEGEND: A-attacking M-morsel T-Tower P-Projectile
# each tower holds the following info in order [AT?, MT?, ACooldown, PDamage, PSpeed, PSprite, MspawnCooldown, MMaxBabies, MHealth, MDamage, MSpeed, MAttackSpeed, MSprite] (13 things, 0-12)



# Called when the node enters the scene tree for the first time.
func getstuff():
	return 5
func _ready():
	rng.randomize()
	$SpawnCooldown.start(spawn_cooldown)

func set_target_type(new_target_type): #can be: closest, farthest, lowest, highest, closest_end, closest_start
	target_type = new_target_type
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#detect closest enemy, and call attack function on it
	if dragging and is_instance_valid(comb_node) and not (mouse_pos == null):
		drag()
	if(attacking_tower and can_attack):
		if enemies.size() > 0:
			while(num_projectiles > targeted_enemies.size()):
				if(target_type == "closest"):
					var lowest = 1000
					var index = -1
					for i in range(0, enemies.size()):
						var distance = sqrt(pow((enemies[i].get_global_position().x - $ShootPoint.get_global_position().x), 2) + pow((enemies[i].get_global_position().y - $ShootPoint.get_global_position().y), 2))
						if(distance < lowest and not (enemies[i] in targeted_enemies)):
							lowest = distance
							index = i
					if not (index == -1):
						targeted_enemies.append(enemies[index])
					else:
						targeted_enemies.append(null)
				elif(target_type == "farthest"):
					var highest = 0
					var index = -1
					for i in range(0, enemies.size()):
						var distance = sqrt(pow((enemies[i].get_global_position().x - $ShootPoint.get_global_position().x), 2) + pow((enemies[i].get_global_position().y - $ShootPoint.get_global_position().y), 2))
						if(distance > highest and not (enemies[i] in targeted_enemies)):
							highest = distance
							index = i
					if not (index == -1):
						targeted_enemies.append(enemies[index])
					else:
						targeted_enemies.append(null)
				elif(target_type == "lowest"):
					var index = -1
					var lowest = 1000
					for i in range(0, enemies.size()):
						if(enemies[i].get_parent().get_percent_health() < lowest and not (enemies[i] in targeted_enemies)):
							lowest = enemies[i].get_parent().get_percent_health()
							index = i
					if not (index == -1):
						targeted_enemies.append(enemies[index])
					else:
						targeted_enemies.append(null)
				elif(target_type == "highest"):
					var index = -1
					var highest = 0
					for i in range(0, enemies.size()):
						if(enemies[i].get_parent().get_percent_health() > highest and not (enemies[i] in targeted_enemies)):
							highest = enemies[i].get_parent().get_percent_health()
							index = i
					if not (index == -1):
						targeted_enemies.append(enemies[index])
					else:
						targeted_enemies.append(null)
				elif(target_type == "closest_end"):
					var index = -1
					var highest = 0
					for i in range(0, enemies.size()):
						if(enemies[i].get_parent().get_offset() > highest and not (enemies[i] in targeted_enemies)):
							highest = enemies[i].get_parent().get_offset()
							index = i
					if not (index == -1):
						targeted_enemies.append(enemies[index])
					else:
						targeted_enemies.append(null)
				elif(target_type == "closest_start"):
					var index = -1
					var lowest = 10000
					for i in range(0, enemies.size()):
						if(enemies[i].get_parent().get_offset() < lowest and not (enemies[i] in targeted_enemies)):
							lowest = enemies[i].get_parent().get_offset()
							index = i
					if not (index == -1):
						targeted_enemies.append(enemies[index])
					else:
						targeted_enemies.append(null)
			can_attack = false
			$AttackCooldown.start(attack_cooldown)
			for i in range(targeted_enemies.size()):
				attack(targeted_enemies[i])
			targeted_enemies.clear()
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
	projectile.explosive = explosive
	projectile.AOE_percent = AOE_percent
	projectile.stun_chance = stun_chance
	projectile.stun_duration = stun_duration
	rng.randomize()
	$AudioStreamPlayer2D.stream = sounds[rng.randf_range(0,sounds.size())] #picks radom sound and plays it
	$AudioStreamPlayer2D.play()
	projectile.position = $ShootPoint.get_global_position()
	projectile.target = enemy

func increase_range(amount):
	$Range/RangeShape.shape.radius += amount
	
func get_range():
	return $Range/RangeShape.shape.radius

func drag():
	comb_node.position = mouse_pos

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseMotion and combinable:
		mouse_pos = event.position
	elif event is InputEventMouseButton and combinable: 
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if hovering:
					dragging = true
					comb_node = combination_scene.instance()
					get_parent().add_child(comb_node)
					comb_node.get_node("Sprite").set_texture($Sprite.texture)
					comb_node.get_node("Sprite").scale = $Sprite.scale
					comb_node.tower_to_combine = self
			else:
				hovering = false
				if is_instance_valid(comb_node):
					var worked = comb_node.on_drag_end()
					comb_node.queue_free()
					if worked:
						plate.reset()
						queue_free()
				dragging = false
				mouse_pos = null

func make_Baby():
	var morsel = morsalScene.instance()
	morsel.homeTower = self
	get_parent().add_child(morsel)
	
	if(not morselPositions[0]): #Does this ever happen?
		morsel.position = $ShootPoint.get_global_position() + Vector2(-60, -15) #in the future replace this with (go to the neerest point on the path)
		morsel.morselNum = 0
		morselPositions[0] = true
	elif(not morselPositions[1]):
		morsel.position = $ShootPoint.get_global_position() + Vector2(-10, -10) #in the future replace this with (go to the neerest point on the path)
		morsel.morselNum = 1
		morselPositions[1] = true
	elif(not morselPositions[2]):
		morsel.position = $ShootPoint.get_global_position() + Vector2(40, -10) #in the future replace this with (go to the neerest point on the path)
		morsel.morselNum = 2
		morselPositions[2] = true
	elif(not morselPositions[3]):
		morsel.position = $ShootPoint.get_global_position() + Vector2(90, -5) #in the future replace this with (go to the neerest point on the path)
		morsel.morselNum = 3
		morselPositions[3] = true
	

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


func _on_Area2D_mouse_entered():
	hovering = true


func _on_Area2D_mouse_exited():
	hovering = false
