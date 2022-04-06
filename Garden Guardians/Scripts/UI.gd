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

var wood = -1
var metal = -1
var paused = false

var hovering = false

var playerLives = 25
signal nextRoundGo

func _ready():
	get_parent().get_node("Level/MovingEnemies").connect("player_life_lost", self, "_on_player_life_lost")
	wood = 999 #16
	metal = 999 #6
	update()
	$Lives.text = "Lives: " + String(playerLives)
	$RestartButton.visible = false
	playBackgroundTrack()

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
	$MLabel.text = str(metal)


func _on_Area2D_mouse_entered():
	hovering = true


func _on_Area2D_mouse_exited():
	hovering = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if hovering:
					_load_n_play(roundStart,5)
					emit_signal("nextRoundGo")

func waveInProgress():
	$NextButton.visible = false

func waveEnd():
	$NextButton.visible = true
	_load_n_play(roundWin,10)

func updateRound(roundNum):
	$Round.text = "Wave: " + String(roundNum)	


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if paused:
					paused = false
					_load_n_play(play,-1)
					get_tree().paused = false
					$PauseButton.texture = load("res://Sprites/Pause.png")
				else:
					paused = true
					get_tree().paused = true
					$PauseButton.texture = load("res://Sprites/Play.png")
					_load_n_play(pause,-1)

func _on_player_life_lost(livesLost):
	playerLives -= livesLost
	_load_n_play(lostLife, 15)
	if playerLives < 0:
		playerLives = 0
	$Lives.text = "Lives: " + String(playerLives)
	if playerLives == 0:
		$PauseButton.visible = false
		$RestartButton.visible = true
		get_tree().paused = true
		_load_n_play(roundLoss,10)




func _on_Restart_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				print("Restart Pressed")
				get_tree().reload_current_scene()
				get_tree().paused = false
				$RestartButton.visible = false
				$NextButton.visible = true
				$PauseButton.visible = true
				playerLives = 25

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
	


func _on_BackgroundTrack_finished():
	playBackgroundTrack()
