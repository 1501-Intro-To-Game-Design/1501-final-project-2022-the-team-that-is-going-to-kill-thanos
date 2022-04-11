extends CanvasLayer


# Declare member variables here. Examples:
export (PackedScene) var levelOneScene


# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/ui".hide_UI()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewGame_pressed():
	$NewGame.hide()
	$Exit.hide()
	$Level1.show()
	$Back.show()


func _on_Back_pressed():
	$NewGame.show()
	$Exit.show()
	$Level1.hide()
	$Back.hide()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Level1_pressed():
	$"/root/ui".show_UI()
	hide_menu()
	var level = levelOneScene.instance()
	get_parent().add_child(level)

func hide_menu():
	for i in get_children():
		i.hide()

func show_menu():
	$NewGame.show()
	$Exit.show()
