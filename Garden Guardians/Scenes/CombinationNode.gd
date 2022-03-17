extends Node2D

var towers = []
var tower_to_combine = null

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
	print("size: ", towers.size())
	if towers.size() > 0:
		if towers[0].combinable == true and not (towers[0] == tower_to_combine):
			print("return true")
			towers[0].queue_free() #here u would switch out the tower
			return true
	print("return false")
	return false

func _on_Area2D_area_entered(area):
	if area.is_in_group("Tower"):
		print("tower entered")
		towers.append(area.get_parent())


func _on_Area2D_area_exited(area):
	if area.is_in_group("Tower"):
		print("tower removed")
		towers.remove(towers.find(area.get_parent()))
