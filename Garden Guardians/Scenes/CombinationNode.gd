extends Node2D

var towers = []
var tower_to_combine = null

export (PackedScene) var fries_and_ketchup
export (PackedScene) var marinara_spaghetti
export (PackedScene) var gnocchi
export (PackedScene) var baked_ratatouille
export (PackedScene) var tomato_backribs
export (PackedScene) var ribtato_tower
export (PackedScene) var rib_spaghetti
export (PackedScene) var cheese_ribs
export (PackedScene) var loaded_potato

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#ON EVERY BACKRIB ADD THIS FUNCTION BEFORE SIMPLE MAKE TOWER: towers[0].plate.make_rib_plate()

func on_drag_end():
	if towers.size() > 0:
		if towers[0].combinable == true and not (towers[0] == tower_to_combine):
			var new_tower = null
			if tower_to_combine.is_in_group("Tomato"):
				if towers[0].is_in_group("Potato"):
					new_tower = fries_and_ketchup
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Backribs"):
					new_tower = tomato_backribs
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Spaghetti"):
					new_tower = marinara_spaghetti
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Parmesan"):
					new_tower = baked_ratatouille
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
			elif tower_to_combine.is_in_group("Potato"):
				if towers[0].is_in_group("Tomato"):
					new_tower = fries_and_ketchup
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Backribs"):
					new_tower = ribtato_tower #CHANGE THIS
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Spaghetti"):
					new_tower = gnocchi
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Parmesan"):
					new_tower = loaded_potato
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
			elif tower_to_combine.is_in_group("Backribs"):
				if towers[0].is_in_group("Tomato"):
					new_tower = tomato_backribs
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Potato"):
					new_tower = ribtato_tower
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Spaghetti"):
					new_tower = rib_spaghetti
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Parmesan"):
					new_tower = cheese_ribs
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
			elif tower_to_combine.is_in_group("Spaghetti"):
				if towers[0].is_in_group("Tomato"):
					new_tower = marinara_spaghetti
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Potato"):
					new_tower = gnocchi
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Backribs"):
					new_tower = rib_spaghetti
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
			elif tower_to_combine.is_in_group("Parmesan"):
				if towers[0].is_in_group("Tomato"):
					new_tower = baked_ratatouille
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Backribs"):
					new_tower = cheese_ribs
					towers[0].plate.make_rib_plate()
					towers[0].plate.simple_make_tower(new_tower, 0, 0)
					towers[0].queue_free()
					return true
				elif towers[0].is_in_group("Potato"):
					new_tower = loaded_potato
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
