extends CanvasLayer


var wood = -1
var metal = -1


func _ready():
	#FOR TESTING
	wood = 24
	metal = 24
	add_wood()
	add_metal()

func add_wood():
	wood += 1
	$WLabel.text = str(wood)
	
func add_metal():
	metal += 1
	$MLabel.text = str(metal)

func update():
	$WLabel.text = str(wood)
	$MLabel.text = str(metal)