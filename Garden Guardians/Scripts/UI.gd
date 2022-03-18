extends CanvasLayer


var wood = -1
var metal = -1


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
