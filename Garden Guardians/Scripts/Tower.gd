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
export(PackedScene) var combination_scene
var tower = 0 #defult

#SOUND STUFF
export (Array, Resource) var sounds
var rng = RandomNumberGenerator.new()

var morselPositions = [false, false, false, false]

var combinable = true
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
	$SpawnCooldown.start(spawn_cooldown)
	print($SpawnCooldown.time_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#detect closest enemy, and call attack function on it
	if dragging and is_instance_valid(comb_node) and not (mouse_pos == null):
		drag()
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
					$AttackCooldown.start(attack_cooldown)
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
	rng.randomize()
	$AudioStreamPlayer2D.stream = sounds[rng.randf_range(0,sounds.size())] #picks radom sound and plays it
	$AudioStreamPlayer2D.play()
	projectile.position = $ShootPoint.get_global_position()
	projectile.target = enemy

func drag():
	comb_node.position = mouse_pos

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseMotion and dragging:
		mouse_pos = event.position
	elif event is InputEventMouseButton: 
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
