extends CanvasLayer


var wood = -1
var metal = -1
var paused = false

var hovering = false
var restartHovering = false

var playerLives = 10
signal nextRoundGo

func _ready():
	get_parent().get_node("Level/MovingEnemies").connect("player_life_lost", self, "_on_player_life_lost")
	#FOR TESTING
	wood = 100
	metal = 100
	update()
	$Lives.text = "Lives: " + String(playerLives)
	$Restart.visible = false

func add_wood():
	wood += 1
	$AudioStreamPlayer2D.play()
	$WLabel.text = str(wood)
	
func add_metal():
	metal += 1
	$AudioStreamPlayer2D.play()
	$MLabel.text = str(metal)

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
					emit_signal("nextRoundGo")
				if restartHovering:
					get_tree().reload_current_scene()

func waveInProgress():
	$NextButton.visible = false

func waveEnd():
	$NextButton.visible = true

func updateRound(roundNum):
	$Round.text = "Wave: " + String(roundNum)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if paused:
					paused = false
					get_tree().paused = false
					$PauseButton.texture = load("res://Sprites/Pause.png")
				else:
					paused = true
					get_tree().paused = true
					$PauseButton.texture = load("res://Sprites/Play.png")

func _on_player_life_lost(livesLost):
	playerLives -= livesLost
	if playerLives < 0:
		playerLives = 0
	$Lives.text = "Lives: " + String(playerLives)
	if playerLives == 0:
		$PauseButton.visible = false
		$Restart.visible = true
		get_tree().paused = true

func _on_Restart_mouse_entered():
	restartHovering = true


func _on_Restart_mouse_exited():
	restartHovering = false
