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
		current_menu.show()


func _on_VArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		make_tower("vegetable")
		current_menu.hide()
		current_menu = $VUpgradeMenu

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
		

func reset():
	current_menu = $TowerMenu
	tower = null

func _on_BigArea_mouse_exited():
	current_menu.hide()


func _on_PArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		make_tower("protein")
		current_menu.hide()
		current_menu = $PUpgradeMenu
