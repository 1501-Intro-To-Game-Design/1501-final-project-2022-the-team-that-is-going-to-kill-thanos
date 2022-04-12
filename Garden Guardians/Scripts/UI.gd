extends CanvasLayer
#sounds stuff
export (Resource) var roundWin
export (Resource) var roundLoss
export (Resource) var roundStart
export (Resource) var pause
export (Resource) var play
export (Resource) var defultButton
export (Resource) var pickUp
export (Resource) var lostLife
export (Resource) var backgroundTrack
export (Resource) var actionFailed
signal restart
var map_name = ""
var wood = -1
var metal = -1
var paused = false

var firstWavePress = true
var secondWavePress = false
var thirdWavePress = false
var tutorialLevel = false

var hovering = false

var playerLives = 25
signal nextRoundGo

func _ready():
	playerLives = 25
	wood = 999 #16
	metal = 999 #6
	update()
	$Lives.text = String(playerLives)
	$RestartButton.visible = false
	playBackgroundTrack()

func connect_stuff(name_of_root):
	get_parent().get_node(name_of_root + "/MovingEnemies").connect("player_life_lost", self, "_on_player_life_lost")
	if name_of_root == "Tablecloth":
		$NextButton.global_position = $TableclothNode.global_position
	elif name_of_root == "Level":
		$NextButton.global_position = $FarmNode.global_position

func add_wood():
	wood += 1
	$ResourcePlayer.volume_db = 20 + util.g_sound
	$ResourcePlayer.play()
	update()
	
func add_metal():
	metal += 1
	$ResourcePlayer.volume_db = 20 + util.g_sound
	$ResourcePlayer.play()
	update()

func update():
	$WLabel.text = str(wood)
	$WLabel/MLabel.text = str(metal)


func _on_Area2D_mouse_entered():
	hovering = true


func _on_Area2D_mouse_exited():
	hovering = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if hovering:
					_load_n_play(roundStart,4)
					emit_signal("nextRoundGo")
					if tutorialLevel and firstWavePress:
						firstWavePress = false
						secondWavePress = true
						get_parent().get_node("Tutorial").get_node("FirstWaveTutorial").hide()
					elif tutorialLevel and secondWavePress:
						secondWavePress = false
						thirdWavePress = true
						get_parent().get_node("Tutorial").get_node("SecondWave").hide()
					elif tutorialLevel and thirdWavePress:
						thirdWavePress = false
						get_parent().get_node("Tutorial").get_node("ThirdWave").hide()

func waveInProgress():
	$NextButton.visible = false

func waveEnd():
	if not tutorialLevel:
		$NextButton.visible = true
	_load_n_play(roundWin,10)

func updateRound(roundNum):
	$Round.text = String(roundNum)	

func failedAction():
	_load_n_play(actionFailed, 7)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if not paused:
					paused = true
					get_tree().paused = true
					$PauseButton.texture = load("res://Sprites/UI Sprites/Pause.png")
					_load_n_play(pause,-1)
					get_parent().get_node("MainMenu").showInGameMenu()

func _on_player_life_lost(livesLost):
	playerLives -= livesLost
	_load_n_play(lostLife, 15)
	if playerLives < 0:
		playerLives = 0
	$Lives.text = String(playerLives)
	if playerLives == 0:
		$PauseButton.visible = false
		$RestartButton.visible = true
		get_tree().paused = true
		_load_n_play(roundLoss,10)




func _on_Restart_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				get_tree().reload_current_scene()
				get_tree().paused = false
				$RestartButton.visible = false
				$NextButton.visible = true
				$PauseButton.visible = true
				playerLives = 25
				emit_signal("restart")
				_ready()
				

func _load_n_play(sound, vol):
	if vol != -1:
		$AudioStreamPlayer.volume_db = vol - 1 + util.g_sound
	else: 
		$AudioStreamPlayer.volume_db = 24 - 1 + util.g_sound
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()

func playBackgroundTrack():
	$BackgroundTrack.volume_db = -8 + util.g_sound
	$BackgroundTrack.play()
	
func updateVolume():
	$AudioStreamPlayer.volume_db = 24 - 1 + util.g_sound
	$ResourcePlayer.volume_db = 20 + util.g_sound
	$BackgroundTrack.volume_db = -8 + util.g_sound

func _on_BackgroundTrack_finished():
	playBackgroundTrack()

func hide_UI():
	for i in get_children():
		if not i.get_class() == "AudioStreamPlayer":
			i.hide()

func show_UI():
	for i in get_children():
		if not i.get_class() == "AudioStreamPlayer" and not "Delay Show" in i.get_groups():
			i.show()
