extends Path2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

#Function to increment the Pathway pathFollow2D's offset by the given number
func addToOffset(addNum):
	$Pathway.set_offset($Pathway.get_offset() + addNum)

func addToUnitOffset(addNum):
	$Pathway.set_unit_offset($Pathway.get_unit_offset() + addNum)

#Function that returns the position of the Pathway pathFollow2D
func getPathLocation():
	return $Pathway.position
