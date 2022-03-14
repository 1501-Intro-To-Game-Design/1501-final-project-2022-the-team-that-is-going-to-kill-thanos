extends RigidBody2D

var is_Metal = false
var is_Wood = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _spawn(w, loc):
	position = loc
	is_Wood = w
	if !is_Wood:
		is_Metal = true
		$Sprite.modulate = Color(107, 110, 95)
	else:
		$Sprite.modulate = Color(120, 65, 50)

func _pulled(destination):
	var direction = destination - position
	while abs((destination - position).x) < 1 and abs((destination - position).y) < 1:
		position += direction.normalized() * 5
	queue_free()