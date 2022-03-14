extends Node2D

var tower #tower will be the tower assigned to this plate (needed for upgrading)

export (PackedScene) var vegetable_scene
export (PackedScene) var fruit_scene
export (PackedScene) var protein_scene
export (PackedScene) var dairy_scene
export (PackedScene) var grain_scene

export var y_spawn_offset = -60

var current_menu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


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
	if tower_type == "vegetable":
		tower = vegetable_scene.instance()
	elif tower_type == "fruit":
		tower = fruit_scene.instance()
	elif tower_type == "grain":
		tower = grain_scene.instance()
	elif tower_type == "dairy":
		tower = dairy_scene.instance()
	else:
		tower = protein_scene.instance()
	get_parent().add_child(tower)
	tower.position = self.get_global_position() + Vector2(0, y_spawn_offset)
		


func _on_BigArea_mouse_exited():
	current_menu.hide()
