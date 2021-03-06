extends CanvasLayer


# Declare member variables here. Examples:
export (PackedScene) var levelOneScene
export (PackedScene) var levelTwoScene
export (PackedScene) var tutorialScene
export (PackedScene) var levelThreeScene
var currentLevel


# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/ui".hide_UI()
	$InGameMenu/Shade.set_color(Color(0.2, 0.2, 0.2, 0.6))
	$"/root/ui".connect("restart", self, "reset_state")
	$Main.show()
	initUIElements()

func reset_state():
	_on_InGameBack_pressed()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass



func _on_NewGame_pressed():
	$Main.hide()
	$Levels.show()

func _on_Back_pressed():
	$Main.show()
	$Levels.hide()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Level1_pressed():
	$"/root/ui".show_UI()
	hide_menu()
	var level = levelOneScene.instance()
	get_parent().add_child(level)
	currentLevel = "Level1"

func hide_menu():
	for i in get_children():
		i.hide()

func show_menu():
	$Main.show()
	$Background.show()


func _on_Volume_value_changed(value):
	util.g_sound = value/10
	$"/root/ui".updateVolume()
	$InGameMenu/InGameVolume.value = value


func _on_InGameVolume_value_changed(value):
	util.g_sound = value/10
	$"/root/ui".updateVolume()
	$Main/Volume.value = value

func _on_InGameQuit_pressed():
	get_tree().quit()


func _on_InGameBack_pressed():
	if currentLevel == "Level1":
		get_parent().get_node("Level").queue_free()
	elif currentLevel == "Level2":
		get_parent().get_node("Tablecloth").queue_free()
	elif currentLevel == "Tutorial":
		get_parent().get_node("Tutorial").queue_free()
	elif currentLevel == "Level3":
		get_parent().get_node("Kitchen").queue_free()
	$"/root/ui".hide_UI()
	$"/root/ui"._ready()
	show_menu()
	hideInGameMenu()
	if $"/root/ui".paused:
		$"/root/ui".paused = false
		get_tree().paused = false
	$"/root/ui".tutorialLevel = false

func showInGameMenu():
	$InGameMenu.show()

func hideInGameMenu():
	$InGameMenu.hide()


func _on_InGameResume_pressed():
	ui.paused = false
	ui._load_n_play(ui.play,-1)
	get_tree().paused = false
	hideInGameMenu()

func _on_Level2_pressed():
	$"/root/ui".show_UI()
	hide_menu()
	var level = levelTwoScene.instance()
	get_parent().add_child(level)
	currentLevel = "Level2"

func _on_Tutorial_pressed():
	$"/root/ui".show_UI()
	$"/root/ui".firstWavePress = true
	$"/root/ui".secondWavePress = false
	$"/root/ui".thirdWavePress = false
	hide_menu()
	var level = tutorialScene.instance()
	get_parent().add_child(level)
	currentLevel = "Tutorial"

func _on_Level3_pressed():
	$"/root/ui".show_UI()
	hide_menu()
	var level = levelThreeScene.instance()
	get_parent().add_child(level)
	currentLevel = "Level3"

func initUIElements():
	pass


func _on_Mobile_toggled(button_pressed:bool):
	util.on_desktop = not button_pressed
