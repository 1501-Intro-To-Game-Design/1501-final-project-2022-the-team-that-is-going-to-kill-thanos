extends CanvasLayer


var wood = -1
var metal = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_Resources(true)
	_update_Resources(false)


func _update_Resources(w):
	if w:
		wood += 1
		$WLabel.text = str(wood)
	else:
		metal += 1
		$MLabel.text = str(metal)

