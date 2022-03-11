extends Path2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#enemy.position = $Pathway.position
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
func addToOffset(addNum):
	$Pathway.set_offset($Pathway.get_offset() + addNum)

func getPathLocation():
	return $Pathway.position
