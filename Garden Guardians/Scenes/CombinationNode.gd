extends Node2D

var towers = []
var tower_to_combine = null

export (PackedScene) var fries_and_ketchup

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_drag_end():
	if towers.size() > 0:
		if towers[0].combinable == true and not (towers[0] == tower_to_combine):
			var new_tower = null
			if tower_to_combine.is_in_group("Tomato"):
				if towers[0].is_in_group("Potato"):
					new_tower = fries_and_ketchup
			elif tower_to_combine.is_in_group("Potato"):
				if towers[0].is_in_group("Tomato"):
					new_tower = fries_and_ketchup
			towers[0].plate.simple_make_tower(new_tower, 0, 0)
			towers[0].queue_free() 
			return true
	return false

func _on_Area2D_area_entered(area):
	if area.is_in_group("Tower"):
		towers.append(area.get_parent())


func _on_Area2D_area_exited(area):
	if area.is_in_group("Tower"):
		towers.remove(towers.find(area.get_parent()))
