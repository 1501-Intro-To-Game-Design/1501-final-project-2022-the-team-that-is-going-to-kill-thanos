extends Node2D

var tower = null #tower will be the tower assigned to this plate (needed for upgrading)

var target_types = ["closest", "farthest", "lowest", "highest", "closest_end", "closest_start"]
var target_index = 0
var in_area = false

export (PackedScene) var vegetable_scene
export (PackedScene) var fruit_scene
export (PackedScene) var protein_scene
export (PackedScene) var dairy_scene
export (PackedScene) var grain_scene

export (Resource) var upgradeSound

export var y_spawn_offset = -50

var current_menu


#COSTS// each new element after the first is the cost of the upgrade -- 1, 2, 3, offshoot, upgrade1, up2, up3
var vegW = [9, 12, 15, 5, 10, 4, 5] #SC, SD, ACD
var vegM = [2, 3, 5, 7, 0, 2, 2]
var fruitW = [12, 15, 17, 5, 10, 4, 2] #EC, AR, AOE
var fruitM = [0, 0, 1, 5, 10, 1, 3 ]
var grainW = [4]
var grainM = [5]
var dairyW = [11]
var dairyM = [7]
var proW = [0, 0, 0, 2, 4, 4, 8] #AttackSpeed, Damage, ExtraUnit
var proM = [4, 3, 4, 6, 4, 4, 8]

# Called when the node enters the scene tree for the first time.
func _ready():
	current_menu = $TowerMenu

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			current_menu.show()
			if not (tower == null):
				$Target.show()
				$Delete.show()


func _on_VArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = make_tower("vegetable")
			if worked:
				current_menu.hide()
				$VUpgradeMenu.show()
				current_menu = $VUpgradeMenu/V1

func make_tower(tower_type):
	upgrade()
	if tower_type == "vegetable" and vegW[0] <= ui.wood and vegM[0] <= ui.metal:
		ui.wood -= vegW[0]
		ui.metal -= vegM[0]
		ui.update()
		y_spawn_offset = -5
		tower = vegetable_scene.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		y_spawn_offset = -50
		return true
	elif tower_type == "fruit" and fruitW[0] <= ui.wood and fruitM[0] <= ui.metal:
		ui.wood -= fruitW[0]
		ui.metal -= fruitM[0]
		ui.update()
		tower = fruit_scene.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		return true
	elif tower_type == "grain" and grainW[0] <= ui.wood and grainM[0] <= ui.metal:
		ui.wood -= grainW[0]
		ui.metal -= grainM[0]
		ui.update()
		tower = grain_scene.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		return true
	elif tower_type == "dairy" and dairyW[0] <= ui.wood and dairyM[0] <= ui.metal:
		ui.wood -= dairyW[0]
		ui.metal -= dairyM[0]
		ui.update()
		tower = dairy_scene.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		return true
	elif tower_type == "protein" and proW[0] <= ui.wood and proM[0] <= ui.metal:
		ui.wood -= proW[0]
		ui.metal -= proM[0]
		ui.update()
		tower = protein_scene.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		return true
	return false
	
func simple_make_tower(tower_to_make, wood_cost, metal_cost): #simpler than above?
	if(ui.wood >= wood_cost and ui.metal >= metal_cost and not (tower_to_make == null)):
		upgrade()
		ui.wood -= wood_cost
		ui.metal -= metal_cost
		ui.update()
		tower.queue_free()
		tower = tower_to_make.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		tower.set_target_type(target_types[target_index])
		return true
	return false
	
func buy_something(wood_cost, metal_cost):
	if(ui.wood >= wood_cost and ui.metal >= metal_cost):
		upgrade()
		ui.wood -= wood_cost
		ui.metal -= metal_cost
		ui.update()
		return true
	return false
		

func reset():
	current_menu = $TowerMenu
	tower = null

func upgrade():
	$AudioStreamPlayer.stream = upgradeSound
	$AudioStreamPlayer.play()


func _on_PArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = make_tower("protein")
			if worked:
				current_menu.hide()
				$PUpgradeMenu.show()
				current_menu = $PUpgradeMenu/P1


func _on_VArea1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, vegW[1], vegM[1]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $VUpgradeMenu/V2


func _on_VAreaCarrot_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.offshoot_upgrade, vegW[3], vegM[3]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $VUpgradeMenu/Carrot


func _on_VAreaPotato_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, vegW[2], vegM[2]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $VUpgradeMenu/Potato


func _on_VAreaSC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(vegW[4], vegM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.stun_chance += 0.2
				if tower.stun_chance > .70:
					$VUpgradeMenu/Carrot/VAreaSC.hide()
					$VUpgradeMenu/Carrot/OptionSC.hide() #could also change this to change sprite


func _on_VAreaSD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(vegW[5], vegM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.stun_duration += 0.25
				if tower.stun_duration > 1.40:
					$VUpgradeMenu/Carrot/VAreaSD.hide()
					$VUpgradeMenu/Carrot/OptionSD.hide() #could also change this to change sprite


func _on_VAreaACD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(vegW[6], vegM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.attack_cooldown -= 0.5
				if tower.attack_cooldown < 3.1:
					$VUpgradeMenu/Carrot/VAreaACD.hide()
					$VUpgradeMenu/Carrot/OptionACD.hide() #could also change this to change sprite


func _on_VAreaF1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, fruitW[1], fruitM[1]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $FUpgradeMenu/F2


func _on_VAreaTomato_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, fruitW[2], fruitM[2]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $FUpgradeMenu/Tomato


func _on_VAreaCherry_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.offshoot_upgrade, fruitW[3], fruitM[3]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.num_projectiles += 1
				current_menu = $FUpgradeMenu/Cherry


func _on_VAreaEC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(fruitW[4], fruitM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.num_projectiles += 1
				if tower.num_projectiles > 2:
					$FUpgradeMenu/Cherry/VAreaEC.hide()
					$FUpgradeMenu/Cherry/OptionEC.hide() #could also change this to change sprite


func _on_VAreaAR_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(fruitW[5], fruitM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.increase_range(25) #change this
				if tower.get_range() > 290:
					$FUpgradeMenu/Cherry/VAreaAR.hide()
					$FUpgradeMenu/Cherry/OptionAR.hide() #could also change this to change sprite


func _on_VAreaAOE_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(fruitW[6], fruitM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.explosive = true
				tower.AOE_percent += 0.1 #change this
				if tower.AOE_percent > 0.25:
					$FUpgradeMenu/Cherry/VAreaAOE.hide()
					$FUpgradeMenu/Cherry/OptionAOE.hide() #could also change this to change sprite


func _on_FArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = make_tower("fruit")
			if worked:
				current_menu.hide()
				$FUpgradeMenu.show()
				current_menu = $FUpgradeMenu/F1


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
	if not(in_area):
		if current_menu != null:
			current_menu.hide()
			$Target.hide()
			$Delete.hide()


func _on_Text_mouse_entered():
	in_area = true


func _on_Text_mouse_exited():
	in_area = false


func _on_Text_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				target_index += 1
				if target_index >= target_types.size():
					target_index = 0
				if target_types[target_index] == "closest":
					$Target/Text.text = "Target: Closest to Tower"
				if target_types[target_index] == "farthest":
					$Target/Text.text = "Target: Farthest to Tower"
				if target_types[target_index] == "lowest":
					$Target/Text.text = "Target: Lowest % Health"
				if target_types[target_index] == "highest":
					$Target/Text.text = "Target: Highest % Health"
				if target_types[target_index] == "closest_end":
					$Target/Text.text = "Target: Closest to End"
				if target_types[target_index] == "closest_start":
					$Target/Text.text = "Target: Closest to Start"
				tower.set_target_type(target_types[target_index])


func _on_VAreaP1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, proW[1], proM[1]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $PUpgradeMenu/P2


func _on_VAreaBackribs_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, proW[2], proM[2]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $PUpgradeMenu/Backribs


func _on_VAreaNakedChicken_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.offshoot_upgrade, proW[3], proM[3]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				current_menu = $PUpgradeMenu/NakedChicken


func _on_VAreaAS_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(proW[4], proM[4]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.attack_speed_buff += 0.2
				tower.buff_morsels()
				if tower.attack_speed_buff > 0.3:
					$PUpgradeMenu/NakedChicken/VAreaAS.hide()
					$PUpgradeMenu/NakedChicken/OptionAS.hide() #could also change this to change sprite


func _on_VAreaAD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(proW[5], proM[5]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.damage_buff += 0.2
				tower.buff_morsels()
				if tower.damage_buff > 0.3:
					$PUpgradeMenu/NakedChicken/VAreaAD.hide()
					$PUpgradeMenu/NakedChicken/OptionAD.hide() #could also change this to change sprite


func _on_VAreaUnit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(proW[6], proM[6]) #tower to make, wood cost, metal cost
			if worked:
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.max_babies += 1
				$PUpgradeMenu/NakedChicken/VAreaUnit.hide()
				$PUpgradeMenu/NakedChicken/OptionUnit.hide() #could also change this to change sprite


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
	pass # Replace with function body.
	#this is code to move morsel


func _on_VAreaMove_mouse_entered():
	$Text/MorselMove.show()


func _on_VAreaMove_mouse_exited():
	$Text/MorselMove.hide()


func _on_VAreaDelete_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if not (tower == null):
				current_menu.hide()
				$Target.hide()
				$Delete.hide()
				tower.queue_free()
				reset()


func _on_VAreaDelete_mouse_entered():
	$Text/Delete.show()


func _on_VAreaDelete_mouse_exited():
	$Text/Delete.hide()
