extends CanvasLayer


var wood = -1
var metal = -1

var hovering = false
signal nextRoundGo

func _ready():
	#FOR TESTING
	wood = 25
	metal = 25
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
