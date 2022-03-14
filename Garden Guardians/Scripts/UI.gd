extends CanvasLayer


var wood = -1
var metal = -1


func _ready():
	add_wood()
	add_metal()

func add_wood():
	wood += 1
	$WLabel.text = str(wood)
	
func add_metal():
	metal += 1
	$MLabel.text = str(metal)

