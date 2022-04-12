extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	ui.connect_stuff("Tutorial")
	for i in get_children():
		if "Plate" in i.get_groups():
			if not "First" in i.get_groups():
				i.hide()
	$PlateIntro.show()
	$"/root/ui/NextButton".hide()
	$"/root/ui".tutorialLevel = true
	$"/root/ui".metal = 4
	$"/root/ui".wood = 12
	$"/root/ui".update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
