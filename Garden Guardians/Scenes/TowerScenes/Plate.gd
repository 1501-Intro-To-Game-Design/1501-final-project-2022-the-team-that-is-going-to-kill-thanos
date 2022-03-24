extends Node2D

var tower #tower will be the tower assigned to this plate (needed for upgrading)

export (PackedScene) var vegetable_scene
export (PackedScene) var fruit_scene
export (PackedScene) var protein_scene
export (PackedScene) var dairy_scene
export (PackedScene) var grain_scene

export var y_spawn_offset = -5

var current_menu


#COSTS// each new element after the first is the cost of the upgrade
var vegW = [9]
var vegM = [2]
var fruitW = [12]
var fruitM = [0]
var grainW = [4]
var grainM = [5]
var dairyW = [11]
var dairyM = [7]
var proW = [0]
var proM = [4]

# Called when the node enters the scene tree for the first time.
func _ready():
	current_menu = $TowerMenu


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			current_menu.show()


func _on_VArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			make_tower("vegetable")
			current_menu.hide()
			$VUpgradeMenu.show()
			current_menu = $VUpgradeMenu/V1

func make_tower(tower_type):
	if tower_type == "vegetable" and vegW[0] <= ui.wood and vegM[0] <= ui.metal:
		ui.wood -= vegW[0]
		ui.metal -= vegM[0]
		ui.update()
		tower = vegetable_scene.instance()
	elif tower_type == "fruit" and fruitW[0] <= ui.wood and fruitM[0] <= ui.metal:
		ui.wood -= fruitW[0]
		ui.metal -= fruitM[0]
		ui.update()
		tower = fruit_scene.instance()
	elif tower_type == "grain" and grainW[0] <= ui.wood and grainM[0] <= ui.metal:
		ui.wood -= grainW[0]
		ui.metal -= grainM[0]
		ui.update()
		tower = grain_scene.instance()
	elif tower_type == "dairy" and dairyW[0] <= ui.wood and dairyM[0] <= ui.metal:
		ui.wood -= dairyW[0]
		ui.metal -= dairyM[0]
		ui.update()
		tower = dairy_scene.instance()
	elif tower_type == "protein" and proW[0] <= ui.wood and proM[0] <= ui.metal:
		ui.wood -= proW[0]
		ui.metal -= proM[0]
		ui.update()
		tower = protein_scene.instance()
	get_parent().add_child(tower)
	tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
	tower.plate = self
	
func simple_make_tower(tower_to_make, wood_cost, metal_cost):
	if(ui.wood >= wood_cost and ui.metal >= metal_cost):
		ui.wood -= wood_cost
		ui.metal -= metal_cost
		ui.update()
		tower.queue_free()
		tower = tower_to_make.instance()
		get_parent().add_child(tower)
		tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		tower.plate = self
		return true
	return false
	
func buy_something(wood_cost, metal_cost):
	if(ui.wood >= wood_cost and ui.metal >= metal_cost):
		ui.wood -= wood_cost
		ui.metal -= metal_cost
		ui.update()
		return true
	return false
		

func reset():
	current_menu = $TowerMenu
	tower = null

func _on_BigArea_mouse_exited():
	current_menu.hide()


func _on_PArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			make_tower("protein")
			current_menu.hide()
			$PUpgradeMenu.show()
			current_menu = $PUpgradeMenu/P1


func _on_VArea1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, 0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				current_menu = $VUpgradeMenu/V2


func _on_VAreaCarrot_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.offshoot_upgrade, 0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				current_menu = $VUpgradeMenu/Carrot


func _on_VAreaPotato_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, 0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				current_menu = $VUpgradeMenu/Potato


func _on_VAreaSC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.stun_chance += 0.2
				if tower.stun_chance > .70:
					$VUpgradeMenu/Carrot/VAreaSC.hide()
					$VUpgradeMenu/Carrot/OptionSC.hide() #could also change this to change sprite


func _on_VAreaSD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.stun_duration += 0.2
				if tower.stun_duration > .90:
					$VUpgradeMenu/Carrot/VAreaSD.hide()
					$VUpgradeMenu/Carrot/OptionSD.hide() #could also change this to change sprite


func _on_VAreaACD_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.attack_cooldown -= 0.5
				if tower.attack_cooldown < 3.1:
					$VUpgradeMenu/Carrot/VAreaACD.hide()
					$VUpgradeMenu/Carrot/OptionACD.hide() #could also change this to change sprite


func _on_VAreaF1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, 0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				current_menu = $FUpgradeMenu/F2


func _on_VAreaTomato_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.upgrade, 0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				current_menu = $FUpgradeMenu/Tomato


func _on_VAreaCherry_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = simple_make_tower(tower.offshoot_upgrade, 0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.num_projectiles += 1
				current_menu = $FUpgradeMenu/Cherry


func _on_VAreaEC_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.num_projectiles += 1
				if tower.num_projectiles > 2:
					$FUpgradeMenu/Cherry/VAreaEC.hide()
					$FUpgradeMenu/Cherry/OptionEC.hide() #could also change this to change sprite


func _on_VAreaAR_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.increase_range(20) #change this
				if tower.get_range() > 185:
					$FUpgradeMenu/Cherry/VAreaAR.hide()
					$FUpgradeMenu/Cherry/OptionAR.hide() #could also change this to change sprite


func _on_VAreaAOE_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var worked = buy_something(0, 0) #tower to make, wood cost, metal cost
			current_menu.hide()
			if worked:
				tower.AOE_percent += 0.05 #change this
				if tower.AOE_percent > 0.08:
					$FUpgradeMenu/Cherry/VAreaAOE.hide()
					$FUpgradeMenu/Cherry/OptionAOE.hide() #could also change this to change sprite


func _on_FArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			make_tower("fruit")
			current_menu.hide()
			$FUpgradeMenu.show()
			current_menu = $FUpgradeMenu/F1
