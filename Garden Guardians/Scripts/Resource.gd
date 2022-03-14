extends RigidBody2D

var is_Metal = false
var is_Wood = true

var seeking_player = false

var wSprite = load("res://Sprites/Wood.png")
var mSprite = load("res://Sprites/Metal.png")
var player = null

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
		
func _process(delta):
	if seeking_player:
		seek_player(delta)

func seek_player(delta):
	print("yo im here")
	var direction = player.global_position - global_position
	var distance = sqrt(pow((player.get_global_position().x - global_position.x), 2) + pow((player.get_global_position().y - global_position.y), 2))
	if abs(distance) > 10:
		position += direction.normalized() * delta * 50
	else:
		if is_Wood:
			ui.add_wood()
		else:
			ui.add_metal()
		queue_free()


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		player = area.get_parent()
		seeking_player = true


func _on_Area2D_area_exited(area):
	if area.get_parent().is_in_group("Player"):
		player = null
		seeking_player = false
