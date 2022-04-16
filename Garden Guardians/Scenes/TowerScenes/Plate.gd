extends Node2D

var tower = null #tower will be the tower assigned to this plate (needed for upgrading)
var player_in_range = false
var target_types = ["closest", "farthest", "lowest", "highest", "closest_end", "closest_start"]
var target_index = 4
var in_area = false
var combining_tower = null
export (PackedScene) var x_scene
export (PackedScene) var vegetable_scene
export (PackedScene) var fruit_scene
export (PackedScene) var protein_scene
export (PackedScene) var dairy_scene
export (PackedScene) var grain_scene
export (Texture) var new_cherry
export (Texture) var normal_plate
export (Texture) var hover_plate

var spawned_x = []

export (Resource) var upgradeSound
export (Resource) var refundSound
export (Resource) var combinationSound

var current_menu
var moveMode = false
var clicked = false
#COSTS// each new element after the first is the cost of the upgrade -- 1, 2, 3, offshoot, upgrade1, up2, up3
var vegW = [] #SC, SD, ACD
var vegM = []
var fruitW = [] #EC, AR, AOE
var fruitM = []
var grainW = [] #TEMP TD, DOT, PB
var grainM = []
var dairyW = [] #TEMP PDP, PC, SE
var dairyM = []
var proW = [] #AttackSpeed, Damage, ExtraUnit
var proM = []

# Called when the node enters the scene tree for the first time.
func _ready():
	current_menu = $TowerMenu
	target_index = 4
	$Target/Text.text = "Closest to End"
	vegW = [round(9 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(13 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(18 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(14 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(7 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(9 * get_parent().get_node("MovingEnemies").difficulty_multiplier), 0] #SC, SD, ACD
	vegM = [round(2 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(3 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(4 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(7 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(2 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(2 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(5 * get_parent().get_node("MovingEnemies").difficulty_multiplier)]
	fruitW = [round(12 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(20 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(25 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(20 * get_parent().get_node("MovingEnemies").difficulty_multiplier), 0, round(23 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(8 * get_parent().get_node("MovingEnemies").difficulty_multiplier)] #EC, AR, AOE
	fruitM = [0, 0, 0, round(5 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier), 0, round(4 * get_parent().get_node("MovingEnemies").difficulty_multiplier)]
	grainW = [round(4 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(9 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(16 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(14 * get_parent().get_node("MovingEnemies").difficulty_multiplier), 0, round(24 * get_parent().get_node("MovingEnemies").difficulty_multiplier)] #TEMP TD, DOT, PB
	grainM = [round(3 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(3 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(3 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(7 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(2 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(6 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(1 * get_parent().get_node("MovingEnemies").difficulty_multiplier)]
	dairyW = [round(11 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(18 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(24 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier), 0, round(6 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier)] #TEMP PDP, PC, SE
	dairyM = [round(7 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(15 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(17 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(12 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(4 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(1 * get_parent().get_node("MovingEnemies").difficulty_multiplier)]
	proW = [0, 0, 0, round(12 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(6 * get_parent().get_node("MovingEnemies").difficulty_multiplier), 0, round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier)] #AttackSpeed, Damage, ExtraUnit
	proM = [round(4 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(6 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(9 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(6 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(1 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(3 * get_parent().get_node("MovingEnemies").difficulty_multiplier), round(10 * get_parent().get_node("MovingEnemies").difficulty_multiplier)]
	for num in vegW:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in vegM:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in fruitW:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in fruitM:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in grainW:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in grainM:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in dairyW:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in dairyM:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in proW:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	for num in proM:
		num = round(num * get_parent().get_node("MovingEnemies").difficulty_multiplier)
	
	#Sets
	$Text/Turnip/NinePatchRect/WoodCost.text = String(vegW[0])
	$Text/Turnip/NinePatchRect/MetalCost.text = String(vegM[0])
	$Text/Onion/NinePatchRect/WoodCost.text = String(vegW[1])
	$Text/Onion/NinePatchRect/MetalCost.text = String(vegM[1])
	$Text/Potato/NinePatchRect/WoodCost.text = String(vegW[2])
	$Text/Potato/NinePatchRect/MetalCost.text = String(vegM[2])
	$Text/Carrot/NinePatchRect/WoodCost.text = String(vegW[3])
	$Text/Carrot/NinePatchRect/MetalCost.text = String(vegM[3])
	$Text/CarrotSC/NinePatchRect/WoodCost.text = String(vegW[4])
	$Text/CarrotSC/NinePatchRect/MetalCost.text = String(vegM[4])
	$Text/CarrotSD/NinePatchRect/WoodCost.text = String(vegW[5])
	$Text/CarrotSD/NinePatchRect/MetalCost.text = String(vegM[5])
	$Text/CarrotACD/NinePatchRect/WoodCost.text = String(vegW[6])
	$Text/CarrotACD/NinePatchRect/MetalCost.text = String(vegM[6])

	$Text/Seed/NinePatchRect/WoodCost.text = String(fruitW[0])
	$Text/Seed/NinePatchRect/MetalCost.text = String(fruitM[0])
	$Text/Plum/NinePatchRect/WoodCost.text = String(fruitW[1])
	$Text/Plum/NinePatchRect/MetalCost.text = String(fruitM[1])
	$Text/Tomato/NinePatchRect/WoodCost.text = String(fruitW[2])
	$Text/Tomato/NinePatchRect/MetalCost.text = String(fruitM[2])
	$Text/Cherry/NinePatchRect/WoodCost.text = String(fruitW[3])
	$Text/Cherry/NinePatchRect/MetalCost.text = String(fruitM[3])
	$Text/CherryEC/NinePatchRect/WoodCost.text = String(fruitW[4])
	$Text/CherryEC/NinePatchRect/MetalCost.text = String(fruitM[4])
	$Text/CherryAR/NinePatchRect/WoodCost.text = String(fruitW[5])
	$Text/CherryAR/NinePatchRect/MetalCost.text = String(fruitM[5])
	$Text/CherryAOE/NinePatchRect/WoodCost.text = String(fruitW[6])
	$Text/CherryAOE/NinePatchRect/MetalCost.text = String(fruitM[6])
	
	$Text/MeatCube/NinePatchRect/WoodCost.text = String(proW[0])
	$Text/MeatCube/NinePatchRect/MetalCost.text = String(proM[0])
	$Text/Sausage/NinePatchRect/WoodCost.text = String(proW[1])
	$Text/Sausage/NinePatchRect/MetalCost.text = String(proM[1])
	$Text/Backribs/NinePatchRect/WoodCost.text = String(proW[2])
	$Text/Backribs/NinePatchRect/MetalCost.text = String(proM[2])
	$Text/NakedChicken/NinePatchRect/WoodCost.text = String(proW[3])
	$Text/NakedChicken/NinePatchRect/MetalCost.text = String(proM[3])
	$Text/NakedChickenAS/NinePatchRect/WoodCost.text = String(proW[4])
	$Text/NakedChickenAS/NinePatchRect/MetalCost.text = String(proM[4])
	$Text/NakedChickenAD/NinePatchRect/WoodCost.text = String(proW[5])
	$Text/NakedChickenAD/NinePatchRect/MetalCost.text = String(proM[5])
	$Text/NakedChickenUnit/NinePatchRect/WoodCost.text = String(proW[6])
	$Text/NakedChickenUnit/NinePatchRect/MetalCost.text = String(proM[6])
	
	$Text/Rice/NinePatchRect/WoodCost.text = String(grainW[0])
	$Text/Rice/NinePatchRect/MetalCost.text = String(grainM[0])
	$Text/Corn/NinePatchRect/WoodCost.text = String(grainW[1])
	$Text/Corn/NinePatchRect/MetalCost.text = String(grainM[1])
	$Text/Spaghetti/NinePatchRect/WoodCost.text = String(grainW[2])
	$Text/Spaghetti/NinePatchRect/MetalCost.text = String(grainM[2])
	$Text/Pretzel/NinePatchRect/WoodCost.text = String(grainW[3])
	$Text/Pretzel/NinePatchRect/MetalCost.text = String(grainM[3])
	$Text/PretzelTD/NinePatchRect/WoodCost.text = String(grainW[4])
	$Text/PretzelTD/NinePatchRect/MetalCost.text = String(grainM[4])
	$Text/PretzelDOT/NinePatchRect/WoodCost.text = String(grainW[5])
	$Text/PretzelDOT/NinePatchRect/MetalCost.text = String(grainM[5])
	$Text/PretzelPB/NinePatchRect/WoodCost.text = String(grainW[6])
	$Text/PretzelPB/NinePatchRect/MetalCost.text = String(grainM[6])

	$Text/Milk/NinePatchRect/WoodCost.text = String(dairyW[0])
	$Text/Milk/NinePatchRect/MetalCost.text = String(dairyM[0])
	$Text/Cream/NinePatchRect/WoodCost.text = String(dairyW[1])
	$Text/Cream/NinePatchRect/MetalCost.text = String(dairyM[1])
	$Text/Parmesan/NinePatchRect/WoodCost.text = String(dairyW[2])
	$Text/Parmesan/NinePatchRect/MetalCost.text = String(dairyM[2])
	$Text/Butter/NinePatchRect/WoodCost.text = String(dairyW[3])
	$Text/Butter/NinePatchRect/MetalCost.text = String(dairyM[3])
	$Text/ButterPDP/NinePatchRect/WoodCost.text = String(dairyW[4])
	$Text/ButterPDP/NinePatchRect/MetalCost.text = String(dairyM[4])
	$Text/ButterPC/NinePatchRect/WoodCost.text = String(dairyW[5])
	$Text/ButterPC/NinePatchRect/MetalCost.text = String(dairyM[5])
	$Text/ButterSE/NinePatchRect/WoodCost.text = String(dairyW[6])
	$Text/ButterSE/NinePatchRect/MetalCost.text = String(dairyM[6])
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.x < $TopLeft.global_position.x or mouse_pos.x > $TopRight.global_position.x or mouse_pos.y > $BotLeft.global_position.y or mouse_pos.y < $TopLeft.global_position.y:
		for x in spawned_x:
			if is_instance_valid(x):
				x.queue_free()
		if current_menu != null:
			current_menu.hide()
			$Sprite.texture = normal_plate
			$Target.hide()
			$Delete.hide()
			if tower != null and !moveMode:
				tower.show_range(false)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			current_menu.show()
			if not (tower == null):
				$Target.show()
				$Delete.show()
				tower.show_range(true)


func _on_VArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = make_tower("vegetable", -19)
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$VUpgradeMenu.show()
				current_menu = $VUpgradeMenu/V1
			else:
				x_animation($TowerMenu/Vegetable/VArea)

func make_tower(tower_type, y_spawn_offset):
	if tower_type == "vegetable" and vegW[0] <= ui.wood and vegM[0] <= ui.metal:
		ui.wood -= vegW[0]
		ui.metal -= vegM[0]
		ui.update()
		tower = vegetable_scene.instance()
		tower.refundW = 0.4*(vegW[0])
		tower.refundM = 0.4*(vegM[0])
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		upgrade()
		return true
	elif tower_type == "fruit" and fruitW[0] <= ui.wood and fruitM[0] <= ui.metal:
		ui.wood -= fruitW[0]
		ui.metal -= fruitM[0]
		ui.update()
		tower = fruit_scene.instance()
		tower.refundW = 0.4*(fruitW[0])
		tower.refundM = 0.4*(fruitM[0])
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		upgrade()
		return true
	elif tower_type == "grain" and grainW[0] <= ui.wood and grainM[0] <= ui.metal:
		ui.wood -= grainW[0]
		ui.metal -= grainM[0]
		ui.update()
		tower = grain_scene.instance()
		tower.refundW = 0.4*(grainW[0])
		tower.refundM = 0.4*(grainM[0])
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		upgrade()
		return true
	elif tower_type == "dairy" and dairyW[0] <= ui.wood and dairyM[0] <= ui.metal:
		ui.wood -= dairyW[0]
		ui.metal -= dairyM[0]
		ui.update()
		tower = dairy_scene.instance()
		tower.refundW = 0.4*(dairyW[0])
		tower.refundM = 0.4*(dairyM[0])
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		upgrade()
		return true
	elif tower_type == "protein" and proW[0] <= ui.wood and proM[0] <= ui.metal:
		ui.wood -= proW[0]
		ui.metal -= proM[0]
		ui.update()
		tower = protein_scene.instance()
		tower.refundW = 0.4*(proW[0])
		tower.refundM = 0.4*(proM[0])
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		upgrade()
		return true
	else:
		ui.failedAction()
	return false
	
func simple_make_tower(tower_to_make, wood_cost, metal_cost, y_spawn_off = 0, upgrade_sound = true): #simpler than above?
	if(ui.wood >= wood_cost and ui.metal >= metal_cost and not (tower_to_make == null)):
		if upgrade_sound:
			upgrade()
		ui.wood -= wood_cost
		ui.metal -= metal_cost
		ui.update()
		var tempW = tower.refundW
		var tempM = tower.refundM
		var towerT = tower_to_make.instance()
		var tempPos
		if towerT.morsel_tower:
			if combining_tower != null:
				if combining_tower.tower_morsels.size() > 0:
					tempPos = combining_tower.tower_morsels[0].position - combining_tower.morselOffsets[0] - combining_tower.position
				else:
					tempPos =  Vector2.ZERO
				combining_tower = null
			else:
				if tower.tower_morsels.size() > 0:
					tempPos = tower.tower_morsels[0].position - tower.morselOffsets[0] - tower.position
				else:
					tempPos = Vector2.ZERO
		tower.queue_free()
		tower = towerT
		tower.refundW = tempW + (0.4 * wood_cost)
		tower.refundM = tempM + (0.4 * metal_cost)
		get_parent().add_child(tower)
		if tower.morsel_tower:
			tower.posOffset = tempPos
		tower.position = self.get_global_position() + Vector2(0, y_spawn_off)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		return true
	else:
		ui.failedAction()
	return false
	
func buy_something(wood_cost, metal_cost):
	if(ui.wood >= wood_cost and ui.metal >= metal_cost):
		upgrade()
		ui.wood -= wood_cost
		ui.metal -= metal_cost
		ui.update()
		return true
	else:
		ui.failedAction()
	return false
		

func reset(): #only gets
	current_menu = $TowerMenu
	tower = null

func combines():
	$AudioStreamPlayer.volume_db = 3 + util.g_sound
	$AudioStreamPlayer.stream = combinationSound
	$AudioStreamPlayer.play()

func upgrade():
	$AudioStreamPlayer.stream = upgradeSound
	$AudioStreamPlayer.play()


func _on_PArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = make_tower("protein", -40)
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$PUpgradeMenu.show()
				current_menu = $PUpgradeMenu/P1
			else:
				x_animation($TowerMenu/Protein/PArea)

func x_animation(obj):
	var new_x = x_scene.instance()
	get_parent().add_child(new_x)
	spawned_x.append(new_x)
	new_x.global_position = obj.global_position
	new_x.get_node("AnimationPlayer").play("Failed")
	var t = Timer.new()
	t.set_wait_time(1.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	if(is_instance_valid(new_x)):
		spawned_x.remove(spawned_x.find(new_x))
		new_x.queue_free()

func _on_VArea1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, vegW[1], vegM[1], -25) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $VUpgradeMenu/V2
			else:
				x_animation($VUpgradeMenu/V1/VArea1)


func _on_VAreaCarrot_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.offshoot_upgrade, vegW[3], vegM[3], -42) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $VUpgradeMenu/Carrot
			else:
				x_animation($VUpgradeMenu/V2/VAreaCarrot)


func _on_VAreaPotato_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, vegW[2], vegM[2], -28) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $VUpgradeMenu/Potato
			else:
				x_animation($VUpgradeMenu/V2/VAreaPotato)


func _on_VAreaSC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(vegW[4], vegM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.stun_chance += 0.2
				if tower.stun_chance > .70:
					$VUpgradeMenu/Carrot/VAreaSC.hide()
					$VUpgradeMenu/Carrot/OptionSC.hide() #could also change this to change sprite
			else:
				x_animation($VUpgradeMenu/Carrot/VAreaSC)
				


func _on_VAreaSD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(vegW[5], vegM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.stun_duration += 0.25
				if tower.stun_duration > 1.40:
					$VUpgradeMenu/Carrot/VAreaSD.hide()
					$VUpgradeMenu/Carrot/OptionSD.hide() #could also change this to change sprite
			else:
				x_animation($VUpgradeMenu/Carrot/VAreaSD)


func _on_VAreaACD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(vegW[6], vegM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.attack_cooldown -= (0.5/util.g_speed)
				if tower.attack_cooldown < (3.1/util.g_speed):
					$VUpgradeMenu/Carrot/VAreaACD.hide()
					$VUpgradeMenu/Carrot/OptionACD.hide() #could also change this to change sprite
			else:
				x_animation($VUpgradeMenu/Carrot/VAreaACD)


func _on_VAreaF1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, fruitW[1], fruitM[1], -80) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $FUpgradeMenu/F2
			else:
				x_animation($FUpgradeMenu/F1/VAreaF1)


func _on_VAreaTomato_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, fruitW[2], fruitM[2], -68) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $FUpgradeMenu/Tomato
			else:
				x_animation($FUpgradeMenu/F2/VAreaTomato)


func _on_VAreaCherry_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.offshoot_upgrade, fruitW[3], fruitM[3], -79) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.num_projectiles += 1
				current_menu = $FUpgradeMenu/Cherry
			else:
				x_animation($FUpgradeMenu/F2/VAreaCherry)


func _on_VAreaEC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(fruitW[4], fruitM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.num_projectiles += 1
				tower.get_node("Sprite").texture = new_cherry
				if tower.num_projectiles > 2:
					$FUpgradeMenu/Cherry/VAreaEC.hide()
					$FUpgradeMenu/Cherry/OptionEC.hide() #could also change this to change sprite
			else:
				x_animation($FUpgradeMenu/Cherry/VAreaEC)


func _on_VAreaAR_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(fruitW[5], fruitM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.increase_range(20) #change this
				#tower.initializeRangePolygon()
				if tower.get_range() > 299:
					$FUpgradeMenu/Cherry/VAreaAR.hide()
					$FUpgradeMenu/Cherry/OptionAR.hide() #could also change this to change sprite
			else:
				x_animation($FUpgradeMenu/Cherry/VAreaAR)


func _on_VAreaAOE_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(fruitW[6], fruitM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.explosive = true
				tower.AOE_percent += 0.1 #change this
				if tower.AOE_percent > 0.25:
					$FUpgradeMenu/Cherry/VAreaAOE.hide()
					$FUpgradeMenu/Cherry/OptionAOE.hide() #could also change this to change sprite
			else:
				x_animation($FUpgradeMenu/Cherry/VAreaAOE)


func _on_FArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = make_tower("fruit", -80)
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$FUpgradeMenu.show()
				current_menu = $FUpgradeMenu/F1
			else:
				x_animation($TowerMenu/Fruit/FArea)


func _on_VArea_mouse_entered():
	$Text/Turnip.show()


func _on_VArea_mouse_exited():
	$Text/Turnip.hide()


func _on_FArea_mouse_entered():
	$Text/Seed.show()


func _on_FArea_mouse_exited():
	$Text/Seed.hide()


func _on_VArea1_mouse_entered():
	$Text/Onion.show()


func _on_VArea1_mouse_exited():
	$Text/Onion.hide()


func _on_VAreaPotato_mouse_entered():
	$Text/Potato.show()


func _on_VAreaCarrot_mouse_entered():
	$Text/Carrot.show()


func _on_VAreaPotato_mouse_exited():
	$Text/Potato.hide()


func _on_VAreaCarrot_mouse_exited():
	$Text/Carrot.hide()


func _on_VAreaSC_mouse_entered():
	$Text/CarrotSC.show()


func _on_VAreaSC_mouse_exited():
	$Text/CarrotSC.hide()


func _on_VAreaSD_mouse_entered():
	$Text/CarrotSD.show()


func _on_VAreaSD_mouse_exited():
	$Text/CarrotSD.hide()


func _on_VAreaACD_mouse_entered():
	$Text/CarrotACD.show()


func _on_VAreaACD_mouse_exited():
	$Text/CarrotACD.hide()


func _on_VAreaF1_mouse_entered():
	$Text/Plum.show()


func _on_VAreaF1_mouse_exited():
	$Text/Plum.hide()


func _on_VAreaTomato_mouse_entered():
	$Text/Tomato.show()


func _on_VAreaTomato_mouse_exited():
	$Text/Tomato.hide()


func _on_VAreaCherry_mouse_entered():
	$Text/Cherry.show()


func _on_VAreaCherry_mouse_exited():
	$Text/Cherry.hide()


func _on_VAreaEC_mouse_entered():
	$Text/CherryEC.show()


func _on_VAreaEC_mouse_exited():
	$Text/CherryEC.hide()


func _on_VAreaAR_mouse_entered():
	$Text/CherryAR.show()


func _on_VAreaAR_mouse_exited():
	$Text/CherryAR.hide()


func _on_VAreaAOE_mouse_entered():
	$Text/CherryAOE.show()


func _on_VAreaAOE_mouse_exited():
	$Text/CherryAOE.hide()

func _on_BigArea_mouse_exited():
	pass
	#if not(in_area):
		#if spawned_x.size() > 0:
			#for x in spawned_x:
				#x.queue_free()
			#spawned_x.clear()
		#if current_menu != null:
			#current_menu.hide()
			#$Sprite.texture = normal_plate
			#$Target.hide()
			#$Delete.hide()
			#if tower != null and !moveMode:
				#tower.show_range(false)

func make_rib_plate(new_tower):
	combining_tower = new_tower
	$PUpgradeMenu.show()
	current_menu = $PUpgradeMenu/Backribs

func _on_Text_mouse_entered():
	in_area = true


func _on_Text_mouse_exited():
	in_area = false


func _on_Text_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			if event.pressed == util.on_desktop:
				target_index += 1
				if target_index >= target_types.size():
					target_index = 0
				if target_types[target_index] == "closest":
					$Target/Text.text = "Closest to Tower"
				if target_types[target_index] == "farthest":
					$Target/Text.text = "Farthest to Tower"
				if target_types[target_index] == "lowest":
					$Target/Text.text = "Lowest % Health"
				if target_types[target_index] == "highest":
					$Target/Text.text = "Highest % Health"
				if target_types[target_index] == "closest_end":
					$Target/Text.text = "Closest to End"
				if target_types[target_index] == "closest_start":
					$Target/Text.text = "Closest to Start"
				tower.set_target_type(target_types[target_index])


func _on_VAreaP1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, proW[1], proM[1], -23) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $PUpgradeMenu/P2
			else:
				x_animation($PUpgradeMenu/P1/VAreaP1)


func _on_VAreaBackribs_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, proW[2], proM[2], -23) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $PUpgradeMenu/Backribs
			else:
				x_animation($PUpgradeMenu/P2/VAreaBackribs)


func _on_VAreaNakedChicken_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.offshoot_upgrade, proW[3], proM[3], -45) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				current_menu = $PUpgradeMenu/NakedChicken
			else:
				x_animation($PUpgradeMenu/P2/VAreaNakedChicken)


func _on_VAreaAS_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(proW[4], proM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.attack_speed_buff += 0.2
				tower.buff_morsels()
				if tower.attack_speed_buff > 0.3:
					$PUpgradeMenu/NakedChicken/VAreaAS.hide()
					$PUpgradeMenu/NakedChicken/OptionAS.hide() #could also change this to change sprite
			else:
				x_animation($PUpgradeMenu/NakedChicken/VAreaAS)


func _on_VAreaAD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(proW[5], proM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.damage_buff += 0.2
				tower.buff_morsels()
				if tower.damage_buff > 0.3:
					$PUpgradeMenu/NakedChicken/VAreaAD.hide()
					$PUpgradeMenu/NakedChicken/OptionAD.hide() #could also change this to change sprite
			else:
				x_animation($PUpgradeMenu/NakedChicken/VAreaAD)


func _on_VAreaUnit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(proW[6], proM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				tower.max_babies += 1
				$PUpgradeMenu/NakedChicken/VAreaUnit.hide()
				$PUpgradeMenu/NakedChicken/OptionUnit.hide() #could also change this to change sprite
			else:
				x_animation($PUpgradeMenu/NakedChicken/VAreaUnit)


func _on_VAreaP1_mouse_entered():
	$Text/Sausage.show()


func _on_VAreaP1_mouse_exited():
	$Text/Sausage.hide()


func _on_PArea_mouse_entered():
	$Text/MeatCube.show()


func _on_PArea_mouse_exited():
	$Text/MeatCube.hide()


func _on_VAreaBackribs_mouse_entered():
	$Text/Backribs.show()


func _on_VAreaBackribs_mouse_exited():
	$Text/Backribs.hide()


func _on_VAreaNakedChicken_mouse_entered():
	$Text/NakedChicken.show()


func _on_VAreaNakedChicken_mouse_exited():
	$Text/NakedChicken.hide()


func _on_VAreaAS_mouse_entered():
	$Text/NakedChickenAS.show()


func _on_VAreaAS_mouse_exited():
	$Text/NakedChickenAS.hide()


func _on_VAreaAD_mouse_entered():
	$Text/NakedChickenAD.show()


func _on_VAreaAD_mouse_exited():
	$Text/NakedChickenAD.hide()


func _on_VAreaUnit_mouse_entered():
	$Text/NakedChickenUnit.show()


func _on_VAreaUnit_mouse_exited():
	$Text/NakedChickenUnit.hide()


func _on_VAreaMove_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and !moveMode and (event.is_action_released("Mouse") or (!util.on_desktop and !event.pressed)):
			moveMode = true
			current_menu.hide()
			$Sprite.texture = normal_plate
			$Target.hide()
			$Delete.hide()
			tower.set_blue_range()
	
func _unhandled_input(event):
	var counter = 0
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and moveMode and (event.is_action_released("Mouse") or (!util.on_desktop and !event.pressed)):
			if tower.inRange:
				tower.posOffset = event.position - tower.position + Vector2(0,60)
				for m in tower.tower_morsels:
					m._go_To(event.position + tower.morselOffsets[counter] + Vector2(0, 20))
					counter += 1
			else:
				ui.failedAction()
			moveMode = false
			tower.initializeRangePolygon()
			tower.reset_morsel_color()

func _on_VAreaMove_mouse_entered():
	$Text/MorselMove.show()


func _on_VAreaMove_mouse_exited():
	$Text/MorselMove.hide()


func _on_VAreaDelete_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			if not (tower == null):
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.show_range(false)
				ui.wood += floor(tower.refundW)
				ui.metal += floor(tower.refundM)
				$AudioStreamPlayer.stream = refundSound
				$AudioStreamPlayer.play()
				ui.update()
				tower.queue_free()
				reset()


func _on_VAreaDelete_mouse_entered():
	$Text/Delete/RichTextLabel.text = "Sell this tower for " + String(floor(tower.refundW)) + " wood and " + String(floor(tower.refundM)) + " metal."
	$Text/Delete.show()


func _on_VAreaDelete_mouse_exited():
	$Text/Delete.hide()

func _on_GArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = make_tower("grain", -56)
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$GUpgradeMenu.show()
				current_menu = $GUpgradeMenu/G1
			else:
				x_animation($TowerMenu/Grain/GArea/GShape)


func _on_VAreaG1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, grainW[1], grainM[1], -47) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				current_menu = $GUpgradeMenu/G2
			else:
				x_animation($GUpgradeMenu/G1/VAreaG1)


func _on_VAreaSpaghetti_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, grainW[2], grainM[2], -22) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				current_menu = $GUpgradeMenu/Spaghetti
			else:
				x_animation($GUpgradeMenu/G2/VAreaSpaghetti)

func _on_VAreaPretzel_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.offshoot_upgrade, grainW[3], grainM[3], -25) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				current_menu = $GUpgradeMenu/Pretzel
			else:
				x_animation($GUpgradeMenu/G2/VAreaPretzel)


func _on_VAreaTD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(grainW[4], grainM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.duration += 2
				if tower.duration >= 14:
					$GUpgradeMenu/Pretzel/VAreaTD.hide()
					$GUpgradeMenu/Pretzel/OptionTD.hide() #could also change this to change sprite
			else:
				x_animation($GUpgradeMenu/Pretzel/VAreaTD)


func _on_VAreaDOT_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(grainW[5], grainM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.DOTDamage += 0.025
				if tower.DOTDamage >= 0.125:
					$GUpgradeMenu/Pretzel/VAreaDOT.hide()
					$GUpgradeMenu/Pretzel/OptionDOT.hide() #could also change this to change sprite
			else:
				x_animation($GUpgradeMenu/Pretzel/VAreaDOT)


func _on_VAreaPB_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(grainW[6], grainM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.pullBackChance += 0.1
				if tower.pullBackChance >= 0.2:
					$GUpgradeMenu/Pretzel/VAreaPB.hide()
					$GUpgradeMenu/Pretzel/OptionPB.hide() #could also change this to change sprite
			else:
				x_animation($GUpgradeMenu/Pretzel/VAreaPB)


func _on_GArea_mouse_entered():
	$Text/Rice.show()


func _on_GArea_mouse_exited():
	$Text/Rice.hide()


func _on_VAreaG1_mouse_entered():
	$Text/Corn.show()


func _on_VAreaG1_mouse_exited():
	$Text/Corn.hide()


func _on_VAreaSpaghetti_mouse_entered():
	$Text/Spaghetti.show()


func _on_VAreaSpaghetti_mouse_exited():
	$Text/Spaghetti.hide()


func _on_VAreaPretzel_mouse_entered():
	$Text/Pretzel.show()


func _on_VAreaPretzel_mouse_exited():
	$Text/Pretzel.hide()


func _on_VAreaTD_mouse_entered():
	$Text/PretzelTD.show()


func _on_VAreaTD_mouse_exited():
	$Text/PretzelTD.hide()


func _on_VAreaDOT_mouse_entered():
	$Text/PretzelDOT.show()


func _on_VAreaDOT_mouse_exited():
	$Text/PretzelDOT.hide()


func _on_VAreaPB_mouse_entered():
	$Text/PretzelPB.show()


func _on_VAreaPB_mouse_exited():
	$Text/PretzelPB.hide()


func _on_DArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = make_tower("dairy", -46)
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$DUpgradeMenu.show()
				current_menu = $DUpgradeMenu/D1
			else:
				x_animation($TowerMenu/Dairy/DArea/DShape)


func _on_VAreaD1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, dairyW[1], dairyM[1], -42) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				current_menu = $DUpgradeMenu/D2
			else:
				x_animation($DUpgradeMenu/D1/VAreaD1)


func _on_VAreaParmesan_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.upgrade, dairyW[2], dairyM[2], -33) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				current_menu = $DUpgradeMenu/Parmesan
			else:
				x_animation($DUpgradeMenu/D2/VAreaParmesan)


func _on_VAreaButter_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = simple_make_tower(tower.offshoot_upgrade, dairyW[3], dairyM[3], -25) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				current_menu = $DUpgradeMenu/Butter
			else:
				x_animation($DUpgradeMenu/D2/VAreaButter)


func _on_VAreaPDP_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(dairyW[4], dairyM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.posession_DP_limit += 2
				$DUpgradeMenu/Butter/VAreaPDP.hide()
				$DUpgradeMenu/Butter/OptionPDP.hide() #could also change this to change sprite
			else:
				x_animation($DUpgradeMenu/Butter/VAreaPDP)


func _on_VAreaPC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(dairyW[5], dairyM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.ability_cooldown -= 1.5
				if tower.ability_cooldown <= 5.5:
					$DUpgradeMenu/Butter/VAreaPC.hide()
					$DUpgradeMenu/Butter/OptionPC.hide() #could also change this to change sprite
			else:
				x_animation($DUpgradeMenu/Butter/VAreaPC)


func _on_VAreaSE_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			var worked = buy_something(dairyW[6], dairyM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Sprite.texture = normal_plate
				$Target.hide()
				$Delete.hide()
				tower.slowing_tower = true
				tower.towerSlowEffect += 0.1
				if tower.towerSlowEffect >= 0.2:
					$DUpgradeMenu/Butter/VAreaSE.hide()
					$DUpgradeMenu/Butter/OptionSE.hide() #could also change this to change sprite
			else:
				x_animation($DUpgradeMenu/Butter/VAreaSE)

func _on_DArea_mouse_entered():
	$Text/Milk.show()


func _on_DArea_mouse_exited():
	$Text/Milk.hide()


func _on_VAreaD1_mouse_entered():
	$Text/Cream.show()


func _on_VAreaD1_mouse_exited():
	$Text/Cream.hide()


func _on_VAreaParmesan_mouse_entered():
	$Text/Parmesan.show()


func _on_VAreaParmesan_mouse_exited():
	$Text/Parmesan.hide()


func _on_VAreaButter_mouse_entered():
	$Text/Butter.show()


func _on_VAreaButter_mouse_exited():
	$Text/Butter.hide()


func _on_VAreaPDP_mouse_entered():
	$Text/ButterPDP.show()


func _on_VAreaPDP_mouse_exited():
	$Text/ButterPDP.hide()


func _on_VAreaPC_mouse_entered():
	$Text/ButterPC.show()


func _on_VAreaPC_mouse_exited():
	$Text/ButterPC.hide()


func _on_VAreaSE_mouse_entered():
	$Text/ButterSE.show()


func _on_VAreaSE_mouse_exited():
	$Text/ButterSE.hide()


func _on_PlateArea_mouse_entered():
	$Sprite.texture = hover_plate


func _on_PlateArea_mouse_exited():
	if not current_menu.is_visible():
		$Sprite.texture = normal_plate


func _on_Area2D_mouse_entered():
	$Text/Target.show()


func _on_Area2D_mouse_exited():
	$Text/Target.hide()


func _on_Target_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == util.on_desktop:
			if event.pressed == util.on_desktop:
				target_index += 1
				if target_index >= target_types.size():
					target_index = 0
				if target_types[target_index] == "closest":
					$Target/Text.text = "Closest to Tower"
				if target_types[target_index] == "farthest":
					$Target/Text.text = "Farthest to Tower"
				if target_types[target_index] == "lowest":
					$Target/Text.text = "Lowest % Health"
				if target_types[target_index] == "highest":
					$Target/Text.text = "Highest % Health"
				if target_types[target_index] == "closest_end":
					$Target/Text.text = "Closest to End"
				if target_types[target_index] == "closest_start":
					$Target/Text.text = "Closest to Start"
				tower.set_target_type(target_types[target_index])
