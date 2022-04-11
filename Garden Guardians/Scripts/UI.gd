extends CanvasLayer


var wood = -1
var metal = -1
var paused = false

var hovering = false
signal nextRoundGo

func _ready():
<<<<<<< Updated upstream
	#FOR TESTING
	wood = 100
	metal = 100
=======
	playerLives = 25
	wood = 16 #16
	metal = 6 #6
>>>>>>> Stashed changes
	update()

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
