extends RigidBody2D

var is_Metal = false
var is_Wood = true

var wSprite = load("res://Sprites/Wood.png")
var mSprite = load("res://Sprites/Metal.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _spawn(w, loc):
	position = loc
	is_Wood = w
	if !is_Wood:
		is_Metal = true
		$Sprite.texture = mSprite
	else:
		$Sprite.texture = wSprite

func _pulled(destination):
	var direction = destination - position
	while abs((destination - position).x) < 1 and abs((destination - position).y) < 1:
		position += direction.normalized() * 5
	queue_free()
